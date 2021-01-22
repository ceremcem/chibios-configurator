require! 'dcs': {DcsTcpClient, Actor, SignalBranch}
require! '../../config'
require! 'fs'
require! 'prelude-ls': {
    find, map, pairs-to-obj, 
    obj-to-pairs, group-by, unique, filter
    pairs-to-obj}
require! 'fancy-log': log 

require! './generated-db/supported-mcus.json'

require! './lib': {
    mustache-apply, ractive-compile, readdirSyncRecursive,
    read-xml, read-lson}

SECOND_CHAR = 1

new class TemplateEngine extends Actor
    action: ->
        @on-topic \@templating.get, (msg) ~> 
            # backup the original configuration
            config-orig = JSON.stringify msg.data.config, null, 2

            data = 
                hal-use: []
                available-timers: [1, 3, 14]
                adc: 
                    isContinuous: null
                    driver: "ADCD1"         # ADC Driver
                    conf: "adcgrpcfg1"   # ADCConversionGroup struct
                    callback: "adcReadCallback1"
                    bufferName: "samples_buf1"
                    useGpt: no 
                    gpt:
                        driver:~ -> "GPTD#{@timer}"
                        timer: 1
                        conf: "gptCfg1"
                        callback: "gptCallback1"
                        freq: 100_000Hz 
                        waitTicksPerCall: null  # Declare how many ticks to wait per call       
                    CHSEL: []
                    sampling-rate: (rate) -> 
                        # Usage: 
                        #       
                        #       samplingRate("28 cycles") 
                        #       # => "ADC_SMPR_SMP_13P5"
                        #
                        # See os/hal/ports/STM32/LLD/ADCv1/hal_adc_lld.h -> Sampling rates
                        '''
                        #if defined(STM32F0XX) || defined(__DOXYGEN__)
                        #define ADC_SMPR_SMP_1P5        0U  /**< @brief 14 cycles conversion time   */
                        #define ADC_SMPR_SMP_7P5        1U  /**< @brief 21 cycles conversion time.  */
                        #define ADC_SMPR_SMP_13P5       2U  /**< @brief 28 cycles conversion time.  */
                        #define ADC_SMPR_SMP_28P5       3U  /**< @brief 41 cycles conversion time.  */
                        #define ADC_SMPR_SMP_41P5       4U  /**< @brief 54 cycles conversion time.  */
                        #define ADC_SMPR_SMP_55P5       5U  /**< @brief 68 cycles conversion time.  */
                        #define ADC_SMPR_SMP_71P5       6U  /**< @brief 84 cycles conversion time.  */
                        #define ADC_SMPR_SMP_239P5      7U  /**< @brief 252 cycles conversion time. */
                        '''.split '\n' 
                            .find (.match (new RegExp("(#{rate})", 'i')) ?.0) 
                            ?.match(/#define\s+(\w+)\s+/) .1

                    # See os/common/ext/ST/STM32F0xx/stm32f030x6.h
                    cfgr1:~ ->
                        res = []
                            ..push \ADC_CFGR1_CONT if @isContinuous
                            ..push \ADC_CFGR1_RES_12BIT

            try
                [mcu, pinout] = obj-to-pairs msg.data.config .0
                data.mcu = find (.stmGlob is mcu), supported-mcus # eg. 
            catch
                @send-response msg, {error: "Configuration seems to be empty."}
                return 

            response = {}

            b = new SignalBranch
            if data.mcu 
                s = b.add!
                dir = "./hw-template"
                templates = readdirSyncRecursive dir 
                err, res <~ @send-request "@datasheet.mcu-info", {id: mcu}
                if e=(err or res.data.error)
                    return s.go(e)
                datasheet = res.data.info
                # Object format: { "#pinNumber": "#pinName" } 
                # eg. {5: "PA5"}
                pin-names = datasheet.Pin 
                    |> map (._attributes) 
                    |> map (-> [it.Position, it.Name.replace /-.+/, '']) 
                    |> pairs-to-obj

                # get available GPIO ports 
                gpio-ports = datasheet.Pin
                    |> map (._attributes)
                    |> filter (.Type is "I/O")
                    |> map (.Name.1)
                    |> unique
                    |> map (x) -> "GPIO#{x}"

                # Generate parameters 
                data.GPIO_REGISTERS = <[ MODER OTYPER OSPEEDR PUPDR ODR AFRL AFRH ]> 
                # get the Alternate Function table
                try
                    mapping = read-lson "./af-mappings/#{data.mcu.chibiDef}.ls"
                catch
                    @send-response msg, {error: "No Alternate Function 
                        definition is found for #{data.mcu.chibiDef}. \n
                        See 'servers/stm/af-mappings/' for available MCU's."}
                    return 

                get-af = (pin, peripheral) !-> 
                    for af of o=mapping[pin] or {}
                        if o[af].match(peripheral) or peripheral.match(o[af])
                            return {
                                af-value: af.match /AF(\d)+/ .1
                                af-name: af 
                                define: "#{pin}_#{af}_#{peripheral}"
                            }
                    return undefined 

                try 
                    for pin, setup of pinout 
                        # setup = {peripheral, config}
                        setup
                            ..pin-name = pin-names[pin]
                            ..io-name = "#{pin-names[pin]}_#{setup.peripheral |> (-> it.type or it.id) |> (.toUpperCase!)}"
                            # Requires to setup Alternate Function
                            ..gpio-port = "GPIO#{pin-names[pin][SECOND_CHAR].toUpperCase!}"
                            ..gpio-no = pin-names[pin].substring 2 |> parse-int 

                        io = setup.io-name
                        AFRx = if setup.gpio-no <= 7 then "AFRL" else "AFRH"
                        af = null  # Alternate Function 
                        setup.registerMacro = 
                            # For MODER, see Reference Manual, 8.4
                            MODER: switch setup.peripheral.type 
                                | \din => 
                                    "PIN_MODE_INPUT(#io)"
                                | \dout => 
                                    "PIN_MODE_OUTPUT(#io)"
                                | <[ adcIn ]> =>
                                    data.hal-use.push "ADC"  
                                    if data.adc.conversion is \continuous 
                                        data.adc.isContinuous = yes 
                                    else if setup.config.conversion is \onDemand
                                        if setup.config.poll is \periodic
                                            data.adc.useGpt = yes 
                                            data.hal-use.push "GPT"
                                            freq = 1000 / setup.config.period # Hz
                                            data.adc.gpt.waitTicksPerCall = parse-int(data.adc.gpt.freq / freq)
                                    ch-num = setup.peripheral.stm.match /(\d+)/ .1 
                                    data.adc.CHSEL.push "ADC_CHSELR_CHSEL#{ch-num}"
                                    "PIN_MODE_ANALOG(#io)" 
                                | otherwise =>
                                    if get-af(setup.pin-name, setup.peripheral.stm)
                                        af = {name: that.define, value: that.af-value}
                                        data.[]define.push af
                                    if (type=setup.peripheral.type) in <[ adc pwm serial ]>
                                        data.hal-use.push type.toUpperCase!
                                    "PIN_MODE_ALTERNATE(#io)"

                            OTYPER: if setup.af
                                "PIN_OTYPE_PUSHPULL(#io)"

                            OSPEEDR: switch setup.peripheral.type 
                                | \swdio \pwm => 
                                    "PIN_OSPEED_40M(#io)"

                            PUPDR: switch setup.peripheral.type
                                | \swdio => "PIN_PUPDR_PULLUP(#io)"
                                | \swclk => "PIN_PUPDR_PULLDOWN(#io)"

                            # As stated in the Reference Manual, Alternate Functions are 
                            # documented in device datasheet. 
                            "#{AFRx}": if af then "PIN_AFIO_AF(#io, #{af.name})"
                catch
                    log e 
                    return s.go(e)

                data.pinout = pinout  

                # Default definitions must be generated for all GPIO ports 
                for gpio-ports
                    data.{}by-gpio[..] = []

                data.by-gpio <<<< group-by (.gpio-port), 
                    [{...setup} <<< {pin} for pin, setup of pinout]


                /*********************************************************
                data.pinout = {
                    "#pinNumber": 
                        peripheral: # Object
                            id: String, peripheral id, eg. "din" or "pwm-1.3", see webapps/main/stm/peripheral-defs.ls
                            name: String, Human readable name 
                            stm: String, STM type, eg. GPIO or TIM1_CH3N
                            type: String, peripheral type, eg. din for Digital Input

                        config: # Object, Configuration regarding to @peripheral.type 

                        pin-name: eg. PA1 

                        io-name: eg. PA1_PWM

                        gpio-port: eg. GPIOA

                        gpio-no: eg. 1 for PA1, 5 for PB5


                *********************************************************/
                try
                    # Compile the templates found in #templates directory
                    for template in templates
                        file = fs.readFileSync "#{dir}/#{template}", "utf-8"
                        compiled = ractive-compile file, data

                        # Replace Mustache variables in file/folder names
                        template = mustache-apply template, do
                            mcu: data.mcu.chibiDef

                        response[template] = compiled
                    response["config.json"] =  config-orig 
                    s.go!
                catch 
                    s.go(e)
            else 
                response["error"] = "Unknown MCU: #{mcu}"
            err <~ b.joined
            @log.log "Requested hardware definition."
            if err 
                response.error = err 
            @send-response msg, response


new DcsTcpClient port: config.dcs-port 
    .login {user: "templating", password: "1234"}
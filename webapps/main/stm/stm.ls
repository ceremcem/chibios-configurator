require! 'actors': {BrowserStorage}
require! 'prelude-ls': {
    values, map, compact, join, flatten, unique, 
    find, filter
}
require! 'components/router/tools': {scroll-to}

storage = new BrowserStorage "scene.stm"

Ractive.components['stm'] = Ractive.extend do
    template: require('./stm.pug')
    isolated: no 
    data: -> 
        mcuList: storage.get('mcuList') or []
        selected: storage.get('selected') or do
            mcu: null
            datasheet: null
            unavailable: "(not selected)"
            pins: []

        # the pin currently being configured.
        newSetting: 
            pin: null 
            peripheral: null 
            config: {}

        peripheralConfigs:
            din:
                * {id: \pullup, name: "Pull up"}
                * {id: \pulldown, name: "Pull down"}
                * {id: \float, name: "Float"}

            dout:
                * {id: \pushpull, name: "Push-pull"}
                * {id: \opencollector, name: "Open collector"}

        # Format: 
        #   STM_CODE(REGEX): [{TYPE: HUMAN_READABLE_NAME}, ...]
        replace-map:
            "GPIO"                      : 
                * din: "Digital Input" 
                * dout: "Digital Output"
            "TIM([0-9]+)_CH([0-9]+)$"   :
                * pwm: "PWM $1_$2"
                * timer: "Timer $1_$2"
            "ADC_IN([0-9]+)"            : adc-in: "Analog Input $1"
            "I2C([0-9]+)_SCL"           : i2c-clock: "I2C ($1) Clock"
            "I2C([0-9]+)_SDA"           : i2c-data: "I2C ($1) Data"
            "SYS_SWCLK"                 : swclk: "SWD Clock"
            "SYS_SWDIO"                 : swdio: "SWD Data"


        # Format: {"#mcuType": {"#pin": config}}
        configuration: {}

        getSignalName: -> 
            return unless it?
            it 
            |> map (.Name)
            |> join ', '
        getSignalMode: -> 
            return unless it?
            it 
            |> map (.IOModes) 
            |> compact
            |> map (.replace /,/g, ', ')
            |> join ','

    computed:
        availablePeripherals: -> 
            return @get \selected.pins
                |> map (.signal)
                |> flatten 
                |> compact 
                |> map (.Name)
                |> unique
        pinPeripherals: -> 
            return [] unless pin=@get \newSetting.pin
            peripherals = @get \selected.pins
                |> find (.Position is pin)
                |> (.signal)
                |> flatten 
                |> compact 
                |> map (.Name)
                |> unique

            #console.log "replace map: ", replace-map
            human-readable = []
            for stm-code in peripherals
                replaced = false
                for short, meaning of @get \replaceMap
                    short-r = new RegExp short
                    #console.log "Examining if #p matches with #short", short-r
                    if stm-code.match short-r
                        meaning = [] ++ meaning # ensure it is array 
                        for replacement-obj in meaning 
                            for type, replacement of replacement-obj
                                null # for object destruction 
                            x = stm-code.replace short-r, replacement
                            #console.log "type is: #type, replacement is: #x"
                            human-readable.push do 
                                id: x  
                                name: x
                                stm: stm-code
                                type: type   
                        replaced = true 
                        break 
                unless replaced 
                    human-readable.push do 
                        id: stm-code
                        name: stm-code
                    #console.log "no replacement found, appending original: #p"
            return human-readable

    on:
        init: -> 
            # Save the data before leaving the app
            window.addEventListener "beforeunload", ((e) ~> 
                storage
                    ..set \selected, @get \selected 
                    ..set \mcuList, @get \mcuList
                ), false

        lsMcu: (ctx) -> 
            return unless btn=ctx?component 
            btn.state \doing 
            err, res <~ btn.actor.send-request "@datasheet.ls.mcu", {}
            if err 
                btn.error "Something went wrong: #{err}" 
            else 
                btn.state \done...
                @set \mcuList, res.data.mcuList

        subFamilySelected: (ctx, item, progress) -> 
            return unless dd=ctx?component 
            @set \selected.mcu, item.id
            @set \selected.datasheet, null
            err, res <~ dd.actor.send-request "@datasheet.mcu-info", {id: item.id}
            if datasheet=res?.data?.info
                @set \selected.datasheet, datasheet
                @fire \refreshSelected
            progress (err or res?error)

        refreshSelected: (ctx) -> 
            @set \selected.pins, []
            for pin in @get('selected.datasheet').Pin
                {Name, Position, Type} = pin._attributes 
                if signal=pin.Signal
                    signal = signal 
                        |> values
                        |> map (._attributes)

                @push "selected.pins", {Name, Position, Type, signal}
            @sort 'selected.pins', (f, s) -> f.Position > s.Position 
            PNotify.success do 
                text: "Refreshed according to datasheet: #{@get('selected.mcu')}"

        pinSelected: (ctx) -> 
            return unless btn=ctx?component
            @set \newSetting, {} 
            @set \newSetting.pin, btn.get \pin 
            scroll-to 'assign-peripheral'

        configurePin: (ctx) -> 
            return unless btn=ctx?component
            pin-number = @get 'newSetting.pin'
            unless pin-number?
                return btn.error "Pin number is required."
            @set "configuration.#{@get 'selected.mcu'}", {
                "#{pin-number}":
                    peripheral: @get \newSetting.peripheralObj
                    config: @get \newSetting.config
                }, {+deep}

            btn.state \done...

        pinPeripheralSelected: (ctx, item, progress) -> 
            console.log "pinPeripheralSelected, item is: ", item 
            @set \newSetting.peripheralObj, item 
            progress!


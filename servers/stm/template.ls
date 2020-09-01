require! 'dcs': {DcsTcpClient, Actor, SignalBranch}
require! '../../config'
require! 'fs'
require! './ractive-template': {ractive-compile}
require! './readdir-sync-recursive': {readdirSyncRecursive}
require! './supported-mcus.json'
require! 'prelude-ls': {find, map, pairs-to-obj}

new class TemplateEngine extends Actor
    action: ->
        @on-topic \@templating.get, (msg) ~> 
            config-orig = JSON.stringify msg.data.config, null, 2
            data = {}
            for mcu, pinout of msg.data.config
                data["mcu"] = find (.stmGlob is mcu), supported-mcus
                data["pinout"] = pinout 

            response = {}

            b = new SignalBranch
            if data.mcu 
                s = b.add!
                dir = "./hw-template"
                templates = readdirSyncRecursive dir 
                err, res <~ @send-request "@datasheet.mcu-info", {id: mcu}
                if e=(err or res.error)
                    return s.go(e)

                # key: pin number (eg. 5), value: pin name (eg. PA5)
                pin-names = res.data.info.Pin 
                    |> map (._attributes) 
                    |> map (-> [it.Position, it.Name.replace /-.+/, '']) 
                    |> pairs-to-obj

                # Generate parameters 
                for pin, pinout of data.pinout 
                    pinout.pin-name = pin-names[pin]
                    pinout.io-name = "#{pin-names[pin]}_#{pinout.peripheral.type.to-upper-case!}"
                    # Requires to setup Alternate Function
                    pinout.af = pinout.peripheral.type not in <[ din dout ]> 
                    pinout.gpio-port = "GPIO" + pin-names[pin][1].to-upper-case!

                /*********************************************************
                data.pinout = {
                    pin-number: 
                        peripheral: # Object
                            id: String, peripheral id, eg. "din" or "pwm-1.3", see webapps/main/stm/peripheral-defs.ls
                            name: String, Human readable name 
                            stm: String, STM type, eg. GPIO
                            type: String, peripheral type, eg. din for Digital Input

                        config: # Object, Configuration regarding to @peripheral.type 

                        pin-name: eg. PA1 

                        io-name: eg. PA1_PWM

                        gpio-port: eg. GPIOA


                *********************************************************/
                
                # Compile the templates found in #templates directory
                for template in templates
                    file = fs.readFileSync "#{dir}/#{template}", "utf-8"
                    compiled = ractive-compile file, data
                    response[template] = compiled
                response["config.json"] =  config-orig 
                s.go!
            else 
                response["error"] = "Unknown MCU: #{mcu}"
            <~ b.joined
            @log.log "Requested hardware definition."
            @send-response msg, response


new DcsTcpClient port: config.dcs-port 
    .login {user: "templating", password: "1234"}
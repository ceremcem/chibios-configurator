require! 'actors': {BrowserStorage}
require! 'prelude-ls': {
    values, map, compact, join, flatten, unique, 
    find, filter
}
require! 'components/router/tools': {scroll-to}
require! './peripheral-defs': {replace-map, peripheralConfigs}
require! 'aea': {merge, create-download}
require! 'jszip': JSZip
require! 'dcs/browser': {Signal}

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
            board-name: "my-board"

        # the pin currently being configured.
        newSetting: 
            pin: null 
            peripheral: null 
            config: {}


        replace-map: replace-map
        peripheralConfigs: peripheralConfigs

        # Format: {"#mcuType": {"#pin": config}}
        configuration: storage.get \configuration 

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

        readableJSON: (obj) -> 
            JSON.stringify(obj)
                .replace(/:/g, ': ')
                .replace(/[{}"]/g, '')
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

            # Generate possible peripherals
            human-readable = []
            for stm-code in peripherals
                replaced = false
                for short, meaning of @get \replaceMap
                    # meaning: {id, name}
                    short-r = new RegExp short
                    #console.log "Examining if #p matches with #short", short-r
                    if stm-code.match short-r
                        meaning = [] ++ meaning # ensure it is array 
                        for replacement-obj in meaning 
                            for type, replacement of replacement-obj
                                null # for object destruction 
                            id = stm-code.replace short-r, replacement.id
                            name = stm-code.replace short-r, replacement.name
                            #console.log "type is: #type, replacement is: #x"
                            human-readable.push do 
                                id: id
                                name: name
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
        complete: -> 
            # Save the data before leaving the app
            window.addEventListener "beforeunload", ((e) ~> 
                @fire \saveProject
            ), false

            @observe "configuration", ~> 
                @fire \saveProject

        saveProject: (ctx) -> 
            console.log "Project saved, #{Date.now!}"
            storage
                ..set \selected, @get \selected 
                ..set \mcuList, @get \mcuList
                ..set \configuration, @get \configuration             

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
            s = new Signal
            if dd.actor._last_login is 0
                msg <~ dd.actor.once-topic 'app.dcs.connect'
                s.go!
            else
                s.go!
            <~ s.wait
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
            pin = btn.get \pin 
            _config = (@get "configuration.#{@get 'selected.mcu'}")?[pin]
            if _config?
                config = JSON.parse JSON.stringify _config 
                config.pin = pin 
                console.log "found in configuration, loading config: ", config 
            else 
                config = {pin}
            @set \newSetting, config 
            @set "overrideAllowed", false
            scroll-to 'assign-peripheral'

        configurePin: (ctx) -> 
            return unless btn=ctx?component
            pin-number = @get 'newSetting.pin'
            unless pin-number?
                return btn.error "Pin number is required."

            new-conf = 
                "#{pin-number}": 
                    peripheral: @get \newSetting.peripheral
                    config: @get \newSetting.config

            #console.log "New config is set:", new-conf
            @set "configuration.#{@get 'selected.mcu'}", new-conf, {+deep}            
            @set "overrideAllowed", false
            btn.state \done...

        deletePinSetting: (ctx) -> 
            return unless btn=ctx?component
            pin-number = @get 'newSetting.pin'
            unless pin-number?
                return btn.error "Pin number is required."
            answer, data <~ btn.yesno do 
                closable: yes 
                title: "Are you sure?"
                template: """
                    <div class='ui p'>
                        Delete Pin-#{pin-number}?
                    </div>
                    """
            if answer is \yes 
                @delete "configuration.#{@get 'selected.mcu'}", "#{pin-number}"
                @fire \closeEdited
                PNotify.success do 
                    text: "Removed Pin-#{pin-number}"
                    addClass: "nonblock"                
            else 
                PNotify.info do 
                    text: "Not removing Pin-#{pin-number}"
                    addClass: "nonblock"

        pinPeripheralSelected: (ctx, item, progress) -> 
            #console.log "pinPeripheralSelected, item is: ", item 
            @set \newSetting.peripheral, item
            progress!

        downloadHardware: (ctx) -> 
            return unless btn=ctx?component 
            btn.state \doing 
            config = @get('configuration')
            err, res <~ btn.actor.send-request "@templating.get", {config}
            if e=(err or res.data.error) 
                btn.error e
            else 
                console.log res.data
                zip = new JSZip
                for name, content of res.data 
                    zip.file name, content 
                content <~ zip.generate-async {type: \blob} .then
                filename = "#{@get 'selected.boardName' .replace ' ', '-'}.zip"
                create-download filename, content, "application/zip"
                btn.state \done...

        closeEdited: (ctx) -> 
            @set \newSetting, {}


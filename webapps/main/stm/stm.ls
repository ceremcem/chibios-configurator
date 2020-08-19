require! 'actors': {BrowserStorage}
require! 'prelude-ls': {values, map, compact, join}

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
        peripherals: -> 
            <[ SPI USART I2C PWM Analog Input Output ]>

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
            @set \newSetting.pin, btn.get \pin 

        configurePin: (ctx) -> 
            return unless btn=ctx?component
            @set "configuration.#{@get 'selected.mcu'}", {
                "#{@get 'newSetting.pin'}":
                    peripheral: @get \newSetting.peripheral
            }, {+deep}

            btn.state \done...

        
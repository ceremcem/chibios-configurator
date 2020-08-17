require! 'actors': {BrowserStorage}

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

    on:
        init: -> 
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
            @set \selected.datasheet, res?.data
            progress (err or res.error)

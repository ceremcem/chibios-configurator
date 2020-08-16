Ractive.components['stm'] = Ractive.extend do
    template: require('./stm.pug')
    isolated: no 
    data: -> 
        mcuList: []
    on:
        lsMcu: (ctx) -> 
            btn = ctx?component 
            return unless btn?
            btn.state \doing 
            err, res <~ btn.actor.send-request "@datasheet.ls.mcu", {+list}
            if err 
                btn.error "Something went wrong: #{err}" 
            else 
                btn.state \done
                @set \mcuList, res.data.mcuList
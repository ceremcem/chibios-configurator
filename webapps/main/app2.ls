try
    require! 'aea/defaults'
    require! 'components'
    require! './stm/stm'
    new Ractive do
        el: \body
        template: require('./app.pug') 
        data:
            appVersion: require('app-version.json')
        on:
            dcsLive: ->                    
                info = new PNotify.notice do
                    text: "Fetching dependencies..."
                    hide: no
                    addClass: 'nonblock'

                start = Date.now!
                <~ getDep "js/app3.js"
                info.close!
                elapsed = (Date.now! - start) / 1000
                new PNotify.info do
                    text: "Dependencies are loaded in #{oneDecimal elapsed} s"
                    addClass: 'nonblock'                

                # send signal to Async Synchronizers
                @set "@shared.deps", {_all: yes}, {+deep}
catch
    loadingError (e.stack or e)

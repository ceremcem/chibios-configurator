require! 'app/tools'
try
    require! 'aea/defaults'
    require! 'components'
    #require! 'aea/defaults2'
    #require! 'components/heavy-components'

    new Ractive do
        el: \body
        template: require('./app.pug')
        data:
            appVersion: require('app-version.json')
        on:
            complete: -> 
                # send signal to Async Synchronizers
                @set "@shared.deps", {_all: yes}, {+deep}
catch
    loadingError (e.stack or e)

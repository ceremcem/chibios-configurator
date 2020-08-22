require! 'dcs': {DcsTcpClient, Actor}
require! '../config'
require! 'fs': {readFileSync}
require! 'ractive': Ractive
Ractive.DEBUG = off

ractive-compile = (template="", data={}) -> 
        instance = new Ractive do 
            template: "<pre>" + template + "</pre>"
            data: data 
        return instance.toHTML!.slice "<pre>".length, - "</pre>".length


new class TemplateEngine extends Actor
    action: ->
        @on-topic \@templating.get, (msg) ~> 
            halconf = readFileSync "./hw-template/halconf.h"
            compiled = ractive-compile halconf.to-string('utf-8'), {hello: "wooo"}
            @log.log "Requested hardware definition."
            @send-response msg, {"halconf.h": compiled}


new DcsTcpClient port: config.dcs-port 
    .login {user: "templating", password: "1234"}

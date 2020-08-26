require! 'dcs': {DcsTcpClient, Actor}
require! '../../config'
require! 'fs'
require! 'path'
require! 'ractive': Ractive
Ractive.DEBUG = off


function readdirSyncRecursive (dir, files=[], {sub}={})
    f = fs.readdirSync dir
    for file in f 
        if fs.statSync "#{dir}/#{file}" .isDirectory!
            files = readdirSyncRecursive "#{dir}/#{file}", files, {sub: path.join (sub or ''), file}
        else 
            files.push path.join (sub or ''), file 
    return files 


ractive-compile = (template="", data={}) -> 
        instance = new Ractive do 
            template: (Ractive.parse template, {+textOnlyMode, +preserveWhitespace})
            data: data 
        return instance.toHTML!

new class TemplateEngine extends Actor
    action: ->
        @on-topic \@templating.get, (msg) ~> 
            data = {}
            for mcu, pinout of msg.data.config
                data["mcu"] = mcu 
                data["pinout"] = pinout 

            dir = "./hw-template"
            templates = readdirSyncRecursive dir 
            res = {}
            for template in templates
                file = fs.readFileSync "#{dir}/#{template}", "utf-8"
                compiled = ractive-compile file, data
                res[template] = compiled
            @log.log "Requested hardware definition."
            @send-response msg, res 


new DcsTcpClient port: config.dcs-port 
    .login {user: "templating", password: "1234"}
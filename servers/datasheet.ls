require! 'dcs': {DcsTcpClient, Actor}
require! '../config'
require! 'xml-js': convert
require! 'fs': {readFileSync, readdirSync}
require! 'prelude-ls': {map, flatten, unique, find, filter}
require! 'fancy-log': log 

read-xml = (file) -> 
    convert.xml2js readFileSync(file, "utf8"), 
        {+compact, +ignoreComment}

new class Datasheet extends Actor
    action: ->
        #families = read-xml "./stm-db/mcu/families.xml"
        @on-topic \@datasheet.ls.mcu, (msg) ~>
            log "list mcu requested"
            mcu-list = readdirSync './stm-db/mcu'
                .filter (.startsWith \STM32)
                .map (.replace /\..+$/, '') # remove extensions
            log "...returning #{mcu-list.length} results."
            @send-response msg, {mcu-list}

        @on-topic "@datasheet.mcu-info", (msg) ~> 
            log "Mcu info requested: #{msg.data.id}"
            error = false 
            mcu-info = null 
            try 
                mcu-info = (read-xml "./stm-db/mcu/#{msg.data.id}.xml").Mcu
            catch 
                error = e  
            @send-response msg, {info: mcu-info, error}

new DcsTcpClient port: config.dcs-port 
    .login {user: "datasheet", password: "1234"}

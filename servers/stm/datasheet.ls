require! 'dcs': {DcsTcpClient, Actor}
require! '../../config'
require! 'fs'
require! 'prelude-ls': {map, flatten, unique, find, filter}
require! 'fancy-log': log 
require! './read-xml': {read-xml}

new class Datasheet extends Actor
    action: ->
        families = read-xml "./stm-db/mcu/families.xml" .Families.Family       
        @on-topic \@datasheet.ls.mcu, (msg) ~>
            log "list mcu requested"
            mcu-list = fs.readdirSync './stm-db/mcu'
                .filter (.startsWith \STM32)
                .map (.replace /\..+$/, '') # remove extensions
            log "...returning #{mcu-list.length} results."
            @send-response msg, {mcu-list}

        @on-topic "@datasheet.mcu-info", (msg) ~> 
            log "Mcu info requested: #{msg.data.id}"
            error = ""
            mcu-info = null 
            try 
                mcu-info = (read-xml "./stm-db/mcu/#{msg.data.id}.xml").Mcu
            catch 
                error += e  

            try
                family = null 
                :found for families
                    for ..SubFamily
                        for ..Mcu 
                            if .._attributes.Name is msg.data.id
                                family = .. 
                                break found
            catch 
                error += e 

            @send-response msg, {info: mcu-info, error, family}



new DcsTcpClient port: config.dcs-port 
    .login {user: "datasheet", password: "1234"}

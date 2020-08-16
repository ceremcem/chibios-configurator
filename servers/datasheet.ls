require! 'dcs': {DcsTcpClient, Actor}
require! '../config'
require! 'xml-js': convert
require! 'fs': {readFileSync}
require! 'prelude-ls': {map, flatten, unique}

read-xml = (file) -> 
    convert.xml2js readFileSync(file, "utf8"), 
        {+compact, +ignoreComment}

new class Datasheet extends Actor
    action: ->
        @on-topic \@datasheet.ls.mcu, (msg) ~>
            console.log "list mcu requested"
            families = read-xml "./stm-db/mcu/families.xml"
            mcu-list = families.Families.Family 
                |> map (.SubFamily)
                |> flatten
                |> map (.Mcu) 
                |> flatten 
                |> map (._attributes)
                |> map (.Name)
                |> unique
            @send-response msg, {mcu-list}

new DcsTcpClient port: config.dcs-port 
    .login {user: "datasheet", password: "1234"}

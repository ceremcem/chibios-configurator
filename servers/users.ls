require! '../config': {default-password}
require! 'dcs/src/auth-helpers': {hash-passwd}

export initial-users =
    'auth-db':
        passwd-hash: hash-passwd default-password
        routes:
            \@db-proxy.**

if require.main is module
    users =
        'public':
            passwd-hash: hash-passwd "public"
            routes:
                \@datasheet.**
            permissions:
                'something'
                'something-else'

        'datasheet':
            passwd-hash: hash-passwd "1234"
            permissions:
                \datasheet.**


    require! 'dcs': {Actor, DcsTcpClient, sleep}
    require! '../config': {dcs-port}

    new DcsTcpClient port: dcs-port
        .login do
            user: "auth-db"
            password: default-password

    new class Users extends Actor
        ->
            super "Users"
            @subscribe '@auth-db'
            process-users = ~>
                @log.log "Sending users..."
                err, msg <~ @send-request {to: '@auth-db'}, users
                if err
                    @log.err "Failed to send users: ", err
                else
                    @log.success "Users sent:", msg.data
            @on-every-login ~>
                process-users!
#!/usr/bin/env lsc 
require! \path
require! \express
require! 'dcs/services/dcs-proxy': {AuthDB, DcsSocketIOServer, DcsTcpServer}
require! 'dcs': {Actor}

# configuration
require! '../config': {webserver-port, dcs-port}
require! 'yargs': {argv}

if argv.development
    console.log "Using development site-root."
    site-root = "../scada.js/build/main"
else if argv.production
    console.log "Using production site-root."
    site-root = "../scada.js/release/main"
else
    console.error "Use a --development or --production argument."
    process.exit 1

# Create a webserver
app = express!
http = require \http .Server app
app.use "/", express.static path.resolve site-root
http.listen webserver-port, "0.0.0.0", ->
    console.log "webserver is listening on *:#{webserver-port}"

# -----------------------------------------------------------------------------
# DCS section
# -----------------------------------------------------------------------------
# Create auth db
db = new AuthDB (require './users' .initial-users)
# use ..update(users) to add more users in the runtime

new class Users extends Actor
    action: ->
        @on-topic \@auth-db, (msg) ~>
            db.update msg.data
            @send-response msg, {+ok}

# Create a SocketIO bridge
new DcsSocketIOServer http, {db}

# Create a TCP DCS Service
new DcsTcpServer {port: dcs-port, db}


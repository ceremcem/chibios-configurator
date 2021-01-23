require! 'dcs': {DcsTcpClient, Actor, SignalBranch}
require! '../../../config'
require! '../lib': {read-lson}
require! fs
require! shelljs: {
    echo, mkdir, cd, cat, ShellString, ls, exec, rm
    }:sh
require! path
require! 'prelude-ls': {keys, map, unique, filter}

new class Tester extends Actor
    action: ->
        @on-every-login ~> 
            tests = ls './cases'
            cd './cases'
            i = 0
            e <~ :lo(op) ~>
                dir = tests[i]
                echo "Running test: ", dir 
                config = read-lson "#{dir}/config.json"

                # request the templates regarding to the config.json
                err, res <~ @send-request "@templating.get", {config}
                if e=(err or res.data.error) 
                    echo "something went wrong: ", e 
                else 
                    if sh.test '-d', observed="#{dir}/observed"
                        rm '-r', observed
                    mkdir observed
                    cd observed 
                    # create necessary directories
                    keys res.data 
                        |> filter (.includes '/')
                        |> map path.dirname 
                        |> unique 
                        |> mkdir 
                    for filename, content of res.data 
                        ShellString content .to filename

                    cd '..'

                    # compare with "expected"
                    res = exec "/usr/bin/diff -rB ./expected ./observed" , {+silent}
                    if res.code isnt 0
                        return op [dir, res.stderr]
                return op! if ++i is tests.length 
                lo(op)
            if e
                echo "Tests didn't go well :|"
                echo "Message:", ...e 
                return 
            echo "Tests ended."


new DcsTcpClient port: config.dcs-port 
    .login {user: "templating", password: "1234"}
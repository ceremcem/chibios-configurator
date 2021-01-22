require! 'ractive': Ractive
Ractive.DEBUG = off
require! 'aea/html-encode-decode': {html-decode}

compile = (template="", data={}) -> 
    instance = new Ractive do 
        template: (Ractive.parse template, {+textOnlyMode, +preserveWhitespace})
        data: data 
    return html-decode instance.toHTML!

/*
compile = (template="", data={}) -> 
    [prefix, postfix] = <[ <pre> </pre> ]>
    instance = new Ractive do 
        template: prefix + template + postfix 
        data: data 
    return instance.toHTML!.slice(prefix.length, -postfix.length)
*/
export ractive-compile = compile
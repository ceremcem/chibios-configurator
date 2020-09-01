require! 'ractive': Ractive
Ractive.DEBUG = off

compile = (template="", data={}) -> 
    instance = new Ractive do 
        template: (Ractive.parse template, {+textOnlyMode, +preserveWhitespace})
        data: data 
    return instance.toHTML!

/*
compile2 = (template="", data={}) -> 
    [prefix, postfix] = <[ <pre> </pre> ]>
    instance = new Ractive do 
        template: prefix + template + postfix 
        data: data 
    return instance.toHTML!.slice(prefix.length, -postfix.length)
*/

export ractive-compile = compile
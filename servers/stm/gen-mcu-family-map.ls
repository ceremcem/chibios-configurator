require! 'fs'
require! 'prelude-ls': {sort-by, values, flatten}

chibi-defs = fs.readFileSync './chibi-stm-headers.txt', "utf-8" 
    .split /\r?\n/ # not a big file, split is okay.
chibi-family = []
for def in chibi-defs when def 
    regex-def = def 
        .replace /x$/g, '.+'
        .replace /x/g, '.'
        .replace /([0-9]+)_([0-9]+)/g, "($1|$2)"
        .replace /$/, ".*$"

    chibi-family.push do
        definition: def 
        regex: r=(new RegExp regex-def)
        self-match: [.. for chibi-defs when ..match r]

chibi-family = chibi-family |> sort-by (.self-match.length)

stm-mcus = fs.readFileSync './stm-mcu-types.txt', "utf-8" 
    .split /\r?\n/ # not a big file, split is okay.

stm-mcus-expanded = {}
for mcu in stm-mcus when mcu
    if (m=mcu.match /\((.+)\)/)
        # regex-like syntax
        variations = m.1.split '-'
        [begin, end] = mcu.split m.0
        for variations 
            stm-mcus-expanded[][mcu].push "#{begin}#{..}#{end}"
    else 
        stm-mcus-expanded[][mcu].push mcu 


#console.log stm-mcus-expanded

match-list = []
for stm-code, expanded of stm-mcus-expanded
    for code in expanded 
        match-found = no 
        for chibi in chibi-family when code.match chibi.regex
            #console.log "#{code} matched with #{chibi.definition}"
            match-list.push do
                chibi-def: chibi.definition
                mcu-code: code 
                stm-glob: stm-code 
            chibi.matched = yes 
            match-found = yes 
            break
        unless match-found 
            #console.error "#{code} has no ChibiOS support."
            null

for chibi-family when not ..matched
    console.error "#{..definition} \t does not match any known STM MCU type."

try
    fs.writeFileSync "supported-mcus.json", """
        export supported-mcus = #{JSON.stringify match-list, null, 2}
        """
    console.log "Supported MCU's are written to file."
catch 
    console.error e 

/* Conflict at the beginning: 

Error: /STM32F10X_MD/ has multiple match:  STM32F10X_MD, STM32F10X_MD_VL
Error: /STM32F401../ has multiple match:  STM32F401xC, STM32F401xE, STM32F401xx
Error: /STM32F410../ has multiple match:  STM32F410Cx, STM32F410Rx, STM32F410Tx, STM32F410xx
Error: /STM32F411../ has multiple match:  STM32F411xE, STM32F411xx
Error: /STM32F412../ has multiple match:  STM32F412Cx, STM32F412Rx, STM32F412Vx, STM32F412xx, STM32F412Zx
Error: /STM32F427../ has multiple match:  STM32F427_437xx, STM32F427xx
Error: /STM32F429../ has multiple match:  STM32F429_439xx, STM32F429xx
Error: /STM32F469../ has multiple match:  STM32F469_479xx, STM32F469xx
Error: /STM32L100.B/ has multiple match:  STM32L100xB, STM32L100xBA
Error: /STM32L151.B/ has multiple match:  STM32L151xB, STM32L151xBA
Error: /STM32L151.C/ has multiple match:  STM32L151xC, STM32L151xCA
Error: /STM32L151.D/ has multiple match:  STM32L151xD, STM32L151xDX
Error: /STM32L152.B/ has multiple match:  STM32L152xB, STM32L152xBA
Error: /STM32L152.C/ has multiple match:  STM32L152xC, STM32L152xCA
Error: /STM32L162.C/ has multiple match:  STM32L162xC, STM32L162xCA
Error: /STM32L162.D/ has multiple match:  STM32L162xD, STM32L162xDX

*/ 
#console.log chibi-family
require! 'fs'
require! 'livescript'

export read-lson = (filename) -> 
    file = fs.readFileSync filename, "utf8"
    json = livescript.compile file, {+json}
    JSON.parse json 

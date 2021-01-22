require! 'xml-js': convert
require! 'fs'

export read-xml = (file) -> 
    convert.xml2js fs.readFileSync(file, "utf8"), 
        {+compact, +ignoreComment}
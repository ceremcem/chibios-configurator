export mustache-apply = (str, data) -> 
    for k, v of data
        str = str.replace (new RegExp "{{\s*#{k}\s*}}", 'gi'), v
    return str 

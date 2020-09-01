require! <[ fs path ]>

export function readdirSyncRecursive (dir, files=[], {sub}={})
    f = fs.readdirSync dir
    for file in f 
        if fs.statSync "#{dir}/#{file}" .isDirectory!
            files = readdirSyncRecursive "#{dir}/#{file}", files, {sub: path.join (sub or ''), file}
        else 
            files.push path.join (sub or ''), file 
    return files 

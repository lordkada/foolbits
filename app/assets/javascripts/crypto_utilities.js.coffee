###
    (c) 2013 by Lord Kada
    The forge project (https://github.com/digitalbazaar/forge) uses strings to store data (such as keys or encrypted data) while 
    the XMLHttpRequest/arraybuffer uses the "typed arrays" way
###
salt = "this is blood of soul"

generate_key = (passphrase) ->
    key = forge.pkcs5.pbkdf2 passphrase, salt, 10000, 32

encrypt_text = (text, publicKey) ->
    key = forge.random.getBytesSync 32
    iv = forge.random.getBytesSync 16
    cipher = forge.aes.createEncryptionCipher key, 'CBC'
    cipher.start iv    
    cipher.update forge.util.createBuffer text
    cipher.finish()
    encrypted = cipher.output.data
    encrypted_key = publicKey.encrypt key, 'RSA-OAEP'
    #console.log "encrypted_key: #{encrypted_key}"
    #console.log "iv: #{iv}"
    #console.log "encrypted: #{encrypted}"
    forge.util.encode64(encrypted_key + iv + encrypted)
     
decrypt_text = (encrypted_base_64_text, privateKey) ->
    encrypted_text = forge.util.decode64 encrypted_base_64_text
    encrypted_key = encrypted_text.slice(0,267)
    iv = encrypted_text.slice(267,283)
    encrypted = encrypted_text.slice(283)
    #console.log "encrypted_key: #{encrypted_key}"
    #console.log "iv: #{iv}"
    #console.log "encrypted: #{encrypted}"
    key = privateKey.decrypt encrypted_key, 'RSA-OAEP'
    cipher = forge.aes.createDecryptionCipher key, 'CBC'
    cipher.start iv
    cipher.update forge.util.createBuffer encrypted
    cipher.finish()
    cipher.output.data

encrypt = (url, key, callback) ->
    if url? && key?
        try
            xhr = new XMLHttpRequest()
            xhr.open 'GET', url, true
            xhr.responseType = 'arraybuffer'
            xhr.onreadystatechange = (e) ->
                if xhr.readyState is 4 
                    try               
                        cipher = forge.aes.createEncryptionCipher key, 'CBC'
                        iv = forge.random.getBytesSync 16
                        cipher.start iv

                        to_encrypt = uint8array_to_string(new Uint8Array(xhr.response))
                        cipher.update forge.util.createBuffer(to_encrypt)
                        cipher.finish()
                        
                        encrypted = cipher.output.data
                        blob = new Blob([string_to_uint8array(iv), string_to_uint8array(encrypted)], {type: "text/plain"})
                        encrypted_url = window.URL.createObjectURL(blob) 

                        callback null, encrypted_url
                    catch err
                        callback err
            xhr.send()
        catch err
            callback err
    else
        console.log "should provide a url and a passphrase!"

decrypt = (url, key, callback) ->
    xhr = new XMLHttpRequest()
    xhr.open 'GET', url, true
    xhr.responseType = 'arraybuffer'
    xhr.onreadystatechange = (e) ->
        if xhr.readyState is 4
            try
                load = uint8array_to_string(new Uint8Array(xhr.response))
                iv = load.slice(0,16)
                cipher = forge.aes.createDecryptionCipher key, 'CBC'
                cipher.start iv
                encrypted = load.slice(16)
                cipher.update forge.util.createBuffer(encrypted)
                cipher.finish()

                callback null, new Blob([string_to_uint8array(cipher.output.data)], {type: 'binary/octet-stream'})
            catch err
                callback err
    xhr.send()

string_to_uint8array = (string) ->
    ui8arr = new Uint8Array(string.length)
    for i in [0..string.length-1]
        ui8arr[i] = string.charCodeAt(i)
    ui8arr

uint8array_to_string = (uint8array) ->
    str = ""
    for i in [0..uint8array.length-1]
        str += String.fromCharCode(uint8array[i])
    str

uint8array_to_hex = (array) ->
    (for i in [0..array.length-1]
        array[i].toString(16)
    ).join("")

buffer_to_uint8array = (buffer) ->
    buffer.read = 0
    ui8arr = new Uint8Array(buffer.length())
    for i in [0..buffer.length()-1]
        ui8arr[i] = buffer.getInt(1)
    ui8arr

all_tests = () ->
    run test
    run test2
    run test_crypt

run = (test) ->
    test (res, msg) ->
        if res
            console.log "ok"
        else
            console.log "failed: #{msg}"

test = (callback) ->
    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(uint8array_to_string(string_to_uint8array(a)))
        return callback false, "Error: #{h1} -- NOT EQUAL -> #{h2}" if h1 isnt h2
    callback true

test2 = (callback) ->
    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(uint8array_to_string(buffer_to_uint8array(forge.util.createBuffer(a))))
        return callback false, "Error: #{h1} -- NOT EQUAL -> #{h2}" if h1 isnt h2
    callback true

test_crypt = (callback) ->
    key = generate_key "test" 
    encrypt "http://www.opinionage.com", key, (err,out) ->
        return callback err if err?    
        decrypt out, key, (err, out) ->
            callback !err? and out?

window.crypto_utils =
    encrypt_text: encrypt_text
    decrypt_text: decrypt_text
    string_to_uint8array: string_to_uint8array
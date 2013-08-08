###
    (c) 2013 by Lord Kada
    The forge project (https://github.com/digitalbazaar/forge) uses strings to store data (such as keys or encrypted data) while 
    the XMLHttpRequest to access binary files prefer the "typed arrays" way
###
salt = "this is blood of soul"

generate_key = (passphrase) ->
    key = forge.pkcs5.pbkdf2 passphrase, salt, 10000, 256

encrypt = (url, key) ->
    if url? && key?
        xhr = new XMLHttpRequest()
        xhr.open 'GET', url, true
        xhr.responseType = 'arraybuffer'
        xhr.onreadystatechange = (e) ->
            if xhr.readyState is 4                
                cipher = forge.aes.createEncryptionCipher key, 'CBC'
                iv = forge.random.getBytesSync 16
                cipher.start iv

                to_encrypt = uint8array_to_string(new Uint8Array(xhr.response))
                cipher.update forge.util.createBuffer(to_encrypt)
                cipher.finish()
                
                encrypted = cipher.output.data
                blob = new Blob([string_to_uint8array(iv), string_to_uint8array(encrypted)], {type: "text/plain"})
                encrypted_url = window.URL.createObjectURL(blob) 

                console.log "encrypted url is: #{encrypted_url}"
        xhr.send()
    else
        console.log "should provide a url and a passphrase!"

decrypt = (url, key) ->
    xhr = new XMLHttpRequest()
    xhr.open 'GET', url, true
    xhr.responseType = 'arraybuffer'
    xhr.onreadystatechange = (e) ->
        if xhr.readyState is 4
            load = uint8array_to_string(new Uint8Array(xhr.response))
            
            iv = load.slice(0,16)
            console.log "iv hex: #{forge.util.bytesToHex(iv)}"
            cipher = forge.aes.createDecryptionCipher key, 'CBC'
            cipher.start iv
            encrypted = load.slice(16)
            console.log "encrypted length: #{encrypted.length}"
            cipher.update forge.util.createBuffer(encrypted)
            cipher.finish()

            window.open window.URL.createObjectURL new Blob([string_to_uint8array(cipher.output.data)], {type: 'binary/octet-stream'})
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

run = (test) ->
    if test()
        console.log "ok"
    else
        console.log "failed"

test = () ->
    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(uint8array_to_string(string_to_uint8array(a)))
        if h1 isnt h2
            console.log "Error: #{h1} -- NOT EQUAL -> #{h2}" 
            return false
    true

test2 = () ->
    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(uint8array_to_string(buffer_to_uint8array(forge.util.createBuffer(a))))
        if h1 isnt h2
            console.log "Error: #{h1} -- NOT EQUAL -> #{h2}" 
            return false
    true

window.generate_key = generate_key
window.encrypt = encrypt
window.decrypt = decrypt

window.all_tests = all_tests
window.uint8array_to_string = uint8array_to_string
window.buffer_to_uint8array = buffer_to_uint8array
window.string_to_uint8array = string_to_uint8array
window.uint8array_to_hex = uint8array_to_hex
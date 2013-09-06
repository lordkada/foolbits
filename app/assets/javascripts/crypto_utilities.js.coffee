###
    (c) 2013 by Lord Kada
    The "forge" project (https://github.com/digitalbazaar/forge) uses strings to store data (such as keys or encrypted data) while 
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
    forge.util.encode64(encrypted_key + iv + encrypted)
     
decrypt_text = (encrypted_base_64_text, privateKey) ->
    encrypted_text = forge.util.decode64 encrypted_base_64_text
    encrypted_key = encrypted_text.slice(0,267)
    iv = encrypted_text.slice(267,283)
    encrypted = encrypted_text.slice(283)
    key = privateKey.decrypt encrypted_key, 'RSA-OAEP'
    cipher = forge.aes.createDecryptionCipher key, 'CBC'
    cipher.start iv
    cipher.update forge.util.createBuffer encrypted
    cipher.finish()
    cipher.output.data

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

window.crypto_utils =
    generate_key: generate_key
    encrypt_text: encrypt_text
    decrypt_text: decrypt_text
    string_to_uint8array: string_to_uint8array
    uint8array_to_string: uint8array_to_string
    uint8array_to_hex: uint8array_to_hex
    buffer_to_uint8array: buffer_to_uint8array
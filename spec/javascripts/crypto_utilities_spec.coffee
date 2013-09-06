describe "Crypto utilities", () ->

  it "will check string_to_uint8array and uint8array_to_string reflexivity", () ->

    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(crypto_utils.uint8array_to_string(crypto_utils.string_to_uint8array(a)))
        expect(h1).to.be(h2)

  it "will check hex -> buffer -> uint8array -> string -> hex", () ->
    for i in [0..999]
        a = forge.random.getBytesSync 16
        h1 = forge.util.bytesToHex a
        h2 = forge.util.bytesToHex(crypto_utils.uint8array_to_string(crypto_utils.buffer_to_uint8array(forge.util.createBuffer(a))))
        expect(h1).to.be(h2)

  it "will check if text -> encrypt_text -> decrypt_text -> text", (done) ->
    @timeout 0
    test_string = "http://www.opinionage.com"
    keypair = forge.rsa.generateKeyPair {bits: 2136, e: 0x10001}
    processed_string = crypto_utils.decrypt_text( crypto_utils.encrypt_text( test_string, keypair.publicKey), keypair.privateKey )  
    expect(processed_string).to.be(test_string)
    done()
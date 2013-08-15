init = (selector) ->

    passphrase = null
    keypair = null
    encrypted_key = null

    step1_element = $(".step1")
    step2_element = $(".step2")

    input_element = $(selector).find("input")
    progress_bar = $(selector).find(".progress .bar")
    status = $(selector).find(".progress div.status")

    ok_button_element = $(selector).find("[data-id='ok-passphrase']")

    input_element.keypress () ->
        passphrase = input_element.val()
        strength = PasswordStrength.test(null, passphrase)
        progress_bar.css "width", "#{strength.score}%"
        status.html strength.status
        ok_button_element.prop "disabled", false if strength.score > 30

    ok_button_element.click () ->
        passphrase = input_element.val()
        step1_element.animate {height: 0}
        step2_element.fadeIn () ->
            keypair = forge.rsa.generateKeyPair {bits: 2136, e: 0x10001}

            encrypted_key = forge.pki.encryptRsaPrivateKey keypair.privateKey, passphrase
            step2_element.append("<p>Ok, done...!<p> '#{passphrase}'")
            setTimeout () ->
                
                step2_element.append("<p>Updating your profile....<p>")
                $.post 'keypair', 
                    public_key: forge.pki.publicKeyToPem(keypair.publicKey).toString()
                    private_key: encrypted_key.toString()
                , (success) ->
                    if success.status is "ok"
                        step2_element.append("<p>Great, your setup is complete now! Redirecting to your vault!<p>")
                        setTimeout () ->
                            location.reload()
                        , 3000

                    else
                        step2_element.append("<div class='alert'>I'm sorry, but something went wrong... try later!</div>")

            , 2000

window.setup = init
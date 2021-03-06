init = (selector) ->

    passphrase = null
    retype = null
    keypair = null
    encrypted_key = null
    strength = 0

    step1_element = $(".step1")
    step2_element = $(".step2")

    input_element = $(selector).find("[data-id='passphrase']")
    retype_element = $(selector).find("[data-id='retype-passphrase']")
    status_element = $(selector).find("[data-id='passphrase-strength']")
    weak_alert_element = $(selector).find("[data-id='weak_passphrase_alert']")

    ok_button_element = $(selector).find("[data-id='ok-passphrase']")

    step2_keypair_element =  $(selector).find(".step2 [data-id='step2_keypair']")
    step2_upload_element =  $(selector).find(".step2 [data-id='step2_upload']")
    step2_done_element =  $(selector).find(".step2 [data-id='step2_done']")

    refresh_ui = () ->
        if passphrase? and passphrase is retype
            ok_button_element.css "visibility", "visible"
            weak_alert_element.toggle(strength < 4)
        else
            ok_button_element.css "visibility", "hidden"
        
    input_element.keyup () ->
        passphrase = input_element.val()
        strength = (zxcvbn(passphrase).score) + 1
        switch strength
            when 0, 1
                icon = "icon-warning-sign"
                color = "red"
            when 2, 3
                icon = "icon-warning-sign"
                color = "orange"
            when 4, 5
                icon = "icon-ok-sign"
                color = "green"

        status_element.html "<i class='#{icon}' style='color: #{color};'></i> #{strength}/5"
        refresh_ui()

    retype_element.keyup () ->
        retype = retype_element.val()
        refresh_ui()

    ok_button_element.click () ->
        step1_element.animate {height: 0, opacity: 0}, () ->
            step1_element.css "display", "none"

            step2_element.fadeIn () ->

                step2_keypair_element.css "visibility", "visible"
                keypair = forge.rsa.generateKeyPair {bits: 2136, e: 0x10001}

                encrypted_key = forge.pki.encryptRsaPrivateKey keypair.privateKey, passphrase
                setTimeout () ->

                    step2_upload_element.css "visibility", "visible"                
                    $.post 'keypair', 
                        public_key: forge.pki.publicKeyToPem(keypair.publicKey).toString()
                        private_key: encrypted_key.toString()
                        authenticity_token: window.csrf_token
                    , (success) ->
                        if success.status is "ok"
                            step2_done_element.css "visibility", "visible"
                            step2_done_element.find("a").click () ->
                                location.reload()

                        else
                            step2_element.append("<div class='alert'>I'm sorry, but something went wrong... try later!</div>")

                , 2000


window.setup = init
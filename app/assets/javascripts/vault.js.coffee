init = (selector) ->

    locked_panel_element = $(selector).find("[data-id='locked']")
    unlocked_panel_element  = $(selector).find("[data-id='unlocked']")
    unlocked_textarea_element = unlocked_panel_element.find("textarea")
    unlocked_status = $(selector).find("[data-id='lock-status']")
    passphrase_element = locked_panel_element.find("input")
    publicKey = null
    privateKey = null

    show_locked_vault = () ->
        unlocked_panel_element.fadeOut () ->
            locked_panel_element.fadeIn()
            unlocked_status.hide()

    show_unlocked_vault = () ->
        locked_panel_element.fadeOut () ->
            unlocked_panel_element.fadeIn()
            unlocked_status.show()

            if user.vault?
                decrypted = window.crypto_utils.decrypt_text user.vault, privateKey
                unlocked_textarea_element.val decrypted


    passphrase_element.change () ->
        passphrase = passphrase_element.val()
        privateKey = forge.pki.decryptRsaPrivateKey user.private_key.toString(), passphrase
        if privateKey?
            publicKey = forge.pki.publicKeyFromPem user.public_key
            console.log "publicKey is #{publicKey}"
            show_unlocked_vault()

    unlocked_textarea_element.change () ->
        if privateKey?
            text = unlocked_textarea_element.val()
            encrypted = crypto_utils.encrypt_text text, publicKey
            console.log encrypted
            $.ajax
                url: 'vault'
                type: 'PUT'
                data: 
                    vault: encrypted
            , (result) ->
                console.log result 

    unlocked_status.click () ->
        publicKey = null
        privateKey = null
        unlocked_textarea_element.val ""
        location.reload()

    show_locked_vault()

window.vault = init
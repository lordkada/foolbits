init = (selector) ->

    locked_panel_element = $(selector).find("[data-id='locked']")
    unlocked_panel_element  = $(selector).find("[data-id='unlocked']")
    unlocked_textarea_element = unlocked_panel_element.find("textarea")
    unlocked_status = $(selector).find("[data-id='lock-status']")
    passphrase_element = locked_panel_element.find("input")
    vault_data_element = $(selector).find("[data-id='vault_data']")
    pending_changes_element = $(selector).find("[data-id='pending_changes']")

    save_element = $(selector).find("[data-id='lock-save']")
    edit_element = $(selector).find("[data-id='lock-edit']")
    lock_element = $(selector).find("[data-id='lock-lock']")

    publicKey = null
    privateKey = null
    to_save_flag = false
    editing_flag = false

    resize = () ->
        zoomLevel = document.documentElement.clientWidth / window.innerWidth
        window_height = window.innerHeight * zoomLevel
        console.log "resize: body -> #{window_height} "
        unlocked_textarea_element.height(window_height - 160)

    $(window).resize () ->
        resize()

    toggle = (element, flag) ->
        element.find("a").css "color", if flag then "#428bca" else "lightgray"

    reset_vault = () ->
        publicKey = null
        privateKey = null
        passphrase_element.val ""
        unlocked_textarea_element.val ""
        to_save_flag = false
        editing_flag = false
        show_locked_vault()

    refresh_ui = () ->
        toggle save_element, to_save_flag
        toggle edit_element, !editing_flag
        window.scrollTo 0, 0 if !editing_flag
        resize()

    show_locked_vault = () ->
        unlocked_panel_element.fadeOut () ->
            locked_panel_element.fadeIn()

    passphrase_element.change () ->
        passphrase = passphrase_element.val()
        privateKey = forge.pki.decryptRsaPrivateKey user.private_key.toString(), passphrase
        if privateKey?
            publicKey = forge.pki.publicKeyFromPem user.public_key
            show_unlocked_vault()

    show_data_vault = () ->
        console.log editing_flag
        if editing_flag
            unlocked_textarea_element.prop "readonly", null
        else
            unlocked_textarea_element.prop "readonly", true

    show_unlocked_vault = () ->
        locked_panel_element.fadeOut () ->
            unlocked_panel_element.fadeIn()
            decrypted = window.crypto_utils.decrypt_text(user.vault, privateKey) if user.vault?
            unlocked_textarea_element.val decrypted
            show_data_vault()
            refresh_ui()

    save = (callback) ->
        if privateKey?
            console.log "saving..."
            encrypted = crypto_utils.encrypt_text unlocked_textarea_element.val(), publicKey
            $.ajax
                url: 'vault'
                type: 'PUT'
                data: 
                    vault: encrypted
                    authenticity_token: window.csrf_token
            .done (result) ->
                if result.status is "ok"
                    to_save_flag = false
                    user.vault = encrypted
                callback result.status

    lock_element.click () ->
        if to_save_flag
            pending_changes_element.modal()           
        else
            reset_vault()

    save_element.click () ->
        save () ->
            refresh_ui()

    edit_element.click () ->
        editing_flag = !editing_flag
        show_data_vault()
        refresh_ui()
        unlocked_textarea_element.focus() if editing_flag

    unlocked_textarea_element.keyup () ->
        if editing_flag
            to_save_flag = true
            refresh_ui()

    pending_changes_element.find("[data-id='discard']").click () ->
        reset_vault()

    pending_changes_element.find("[data-id='save']").click () ->
        save (result) ->
            console.log result
            if result is "ok"
                reset_vault()                

    reset_vault()

window.vault = init
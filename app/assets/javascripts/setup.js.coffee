check_strength = (selector) ->

    input_element = $(selector).find("input")
    progress_bar = $(selector).find(".progress .bar")
    status = $(selector).find(".progress div.status")

    input_element.keypress () ->
        console.log "premo"
        passphrase = input_element.val()
        strength = PasswordStrength.test(null, passphrase)
        progress_bar.css "width", "#{strength.score}%"
        status.html strength.status

window.setup = check_strength
$.ready = () ->
    $.get "/user", (user) ->
        window.user = user
        if user?
            if not user.private_key?
                $.get "/setup", (res) ->
                    $(".content").html res
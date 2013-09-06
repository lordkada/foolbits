$.ready = () ->
    content = $("[data-role='content']")
    $.get "/user", (user) ->
        window.user = user
        if user?
            if not user.private_key?
                $.get "/setup", (res) ->
                    content.html res
            else
                $.get "/vault", (res) ->
                    content.html res
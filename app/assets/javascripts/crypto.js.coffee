$(document).ready () ->
    content = $("[data-id='drop_content']")
    $.get "/user", (user) ->
        window.user = user
        if user? and window.location.pathname is "/"
            if not user.private_key?
                $.get "/setup", (res) ->
                    content.html res
            else
                $.get "/vault", (res) ->
                    content.html res
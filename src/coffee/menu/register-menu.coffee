setup.push ->

  ui.menu.menus.register = new Menu
    itemid: "register-menu"

    onlineOnly: true

    refreshAfterVisible: ->
      $("#register-name").focus()

    submit: ->
      name =   $("#register-name").val()
      email =  $("#register-email").val()
      passwd = $("#register-passwd").val()

      #return if name == "" or email == "" or passwd == ""

      ui.account.create(name, email, passwd, (data) ->
        # pass
      )

  $("#submit-registration").click -> ui.menu.menus.register.submit()

  $("#register-passwd").hotkeys
    down:
      enter: ->
        ui.menu.menus.register.submit()


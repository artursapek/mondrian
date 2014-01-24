setup.push ->

  ui.menu.menus.login = new Menu
    itemid: "login-menu"

    refreshAfterVisible: ->
      $("#login-email-input").focus()

    submit: ($self) ->
      email = $("#login-email-input").val()
      passwd = $("#login-passwd-input").val()

      if email == ""
        $self.error("email required")
      else if passwd == ""
        $self.error("password required")
      else
        ui.account.login(email, passwd)
      #@closeDropdown()


  $("#submit-login").click ->
    ui.menu.menus.login.submit($(@))

  $("#login-passwd-input").hotkeys
    down:
      enter: ->
        ui.menu.menus.login.submit()



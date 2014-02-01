###

  The logged-in account

    strings
      email:         user's email address
      session_token: secret token used to verify their logged-in session

    lists
      services: which services they have access to
                default:
                  'local'
                possibly also:
                  'dropbox'
                  (more to come)

      active:     if they should get full account features
      subscribed: if they actually have an active card on file

###

ui.account =

  email: ""
  session_token: ""

  services: ['local']

  valueOf: -> @email or "anon"

  uiAnonymous: ->
    # Hide and disable things not available to anonymous users.
    services.dropbox.tease().disable()
    ui.menu.items.shareAsLink.enable()
    ui.menu.items.downloadSVG.enable()
    ui.menu.menus.login.show()
    ui.menu.menus.register.show()

  uiLoggedIn: ->
    services.dropbox.tease().enable()
    ui.menu.items.shareAsLink.enable()
    ui.menu.items.downloadSVG.enable()
    ui.menu.menus.login.groupHide()
    ui.menu.menus.account.text(@email).groupShow()

  checkSession: ->
    # See if the user is logged in. If so, set up the UI to reflect that.
    @session_token = localStorage.getItem("session_token")

    # TODO Hackish. Why is this here?
    if @session_token
      $.ajax(
        url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/persist-session"
        type: "POST"
        dataType: "json"
        data:
          session_token: @session_token
        success: (response) =>
          if response.anon?
            @uiAnonymous()
          else
            @processLogin response
          trackEvent "User", "Persist session"

        error: =>
          @uiAnonymous()
      )

    else
      @uiAnonymous()

  login: (email, passwd) ->

    $("#login-mg input").each ->
      $(@).disable()

    $.ajax(
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/login"
      type: "POST"
      dataType: "json"
      data:
        email: email
        passwd: passwd
      success: (response) =>
        # Save the session_token for later <3
        @processLogin response

        if response.trial_remaining? > 0
          ui.menu.menus.account.openDropdown()

        $("#login-mg input").each ->
          $(@).enable()

        # Track to GA
        trackEvent "User", "Login"

      error: (data) =>
        data = JSON.parse(data.responseText)
        $("#submit-login").error(data.error)
        trackEvent "User", "Login error", data.error


      complete: ->
        $("#login-mg input").each ->
          $(@).enable()

    )

  processLogin: (response) ->

    $.extend(@, response)

    # Store the session token locally
    localStorage.setItem("session_token", @session_token)

    ui.menu.menus.login.groupHide()
    ui.menu.menus.register.groupHide()
    ui.menu.menus.account.show().text(@email)

    ui.menu.closeAllDropdowns()

    @uiLoggedIn()

    #ui.file.getNewestVersion()

    if response.services?
      for s in response.services
        services[s].activate()
    else
      # Advertise all the non-default services.
      # For now it's just Dropbox.
      services.dropbox.tease()



  logout: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/logout"
      type: "POST"
      dataType: "json"
      data:
        session_token: @session_token
      success: (response) =>
        @session_token = undefined
        localStorage.removeItem("session_token")

        # Track to GA
        trackEvent "User", "Logout"

        @uiAnonymous()

        ui.menu.menus.account.groupHide()
        ui.menu.menus.login.groupShow()
        ui.menu.menus.register.groupShow()

  checkServices: ->
    $.getJSON "#{SETTINGS.MEOWSET.ENDPOINT}/user/check-services",
      { session_token: @session_token },
      (data) ->
        if data.dropbox
          services.dropbox.activate()


  create: (name, email, passwd) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/register"
      type: "POST"
      dataType: "json"
      data:
        name: name
        email: email
        passwd: passwd
      success: (data) =>
        trackEvent "User", "Create", "(#{name} , #{email})"
        @login email, passwd
        ui.menu.closeAllDropdowns()
      error: (data) =>
        data = JSON.parse(data.responseText)
        $("#submit-registration").error(data.error)


setup.push ->
  ui.account.checkSession()
  ui.refreshUtilities() # Hackish spot for this


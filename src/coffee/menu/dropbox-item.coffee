setup.push ->

  ui.menu.items.dropboxConnect = new MenuItem
    itemid: "connect-to-dropbox-item"

    enableWhen: -> navigator.onLine

    refresh: () ->
      if ui.account.session_token
        @enable()
        @rep.parentNode.setAttribute("href", "#{SETTINGS.MEOWSET.ENDPOINT}/poletto/connect-to-dropbox?session_token=#{ui.account.session_token}")
        @$rep.parent().off('click').on('click', ->
          ui.window.one "focus", ->
            ui.menu.menus.file.closeDropdown()
            ui.account.checkServices()
            trackEvent "Dropbox", "Connect Account"
        )

      else
        @disable()
        @$rep.parent().click (e) ->
          e.preventDefault()




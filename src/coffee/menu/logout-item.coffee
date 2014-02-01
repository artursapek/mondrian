setup.push ->

  ui.menu.items.logout = new MenuItem
    itemid: "logout-item"

    action: ->
      ui.account.logout()



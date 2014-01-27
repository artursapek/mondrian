setup.push ->

  ui.menu.menus.share = new Menu
    itemid: "share-menu"

    onlineOnly: true

  ui.menu.items.shareAsLink = new MenuItem
    itemid: "share-permalink-item"

    action: ->
      services.permalink.put()


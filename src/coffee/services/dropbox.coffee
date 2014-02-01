###

  Dropbox, baby

###


services.dropbox = new Service

  name: "Dropbox"

  module: "poletto"

  tease: ->
    # Show it off
    ui.menu.items.dropboxConnect.show()

  activate: ->
    ui.menu.items.dropboxConnect.hide()
    if not ui.account.services.has "dropbox"
      ui.account.services.push "dropbox"

  disable: ->
    ui.menu.items.dropboxConnect.disable()

  enable: ->
    ui.menu.items.dropboxConnect.enable()


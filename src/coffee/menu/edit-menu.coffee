setup.push ->

  ui.menu.menus.edit = new Menu
    itemid: "edit-menu"

  ui.menu.items.undo = new MenuItem
    itemid: "undo-item"

    action: (e) ->
      e.preventDefault()
      archive.undo()

    hotkey: "cmd-Z"

    closeOnClick: false

    enableWhen: ->
      not archive.currentlyAtBeginning()


  ui.menu.items.redo = new MenuItem
    itemid: "redo-item"

    action: (e) ->
      e.preventDefault()
      archive.redo()

    hotkey: "cmd-shift-Z"

    closeOnClick: false

    enableWhen: ->
      not archive.currentlyAtEnd()


  ui.menu.items.visualHistory = new MenuItem
    itemid: "visual-history"

    action: (e) ->
      ui.utilities.history.toggle()

    hotkey: "0"

    closeOnClick: false

    enableWhen: ->
      archive.events.length > 0


  ui.menu.items.selectAll = new MenuItem
    itemid: "select-all-item"

    action: (e) ->
      e.preventDefault()
      ui.selection.elements.selectAll()

    hotkey: "cmd-A"

    closeOnClick: false

    enableWhen: ->
      ui.elements.length > 0


  ui.menu.items.cut = new MenuItem
    itemid: "cut-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.cut()

    hotkey: "cmd-X"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0


  ui.menu.items.copy = new MenuItem
    itemid: "copy-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.copy()

    hotkey: "cmd-C"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0


  ui.menu.items.paste = new MenuItem
    itemid: "paste-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.paste()

    hotkey: "cmd-V"

    closeOnClick: false

    enableWhen: ->
      ui.clipboard.data?


  ui.menu.items.delete = new MenuItem
    itemid: "delete-item"

    action: (e) ->
      e.preventDefault()
      archive.addExistenceEvent(ui.selection.elements.all.map (e) -> e.zIndex())
      ui.selection.delete()
      ui.selection.elements.validate()


    hotkey: "backspace"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0





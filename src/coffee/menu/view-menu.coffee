setup.push ->

  ui.menu.menus.view = new Menu
    itemid: "view-menu"

  ui.menu.items.zoomOut = new MenuItem
    itemid: "zoom-out-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoomOut()
      false
    after: ->
      ui.refreshAfterZoom()
    hotkey: "-"
    closeOnClick: false


  ui.menu.items.zoomIn = new MenuItem
    itemid: "zoom-in-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoomIn()
      false
    after: ->
      ui.refreshAfterZoom()

    hotkey: "+"
    closeOnClick: false


  ui.menu.items.zoom100 = new MenuItem
    itemid: "zoom-100-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoom100()
      false
    after: ->
      ui.refreshAfterZoom()
    hotkey: "1"
    closeOnClick: false


  ui.menu.items.grid = new MenuItem
    itemid: "show-grid-item"
    hotkey: "shift-'"
    action: ->
      ui.grid.toggle()
    closeOnClick: false



setup.push ->


  ui.menu.items.moveBack = new MenuItem
    itemid: 'move-back-item'

    hotkey: '['

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.moveBack()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mb')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.moveForward = new MenuItem
    itemid: 'move-forward-item'

    hotkey: ']'

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.moveForward()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mf')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.sendToBack = new MenuItem
    itemid: 'send-to-back-item'

    hotkey: 'shift-['

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.sendToBack()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mbb')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.bringToFront = new MenuItem
    itemid: 'bring-to-front-item'

    hotkey: 'shift-]'

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.bringToFront()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mff')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false



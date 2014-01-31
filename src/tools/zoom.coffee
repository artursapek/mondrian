###

  Zoom tool

###


tools.zoom = new Tool

  offsetX: 5
  offsetY: 5

  cssid: 'zoom'
  id: 'zoom'

  hotkey: 'Z'

  ignoreDoubleclick: true

  click:
    all: (e) ->
      if ui.hotkeys.modifiersDown.has "alt"
        ui.canvas.zoomOut()
      else
        ui.canvas.zoomIn()
      ui.window.centerOn(new Posn(e.canvasX, e.canvasY))
      ui.refreshAfterZoom()


  startDrag:
    all: (e) ->
      ui.dragSelection.start(new Posn e)


  continueDrag:
    all: (e) ->
      ui.dragSelection.move(new Posn e)


  stopDrag:
    all: ->
      ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)
      for elem in ui.elements
        elem.refreshUI()



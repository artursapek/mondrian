###

  Zoom tool

###


tools.zoom = new Tool

  offsetX: 5
  offsetY: 5

  cssid: 'zoom'
  id: 'zoom'

  ignoreDoubleclick: true

  click:
    all: (e) ->
      if ui.hotkeys.modifiersDown.has "alt"
        ui.canvas.zoomOut(e.clientPosn)
      else
        ui.canvas.zoomIn(e.clientPosn)
      ui.refreshAfterZoom()

  rightClick:
    all: (e) -> ui.canvas.zoom100()

  startDrag:
    all: (e) ->
      ui.dragSelection.start(new Posn e)


  continueDrag:
    all: (e) ->
      ui.dragSelection.move(new Posn e)


  stopDrag:
    all: (e) ->
      if ui.hotkeys.modifiersDown.has "alt"
        ui.dragSelection.end( ->  ui.canvas.zoom100())
      else if e.which is 1
        ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)
      else if e.which is 3
        ui.dragSelection.end(-> ui.canvas.zoomOut())
        #ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)

      for elem in ui.elements
        elem.refreshUI()



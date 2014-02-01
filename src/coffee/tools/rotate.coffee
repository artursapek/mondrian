###

  Rotate

###

tools.rotate = new Tool

  cssid: 'crosshair'

  id: 'rotate'

  offsetX: 7
  offsetY: 7

  setup: ->
    @$rndo = $("#r-nd-o")
    ui.transformer.onRotatingMode()
    @setCenter ui.transformer.center()
    ui.selection.elements.on 'changed', =>
      @$rndo.hide()


  tearDown: ->
    @setCenter undefined
    ui.transformer.offRotatingMode()



  lastAngle: undefined


  setCenter: (@center) ->
    return if ui.selection.elements.all.length is 0
    if @center?
      @$rndo.show().css
        left: (@center.x - 6).px()
        top: (@center.y - 6).px()
    else
      @$rndo.hide()



  click:
    all: (e) ->
      @setCenter new Posn(e.canvasX, e.canvasY)


  startDrag:
    all: (e) ->
      if @center is undefined
        @setCenter ui.transformer.center()
      @lastAngle = new Posn(e.canvasX, e.canvasY)


  continueDrag:
    all: (e) ->
      currentAngle = new Posn(e.canvasX, e.canvasY).angle360(@center)
      change = currentAngle - @lastAngle

      if not isNaN change
        ui.selection.rotate change, @center

      @lastAngle = currentAngle


  stopDrag:
    all: (e) ->
      @lastAngle = undefined
      ui.selection.elements.all.map (p) ->
        p.redrawHoverTargets()

      archive.addMapEvent("rotate", ui.selection.elements.zIndexes(), {
        angle: ui.transformer.accumA
        origin: ui.transformer.origin
      })

      # A rotation has stopped so reset the accumulated values
      ui.transformer.resetAccum()


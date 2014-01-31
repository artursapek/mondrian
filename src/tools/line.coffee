###


   o
    \
     \
      \
       \
        \
         \
          \
           \
            o

###


tools.line = new Tool

  drawing: false
  cssid: 'crosshair'
  id: 'line'

  hotkey: '\\'

  offsetX: 7
  offsetY: 7

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        op = @initialDragPosn
        if op?
          ui.snap.presets.every45(op, "canvas")

  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        ui.snap.toNothing()

  tearDown: ->
    @drawing = false

  startDrag:
    all: (e) ->
      @beginNewLine(e)
      @initialDragPosn = e.canvasPosnZoomed


  beginNewLine: (e) ->
    p = e.canvasPosnZoomed
    @drawing = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY} L#{e.canvasX},#{e.canvasY}")
    @drawing.appendTo('#main')
    @drawing.commit()


  continueDrag:
    all: (e) ->
      p = e.canvasPosnZoomed
      @drawing.points.last.x = p.x
      @drawing.points.last.y = p.y
      @drawing.commit()


  stopDrag:
    all: ->
      @drawing.redrawHoverTargets()
      @drawing.commit()
      ui.selection.elements.select @drawing








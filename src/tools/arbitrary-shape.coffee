###

  Arbitrary Shape Tool

  A subclass of Tool that performs a simple action: draw a hard-coded shape
  from the startDrag point to the endDrag point.

  Basically this is an abstraction. It's used by the Ellipse and Rectangle tools.

###


class ArbitraryShapeTool extends Tool

  constructor: (attrs) ->
    super attrs

  drawing: false
  cssid: 'crosshair'

  offsetX: 7
  offsetY: 7

  ignoreDoubleclick: true

  started: null

  # This is what gets defined as the shape it draws.
  # It should be a string of points
  template: null

  tearDown: ->
    @drawing = false

  startDrag:
    all: (e) ->
      @started = e.canvasPosnZoomed

      @drawing = new Path
        stroke: ui.stroke.clone()
        fill: ui.fill.clone()
        'stroke-width': ui.uistate.get('strokeWidth')
        d: @template

      @drawing.virgin = @virgin()

      @drawing.hide()
      @drawing.appendTo "#main"
      @drawing.commit()


  continueDrag:
    all: (e) ->
      ftb = new Bounds(e.canvasPosnZoomed, @started)
      if e.shiftKey
        ftb = new Bounds(@started, e.canvasPosnZoomed.squareUpAgainst @started)
      if e.altKey
        ftb.centerOn(@started)
        ftb.scale(2, 2, @started)

      @drawing.show()
      @drawing.fitToBounds ftb
      @drawing.commit()

  stopDrag:
    all: ->
      @drawing.cleanUpPoints()
      archive.addExistenceEvent(@drawing.rep)

      @drawing.redrawHoverTargets()

      ui.selection.elements.select @drawing

      @drawing = false




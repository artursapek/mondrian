###

  Pen tool

  Polygon/path-drawing tool


            #
            #
          #####
          #* *#
          # * #
       ###########
       # * * * * #
       #* * * * *#
       # * * * * #



tools.pen = new Tool

  offsetX: 5
  offsetY: 0

  cssid: 'pen'

  id: 'pen'

  ignoreDoubleclick: true

  tearDown: ->
    if @drawing
      ui.selection.elements.select @drawing
      @drawing.redrawHoverTargets()
      @drawing.points.map (p) ->
        p.hideHandles?()
        p.hide()
      @drawing = false
    @clearPoints()


  # Metadata: what shape we're in, what point was just put down,
  # which is being dragged, etc.

  drawing: false
  firstPoint: null
  lastPoint: null
  currentPoint: null

  clearPoints: ->
    # Resetting most of the metadata.
    @firstPoint = null
    @currentPoint = null
    @lastPoint = null


  beginNewShape: (e) ->
    # Ok, if we're drawing and there's no stroke color defined
    # but the stroke width isn't 0, we need to resort to black.
    if (ui.uistate.get('strokeWidth') > 0) and (ui.stroke.toString() is "none")
      ui.stroke.absorb ui.colors.black

    # State a new Path!
    shape = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY}")
    shape.appendTo('#main')
    shape.commit().showPoints()

    archive.addExistenceEvent(shape.rep)

    @drawing = shape
    @firstPoint = shape.points.first
    @currentPoint = @firstPoint



  endShape: ->

    # Close up the shape we're drawing.
    # This happens when the last point is clicked.

    @drawing.points.close().hide()
    @drawing.commit()
    @drawing.redrawHoverTargets()
    @drawing.points.first.antlers.basep3 = null

    @drawing = false
    @clearPoints()


  addStraightPoint: (x, y) ->

    # On a static click, add a point inheriting the last point's succp2 antler.
    # If there was one, this will be a SmoothTo. If there wasn't, then a LineTo.

    last = @drawing.points.last
    succp2 = last.antlers.succp2

    if @drawing.points.last.antlers?.succp2?
      if last instanceof CurvePoint and succp2.x isnt last.x and succp2.y isnt last.y
        point = new SmoothTo(x, y, x, y, @drawing, last)
      else
        point = new CurveTo(last.antlers.succp2.x, last.antlers.succp2.y, x, y, x, y, @drawing, last)
    else
      point = new LineTo(x, y, @drawing)

    @drawing.points.push point

    last.hideHandles?()
    @drawing.hidePoints()
    point.draw()

    archive.addPointExistenceEvent(@drawing.zIndex(), point)

    @drawing.commit().showPoints()
    @currentPoint = point

  addCurvePoint: (x, y) ->
    # CurveTo
    x2 = x
    y2 = y

    last = @drawing.points.last
    last.hideHandles?()
    point = new CurveTo(last.x, last.y, x, y, x, y, @drawing, @drawing.points.last)

    @drawing.points.push point

    if last.antlers?.succp2?
      point.x2 = point.prec.antlers.succp2.x
      point.y2 = point.prec.antlers.succp2.y

    last.hideHandles?()
    @drawing.hidePoints()
    point.draw()

    archive.addPointExistenceEvent(@drawing.zIndex(), point)

    @drawing.commit().showPoints()
    @currentPoint = point


  updateCurvePoint: (e) ->
    @currentPoint.antlers.importNewSuccp2(new Posn(e.canvasX, e.canvasY))

    if @drawing.points.closed
      @currentPoint.antlers.show()
      @currentPoint.antlers.succp.persist()

    @currentPoint.antlers.lockAngle = true
    @currentPoint.antlers.show()
    @currentPoint.antlers.refresh()
    @drawing.commit()


  leaveShape: (e) ->
    @drawing = false


  hover:
    point: (e) ->
      if @drawing
        switch e.point
          when @lastPoint
            e.point.actionHint()
            undo = e.point.antlers.hideTemp 2
            @unhover.point = =>
              undo()
              e.point.hideActionHint()
              @unhover.point = ->
          when @firstPoint
            e.point.actionHint()
            @unhover.point = =>
              e.point.hideActionHint()
              @unhover.point = ->


  unhover: {}


  click:
    background_elem: (e) ->
      if not @drawing
        @beginNewShape(e)
      else
        @addStraightPoint e.canvasX, e.canvasY

    point: (e) ->
      switch e.point
        when @lastPoint
          e.point.antlers.killSuccp2()
        when @firstPoint
          @drawing.points.close()
          @addStraightPoint e.point.x, e.point.y
          @drawing.points.last.antlers.importNewSuccp2 @drawing.points.first.antlers.succp2
          @drawing.points.last.antlers.lockAngle = true

          # We've closed the shape
          @endShape()
        else
          @click.background_elem.call(@, e)

  mousedown:
    all: ->
      if @currentPoint? and @snapTo45
        ui.snap.presets.every45((if @currentPoint? then @currentPoint else @lastPoint), "canvas")

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        @snapTo45 = true
        if @currentPoint? or @lastPoint?
          ui.snap.presets.every45((if @currentPoint? then @currentPoint else @lastPoint), "canvas")

  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        @snapTo45 = false
        ui.snap.toNothing()

  snapTo45: false

  startDrag:
    point: (e) ->
      if e.point is @firstPoint
        @drawing.points.close()
        @addCurvePoint e.point.x, e.point.y
      else
        @startDrag.all(e)

    all: (e) ->
      if @drawing
        @addCurvePoint e.canvasX, e.canvasY
      else
        @beginNewShape e


  continueDrag:
    all: (e, change) ->
      @updateCurvePoint(e) if @drawing


  stopDrag:
    all: (e) ->
      if @drawing.points.closed
        @currentPoint.deselect().hide()
        @endShape()
      @lastPoint = @currentPoint
      @currentPoint = null


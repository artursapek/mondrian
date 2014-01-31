###

  Crayon plz

###

tools.crayon = new Tool

  offsetX: 5
  offsetY: 0
  cssid: 'crayon'
  id: 'crayon'

  hotkey: 'C'

  drawing: false

  setup: ->

  tearDown: ->

  # How many events we go between putting down a point
  # Which kind of point alternates:
  frequency: 0

  eventCounter: 0

  alternatingCounter: 2

  beginNewLine: (e) ->
    line = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY}")
    line.appendTo('#main')
    line.commit().showPoints()

    @line = line
    @currentPoint = @line.points.first

  determineControlPoint: (which) ->
    # Helper for the crayon
    switch which
      when "p2"
        [compareA, compareB, stashed] = [@lastPoint, @currentPoint, @stashed33]
      when "p3"
        [compareA, compareB, stashed] = [@currentPoint, @lastPoint, @stashed66]

    lastBaseToNewBase = new LineSegment(compareA, compareB)
    lastBaseTo33      = new LineSegment(compareA, stashed)

    lBBA =  lastBaseToNewBase.angle360()
    lB33A = lastBaseTo33.angle360()

    angleBB = lB33A - lBBA
    angleDesired = lBBA + angleBB * 2

    lenBB = lastBaseToNewBase.length
    lenDesired = lenBB / 3

    desiredHandle = new Posn(compareA)
    desiredHandle.nudge(0, -lenDesired)
    desiredHandle.rotate(angleDesired + 180, compareA)

    if isNaN desiredHandle.x
      desiredHandle.x = compareB.x
    if isNaN desiredHandle.y
      desiredHandle.y = compareB.y

    desiredHandle

  stashedBaseP3: undefined

  addPoint: (e) ->
    switch @alternatingCounter
      when 1
        @lastPoint = @currentPoint

        # Now we figure out where the last succp2 should have been
        # Twice the angle, half the length.

        if e?
          @currentPoint = new CurveTo(
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            @line)

        #ui.annotations.drawDot(@currentPoint, '#ff0000')

        @alternatingCounter = 2

        #  Time for a shitty diagram!
        #
        #           C
        #          / \
        #         /   |
        #        /     |
        #       /    /
        #      /   X
        #     / /
        #    L------V
        #
        #   L = @lastPoint
        #   C = @currentPoint
        #   X = @stashed33
        #   V = what we want
        #
        #   Line from L-C = lastBaseToNewBase
        #   Line from L-V = lastBaseTo33

        return if not @stashed33?

        @lastPoint.antlers.succp2 = @determineControlPoint('p2')
        @currentPoint.antlers.basep3 = @determineControlPoint('p3')

        @lastPoint.succ = @currentPoint

        # Now that lastPoint has both antlers,
        # flatten them to be no less than 180
        @lastPoint.antlers.flatten()
        @lastPoint.antlers.commit()
        @currentPoint.antlers.commit()

        @line.points.push @currentPoint
        @currentPoint.draw()

        @line.points.hide()
        @line.commit()

      when 2
        # Stash the 33% mark
        @stashed33 = e.canvasPosnZoomed
        @alternatingCounter = 3

      when 3
        # Stash the 66% mark
        @stashed66 = e.canvasPosnZoomed
        @alternatingCounter = 1


  # A static click means they didn't move, so don't do anything
  # We don't want stray points
  click:
    all: ->

  startDrag:
    all: (e) ->
      @beginNewLine(e)

  continueDrag:
    all: (e) ->
      #ui.annotations.drawDot(e.canvasPosnZoomed, 'rgba(0,0,0,0.2)')
      if @eventCounter is @frequency
        @addPoint(e)
        @eventCounter = 0
      else
        @eventCounter += 1


  stopDrag:
    all: ->
      #ui.selection.elements.select @line
      # (meh)
      @line.redrawHoverTargets()
      archive.addExistenceEvent(@line.rep)
      @line = undefined


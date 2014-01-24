###

  Path

  Highest order of vector data. Lowest level of expression.

###

class Path extends Monsvg
  type: 'path'


  constructor: (@data) ->
    super @data

    if @data?.d?
      @importNewPoints(@data.d)


    @antlerPoints = new PointsList([], @)

    # Kind of a hack
    if @data?.d?.match(/z$/gi) isnt null
      @points.closed = true


  # Are we caching expensive metadata like bounds?
  caching: true


  commit: ->
    @data.d = @points.toString()
    super


  hover: ->
    if not ui.selection.elements.all.has @
      @showPoints()

    ui.unhighlightHoverTargets()

  unhover: ->
    @hidePoints()

  # A Path can have a "virgin" attribute that it will be exported as if no points
  # have been changed individually since it was assigned.
  # You would assign another SVG element as its virgin attr and that will get scaled,
  # nudged alongside the Path itself.
  # Any time a point is moved by itself and the "shape" is changed, the virgin attribute
  # is reset to false.
  virgin: undefined


  virginMode: ->
    @virgin.eyedropper @
    @$rep.replaceWith(@virgin.$rep)


  editMode: ->
    @virgin.$rep.replaceWith @$rep


  woohoo: ->
    @virgin = undefined


  importNewPoints: (points) ->
    if points instanceof PointsList
      @points = points
    else
      @points = new PointsList(points, @)

    @points = @points.absolute()

    @clearCachedObjects()

    @


  cleanUpPoints: ->
    for p in @points.all()
      p.cleanUp()
    @commit()


  appendTo: (selector, track = true) ->
    super selector, track
    @points.drawBasePoints().hide()
    @redrawHoverTargets() if track
    @


  xRange: () ->
    cached = @xRangeCached
    if cached isnt null
      return cached
    else
      @xRangeCached = new Range().fromRangeList(@lineSegments().map (x) -> x.xRange())


  xRangeCached: null


  yRange: () ->
    cached = @yRangeCached
    if cached isnt null
      return cached
    else
      @yRangeCached = new Range().fromRangeList(@lineSegments().map (x) -> x.yRange())


  yRangeCached: null


  nudgeCachedObjects: (x, y) ->
    @boundsCached?.nudge x, y
    @xRangeCached?.nudge x
    @yRangeCached?.nudge y
    @lineSegmentsCached?.map (ls) ->
      ls.nudge(x, y)


  scaleCachedObjects: (x, y, origin) ->
    @boundsCached?.scale x, y, origin
    @xRangeCached?.scale x, origin.x
    @yRangeCached?.scale y, origin.y
    @lineSegmentsCached = null
    ###
    @lineSegmentsCached.map (ls) ->
      ls.scale(x, y, origin)
    ###


  clearCachedObjects: ->
    @lineSegmentsCached = null
    @boundsCached = null
    @xRangeCached = null
    @yRangeCached = null
    @


  lineSegments: ->
    # No I/P
    #
    # O/P: A list of LineSegments and/or CubicBeziers representing this path
    cached = @lineSegmentsCached
    if cached isnt null
      return cached
    else
      segments = []
      @points.all().map (curr, ind) =>
        segments.push(lab.conversions.pathSegment curr, curr.succ)
      @lineSegmentsCached = segments

  lineSegmentsCached: null

  scale: (x, y, origin = @center()) ->
    # Keep track of cached bounds and line segments
    @scaleCachedObjects(x, y, origin)

    # We might need to rotate and unrotate this thing
    # to keep its angle true. This way we can scale at angles
    # after we rotate shapes.
    angle = @metadata.angle

    # Don't do unecessary work: only do rotation if shape has an angle other than 0
    unless angle is 0
      # Rotate the shape to normal (0 degrees) before doing the scaling.
      @rotate(360 - angle, origin)

    # After we've unrotated it, scale it
    @points.map((a) => a.scale(x, y, origin))

    unless angle is 0
      # ...and rotate it back to where it should be.
      @rotate(angle, origin)

    # Boom
    @commit()

    # Carry out on virgin rep
    @virgin?.scale(x, y, origin)


  nudge: (x, y) ->
    # Nudge dis bitch
    @points.map (p) -> p.nudge x, y, false

    # Nudge the cached bounds and line segments if they're there
    # to keep track of those.
    @nudgeCachedObjects(x, y)

    # Commit the changes to the canvas
    @commit()

    # Also nudge the virgin shape if there is one
    @virgin?.nudge(x, y)


  rotate: (a, origin = @center()) ->
    # Add to the transform angle we're keeping track of.
    @metadata.angle += a

    # Normalize it to be 0 <= n <= 360
    @metadata.angle %= 360

    # At this point the bounds are no longer valid, so ditch it.
    @clearCachedObjects()

    # Rotate all the points!
    @points.map (p) -> p.rotate a, origin

    # Commit it
    @commit()

    # Rotated rect becomes path
    @woohoo()


  fitToBounds: (bounds) ->
    @clearCachedObjects()
    mb = @bounds()
    # Make up for the difference

    myWidth = mb.width
    myHeight = mb.height

    sx = bounds.width / mb.width
    sy = bounds.height / mb.height

    sx = 1 if (isNaN sx) or (sx == Infinity) or (sx == -Infinity) or (sx == 0)
    sy = 1 if (isNaN sy) or (sy == Infinity) or (sy == -Infinity) or (sy == 0)

    sx = Math.max(1e-5, sx)
    sy = Math.max(1e-5, sy)

    @scale(sx, sy, new Posn(mb.x, mb.y))
    @nudge(bounds.x - mb.x, mb.y - bounds.y)

    debugger if @points.toString().indexOf("NaN") > -1


  overlapsRect: (rect) ->
    if @bounds().overlapsBounds(rect.bounds())
      # First, check if any of our points are inside of this rectangle.
      # This is a much cheaper operation than line segment intersections.
      # We resort to that if no points are found inside of the rect.
      for point in @points.all()
        if point.insideOf rect
          return true
      return @lineSegmentsIntersect(rect)
    else
      return false


  drawToCanvas: (context) ->
    context = @setupToCanvas(context)
    for point in @points.all()
      switch point.constructor
        when MoveTo
          context.moveTo(point.x, point.y)
        when LineTo, HorizTo, VertiTo
          context.lineTo(point.x, point.y)
        when CurveTo, SmoothTo
          context.bezierCurveTo(point.x2, point.y2, point.x3, point.y3, point.x, point.y)
    @finishToCanvas(context)


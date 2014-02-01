class Rect extends Monsvg
  type: 'rect'

  constructor: (@data) ->
    super @data
    @data.x = 0 if not @data.x?
    @data.y = 0 if not @data.y?

    @data.x = parseFloat @data.x
    @data.y = parseFloat @data.y
    @data.width = parseFloat @data.width
    @data.height = parseFloat @data.height


  commit: ->
    @_validateDimensions()
    super


  points: ->
    [new Point(@data.x, @data.y),
     new Point(@data.x + @data.width, @data.y),
     new Point(@data.x + @data.width, @data.y + @data.height),
     new Point(@data.x, @data.y + @data.height)]


  ###

    Geometric data

      points()
      lineSegments()
      center()
      xRange()
      yRange()

  ###

  lineSegments: ->
    p = @points()
    [new LineSegment(p[0], p[1], p[1])
     new LineSegment(p[1], p[2], p[2])
     new LineSegment(p[2], p[3], p[3])
     new LineSegment(p[3], p[0], p[0])]

  center: ->
    new Posn(@data.x + (@data.width / 2), @data.y + (@data.height / 2))

  xRange: ->
    new Range(@data.x, @data.x + @data.width)

  yRange: ->
    new Range(@data.y, @data.y + @data.height)

  clearCachedObjects: ->

  ###

    Relationship analysis

      contains()
      overlaps()
      intersections()
      containments()
      containmentsBothWays()

  ###

  contains: (posn) ->
    @xRange().contains(posn.x) and @yRange().contains(posn.y)


  overlaps: (other) ->

    ###
      Fuck you whore
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    ###

    @['overlaps' + other.type.capitalize()](other)

  overlapsPolygon: (polygon) ->
    if @contains polygon.center() or polygon.contains(@center())
      return true
    return @lineSegmentsIntersect(polygon)


  overlapsCircle: (circle) ->

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)


  intersections: (obj) ->
    intersections = []
    for s1 in @lineSegments()
      for s2 in obj.lineSegments()
        inter = s1.intersection(s2)
        if inter instanceof Posn
          intersections.push(inter)
    return intersections

  containments: (obj) ->
    containments = []
    points = obj.points
    xr = @xRange()
    yr = @yRange()

    for point in points
      if xr.contains(point.x) and yr.contains(point.y)
        containments.push(point)
    return containments


  containmentsBothWays: (obj) ->
    @containments(obj).concat(obj.containments(@))


  scale: (factorX, factorY, origin=@center()) ->
    @attr
      x:      (x) => (x - origin.x) * factorX + origin.x
      y:      (y) => (y - origin.y) * factorY + origin.y
      width:  (w) -> w * factorX
      height: (h) -> h * factorY
    @commit()


  nudge: (x, y) ->
    @data.x += x
    @data.y -= y
    @commit()


  # Operates on perfect rectangle
  #
  # O/P: self as polygon, replaces instance with polygon instance


  convertToPath: ->
    # Get this rect's points
    pts = @points()

    # Build a new rectangular path from it
    path = new Path
      d: "M#{pts[0]} L#{pts[1]} L#{pts[2]} L#{pts[3]} L#{pts[0]}"

    # Copy the colors over
    path.eyedropper @

    path.updateDataArchived()

    path


  drawToCanvas: (context) ->
    context = @setupToCanvas(context)
    context.rect(@data.x, @data.y, @data.width, @data.height)
    context = @finishToCanvas(context)


  _validateDimensions: ->
    if @data.height < 0
      @data.height *= -1
    if @data.width < 0
      @data.width *= -1





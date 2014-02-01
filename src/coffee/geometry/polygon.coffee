# Polygon class
#
#
#
#

class Polygon extends Monsvg
  type: 'polygon'

  constructor: (@data) ->
    @points = new PointsList(@parsePoints(@data.points))
    super @data

  appendTo: (selector, track = true) ->
    super selector, track
    @points.drawBasePoints().hide()
    @redrawHoverTargets() if track
    @


  commit: ->
    @data.points = @points.toString()
    super

  lineSegments: ->
    points = @points.points
    segments = []
    # Recur over points, loop back to first posn at the end.
    points.map (curr, ind) ->
      # Get the next point. If there is no next point, use the first point (loop back around)
      next = points[if ind == (points.length - 1) then 0 else ind + 1]
      # Make the LineSegment and bail
      segments.push(new LineSegment(curr, next))

    segments


  xs: ->
    @points.all().map((posn) -> posn.x)


  ys: ->
    @points.all().map((posn) -> posn.y)


  xRange: ->
    new Range().fromList(@xs())


  yRange: ->
    new Range().fromList(@ys())


  topLeftBound: ->
    new Posn(@xRange().min, @yRange().min)


  topRightBound: ->
    new Posn(@xRange().max, @yRange().min)


  bottomRightBound: ->
    new Posn(@xRange().max, @yRange().max)


  bottomLeftBound: ->
    new Posn(@xRange().min, @yRange().max)

  bounds: ->
    xr = @xRange()
    yr = @yRange()
    new Bounds(xr.min, yr.min, xr.length(), yr.length())

  center: ->
    @bounds().center()


  parsePoints: ->
    if @data.points is ''
      return []

    points = []

    @data.points = @data.points.match(/[\d\,\. ]/gi).join('')

    @data.points.split(' ').map((coords) =>
      coords = coords.split(',')
      if coords.length == 2
        x = parseFloat(coords[0])
        y = parseFloat(coords[1])
        p = new Point(x, y, @)
        points.push p
      )

    points

  clearCachedObjects: ->

  ###
    Transformations
      rotate
      nudge
  ###

  rotate: (angle, center = @center()) ->
    @points.map (p) => p.rotate(angle, center)
    @metadata.angle += angle
    @metadata.angle %= 360

  scale: (x, y, origin = @center()) ->
    #console.log "scale polygon", x, y, origin.toString(), "#{@points}"
    @points.map (p) -> p.scale x, y, origin
    @commit()
    #console.log "scaled. #{@points}"

  nudge: (x, y) ->
    @points.map (p) -> p.nudge x, y
    @commit()

  contains: (posn) ->
    return posn.insideOf(@lineSegments())

  overlaps: (other) ->

    # Checks for overlap with another shape.
    # Redirects to appropriate method.

    # I/P: Polygon/Circle/Rect
    # O/P: true or false

    @['overlaps' + other.type.capitalize()](other)


  overlapsPolygon: (polygon) ->
    if @contains polygon.center() or polygon.contains(@center())
      return true
    for line in @lineSegments()
      if polygon.contains line.a or polygon.contains line.b
        return true
      for polyLine in polygon.lineSegments()
        if polyLine.intersects(line)
          return true
    return false


  overlapsCircle: (circle) ->

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)

  convertToPath: ->
    path = new Path(
      d: "M#{@points.at(0).x},#{@points.at(0).y}"
    )
    path.eyedropper @

    old = path.points.at(0)
    for p in @points.all().slice(1)
      lt = new LineTo(p.x, p.y, path, old, false)
      path.points.push lt
      old = lt

    path.points.close()
    path



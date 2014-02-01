class Circle extends Monsvg
  type: 'circle'

  scale: (factor, origin) ->
    @attr('r': (r) -> r * factor)
    @commit()

  scaleXY: (x, y, origin) ->
    # Conver to ellipse, then scale.

  points: []

  center: ->
    new Posn(@data.cx, @data.cy)

  xRange: ->
    new Range(@data.cx - @data.r, @data.cx + @data.r)

  yRange: ->
    new Range(@data.cy - @data.r, @data.cy + @data.r)

  overlaps: (other) ->

    ###
      Checks for overlap with another shape.
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    ###

    @['overlaps' + other.type.capitalize()](other)



  overlapsPolygon: (polygon) ->
    return true if polygon.contains @center()
    for line in polygon.lineSegments()
      if line.intersects(@)
        return true
    return false


  overlapsCircle: (circle) ->
    # TODO

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)

  nudge: (x, y) ->
    @attr
      cx: (cx) -> cx += x
      cy: (cy) -> cy -= y
    @commit()



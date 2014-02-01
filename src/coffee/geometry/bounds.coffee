class Bounds

  constructor: (@x, @y, @width, @height) ->
    if @x instanceof Array
      # A list of bounds
      minX = Math.min.apply(@, @x.map (b) -> b.x)
      @y   = Math.min.apply(@, @x.map (b) -> b.y)
      @x2  = Math.max.apply(@, @x.map (b) -> b.x2)
      @y2  = Math.max.apply(@, @x.map (b) -> b.y2)
      @x   = minX
      @width  = @x2 - @x
      @height = @y2 - @y


    else if @x instanceof Posn and @y instanceof Posn
      # A pair of posns

      x = Math.min(@x.x, @y.x)
      y = Math.min(@x.y, @y.y)
      @x2 = Math.max(@x.x, @y.x)
      @y2 = Math.max(@x.y, @y.y)
      @x = x
      @y = y
      @width = @x2 - @x
      @height = @y2 - @y

    else
      @x2 = @x + @width
      @y2 = @y + @height

    @xr = new Range(@x, @x + @width)
    @yr = new Range(@y, @y + @height)

  tl: -> new Posn(@x, @y)
  tr: -> new Posn(@x2, @y)
  br: -> new Posn(@x2, @y2)
  bl: -> new Posn(@x, @y2)

  clone: -> new Bounds(@x, @y, @width, @height)

  toRect: ->
    new Rect(
      x: @x,
      y: @y,
      width: @width,
      height: @height
    )

  center: ->
    new Posn(@x + (@width / 2), @y + (@height / 2))

  points: -> [new Posn(@x, @y), new Posn(@x2, @y), new Posn(@x2, @y2), new Posn(@x, @y2)]

  contains: (posn, tolerance) ->
    @xr.containsInclusive(posn.x, tolerance) and @yr.containsInclusive(posn.y, tolerance)

  overlapsBounds: (other, recur = true) ->
    @toRect().overlaps(other.toRect())

  nudge: (x, y) ->
    @x += x
    @x2 += x
    @y += y
    @y2 += y
    @xr.nudge x
    @yr.nudge y

  scale: (x, y, origin) ->
    tl = new Posn(@x, @y)
    br = new Posn(@x2, @y2)
    tl.scale(x, y, origin)
    br.scale(x, y, origin)

    @x = tl.x
    @y = tl.y
    @x2 = br.x
    @y2 = br.y

    @width *= x
    @height *= y

    @xr.scale x, origin
    @yr.scale y, origin

    @

  squareSmaller: (anchor) ->
    if @width < @height
      @height = @width
    else
      @width = @height

  centerOn: (posn) ->
    offset = posn.subtract @center()
    @nudge(offset.x, offset.y)

  fitTo: (bounds) ->
    sw = @width / bounds.width
    sh = @height / bounds.height
    sm = Math.max(sw, sh)
    new Bounds(0, 0, @width / sm, @height / sm)


  adjustElemsTo: (bounds) ->
    # Returns a method that can run on Monsvg objects
    # that will nudge and scale them so they go from these bounds
    # to look proportionately the same in the given bounds.
    offset = @tl().subtract bounds.tl()
    sw = @width / bounds.width
    sh = @height / bounds.height
    # Return a function that will adjust a given element to the canvas
    return (elem) ->
      elem.scale(1/sw, 1/sh, bounds.tl())
      elem.nudge(-offset.x, offset.y)

  annotateCorners: ->
    ui.annotations.drawDot(@tl())
    ui.annotations.drawDot(@tr())
    ui.annotations.drawDot(@bl())
    ui.annotations.drawDot(@br())


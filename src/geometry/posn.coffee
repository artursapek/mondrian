###

  Posn

    •
      (x, y)


  Lowest-level geometry class.

  Consists of x, y coordinates. Provides methods for manipulating or representing
  the point in two-dimensional space.

  Superclass: Point

###

class Posn

  constructor: (@x, @y, @zoomLevel = 1.0) ->
    # I/P:
    #   x: number
    #   y: number
    #
    #     OR
    #
    #   e: Event object with clientX and clientY values

    if @x instanceof Object
      # Support for providing an Event object as the only arg.
      # Reads the clientX and clientY values
      if @x.clientX? and @x.clientY?
        @y = @x.clientY
        @x = @x.clientX
      else if @x.left? and @x.top?
        @y = @x.top
        @x = @x.left
      else if @x.x? and @x.y?
        @y = @x.y
        @x = @x.x

    else if (typeof @x == "string") and (@x.mentions ",")
      # Support for giving a string of two numbers and a comma "12.3,840"
      split = @x.split(",").map parseFloat
      x = split[0]
      y = split[1]
      @x = x
      @y = y

    # That's fucking it.
    @

  # Rounding an you know

  cleanUp: ->
    # TODO
    # This was giving me NaN bullshit. Don't enable again until the app is stable
    # and we can test it properly
    return
    @x = cleanUpNumber @x
    @y = cleanUpNumber @y


  # Zoom compensation

  # By default, all Posns are interpreted as they are explicitly invoked. x is x, y is y.
  # You can call Posn.zoom() to ensure you're using a zoom-adjusted version of this Posn.
  #
  # In this case, x is x times the zoom level, and the same goes for y.
  #
  # Posn.unzoom() takes it back to zoom-agnostic mode - 1.0


  zoomed: (level = ui.canvas.zoom) ->
    # Return this Posn after ensuring it is at the given zoom level.
    # If no level is given, current zoom level of document is used.
    #
    # I/P: level: float (optional)
    #
    # O/P: adjusted Posn

    return @ if @zoomLevel is level

    @unzoomed()

    @alterValues (val) -> val *= level
    @zoomLevel = level
    @


  unzoomed: ->
    # Return this Posn after ensuring it is in 100% "true" mode.
    #
    # No I/P
    #
    # O/P: adjusted Posn

    return if @zoomLevel is 1.0

    @alterValues (val) => val /= @zoomLevel
    @zoomLevel = 1.0
    @


  setZoom: (@zoomLevel) ->
    @x /= @zoomLevel
    @y /= @zoomLevel
    @


  # Aliases:


  zoomedc: ->
    @clone().zoomed()


  unzoomedc: ->
    @clone.unzoomed()


  # Helper:


  alterValues: (fun) ->
    # Do something to all the values this Posn has. Kind of like map, but return is immediately applied.
    #
    # Since Posns get superclassed into Points which get superclassed into CurvePoints,
    # they may have x2, y2, x3, y3 attributes. This checks which ones it has and alters all of them.
    #
    # I/P: fun: one-argument function to be called on each of this Posn's values.
    #
    # O/P: self

    for a in ["x", "y", "x2", "y2", "x3", "y3"]
      @[a] = if @[a]? then fun(@[a]) else @[a]
    @


  toString: ->
    "#{@x},#{@y}"

  toJSON: ->
    x: @x
    y: @y

  toConstructorString: ->
    "new Posn(#{@x},#{@y})"


  nudge: (x, y) ->
    @x += x
    @y -= y

    @

  lerp: (b, factor) ->
    new Posn(@x + (b.x - @x) * factor, @y + (b.y - @y) * factor)

  gte: (p) ->
    @x >= p.x and @y >= p.y

  lte: (p) ->
    @x <= p.x and @y <= p.y

  directionRelativeTo: (p) ->
    "#{if @y < p.y then "t" else (if @y > p.y then "b" else "")}#{if @x < p.x then "l" else (if @x > p.x then "r" else "")}"

  squareUpAgainst: (p) ->
    # Takes another posn as an anchor, and nudges this one
    # so that it's on the nearest 45° going off of the anchor posn.

    xDiff = Math.abs(@x - p.x)
    yDiff = Math.abs(@y - p.y)
    direction = @directionRelativeTo p

    return p if (xDiff is 0) and (yDiff is 0)

    switch direction
      when "tl"
        if xDiff < yDiff
          @nudge(xDiff - yDiff, 0)
        else if yDiff < xDiff
          @nudge(0, xDiff - yDiff, 0)
      when "tr"
        if xDiff < yDiff
          @nudge(yDiff - xDiff, 0)
        else if yDiff < xDiff
          @nudge(0, xDiff - yDiff)
      when "br"
        if xDiff < yDiff
          @nudge(yDiff - xDiff, 0)
        else if yDiff < xDiff
          @nudge(0, yDiff - xDiff)
      when "bl"
        if xDiff < yDiff
          @nudge(xDiff - yDiff, 0)
        else if yDiff < xDiff
          @nudge(0, yDiff - xDiff)
      when "t", "b"
        @nudge(yDiff, 0)
      when "r", "l"
        @nudge(0, xDiff)
    @


  equal: (p) ->
    @x is p.x and @y is p.y

  min: (p) ->
    new Posn(Math.min(@x, p.x), Math.min(@y, p.y))

  max: (p) ->
    new Posn(Math.max(@x, p.x), Math.max(@y, p.y))

  angle360: (base) ->
    a = 90 - new LineSegment(base, @).angle
    return a + (if @x < base.x then 180 else 0)

  rotate: (angle, origin = new Posn(0, 0)) ->

    return @ if origin.equal @

    angle *= (Math.PI / 180)

    # Normalize the point on the origin.
    @x -= origin.x
    @y -= origin.y

    x = (@x * (Math.cos(angle))) - (@y * Math.sin(angle))
    y = (@x * (Math.sin(angle))) + (@y * Math.cos(angle))

    # Move points back to where they were.
    @x = x + origin.x
    @y = y + origin.y

    @

  scale: (x, y, origin = new Posn(0, 0)) ->
    @x += (@x - origin.x) * (x - 1)
    @y += (@y - origin.y) * (y - 1)
    @

  copy: (p) ->
    @x = p.x
    @y = p.y


  clone: ->
    # Just make a new Posn, and maintain the zoomLevel
    new Posn(@x, @y, @zoomLevel)


  snap: (to, threshold = Math.INFINITY) ->
    # Algorithm: bisect the line on this posn's x and y
    # coordinates and return the midpoint of that line.
    perpLine = @verti(10000)
    perpLine.rotate(to.angle360() + 90, @)
    perpLine.intersection to


  reflect: (posn) ->
    ###

      Reflect the point over an x and/or y axis

      I/P:
        posn: Posn

    ###

    x = posn.x
    y = posn.y

    return new Posn(x + (x - @x), y + (y - @y))

  distanceFrom: (p) ->
    new LineSegment(@, p).length

  perpendicularDistanceFrom: (ls) ->
    ray = @verti(1e5)
    ray.rotate(ls.angle360() + 90, @)
    #ui.annotations.drawLine(ray.a, ray.b)
    inter = ray.intersection ls
    if inter?
      ls = new LineSegment(@, inter)
      len = ls.length
      return [len, inter, ls]
    else
      return null

  multiplyBy: (s) ->
    switch typeof s
      when 'number'
        np = @clone()
        np.x *= s
        np.y *= s
        return np
      when 'object'
        np = @clone()
        np.x *= s.x
        np.y *= s.y
        return np

  multiplyByMutable: (s) ->
    @x *= s
    @y *= s

    if @x2?
      @x2 *= s
      @y2 *= s

    if @x3?
      @x3 *= s
      @y3 *= s

  add: (s) ->
    switch typeof s
      when 'number'
        return new Posn(@x + s, @y + s)
      when 'object'
        return new Posn(@x + s.x, @y + s.y)

  subtract: (s) ->
    switch typeof s
      when 'number'
        return new Posn(@x - s, @y - s)
      when 'object'
        return new Posn(@x - s.x, @y - s.y)

  setPrec: (@prec) ->

  setSucc: (@succ) ->


  ###
      I love you artur
      hackerkate nows the sick code
  ###

  inRanges: (xr, yr) ->
    xr.contains @x and yr.contains @y

  inRangesInclusive: (xr, yr) ->
    xr.containsInclusive(@x) and yr.containsInclusive(@y)

  verti: (ln) ->
    new LineSegment(@clone().nudge(0, -ln), @clone().nudge(0, ln))

  insideOf: (shape) ->
    # Draw a horizontal ray starting at this posn.
    # If it intersects the shape's perimeter an odd
    # number of times, the posn's inside of it.
    #
    #    _____
    #  /      \
    # |   o----X------------
    #  \______/
    #
    #  1 intersection - it's inside.
    #
    #    __         __
    #  /   \      /    \
    # |  o--X----X-----X---------
    # |      \__/      |
    #  \______________/
    #
    #  3 intersections - it's inside.
    #
    #  etc.

    if shape instanceof Polygon or shape instanceof Path
      ray = new LineSegment(@, new Posn(@x + 1e+20, @y))
      counter = 0
      shape.lineSegments().map((a) ->
        inter = a.intersection(ray)
        if inter instanceof Posn
          ++ counter
        else if inter instanceof Array
          counter += inter.length
      )

      # If there's an odd number of intersections, we are inside.
      return counter % 2 == 1

    # Rect
    # This one is trivial. Method lives in the Rect class.
    if shape instanceof Rect
      return shape.contains @


  dot: (v) ->
    @x * v.x + @y * v.y

  within: (tolerance, posn) ->
    Math.abs(@x - posn.x) < tolerance and Math.abs(@y - posn.y) < tolerance

  parseInt: ->
    @x = parseInt(@x, 10)
    @y = parseInt(@y, 10)


Posn.fromJSON = (json) ->
  new Posn(json.x, json.y)


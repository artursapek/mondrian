###
  Internal representation of a straight line segment

  a
   \
    \
     \
      \
       \
        \
         \
          b

  I/P:
    a: First point
    b: Second point

###


class LineSegment

  # LineSegment
  #
  # Allows you to do calculations on simple straight line segments.
  #
  # I/P : a, b Posns

  constructor: (@a, @b, @source = @toLineTo()) ->
    @calculate()

  calculate: ->

    # Do some calculations at startup:
    #
    # Slope, number
    # Angle, number (degrees)
    # Length, number
    #
    # No I/P
    # O/P : self

    @slope = (@a.y - @b.y) / (@b.x - @a.x)
    @angle = Math.atan(@slope) / (Math.PI / 180)
    @length = Math.sqrt(Math.pow((@b.x - @a.x), 2) + Math.pow((@b.y - @a.y), 2))
    @

  beginning: -> @a

  end: -> @a

  toString: ->
    # Returns as string in "x y" format.
    "(Line segment: #{@a.toString()} #{@b.toString()})"

  constructorString: ->
    "new LineSegment(#{@a.constructorString()}, #{@b.constructorString()})"

  angle360: ->
    @b.angle360 @a

  toLineTo: ->
    new LineTo(@b.x, @b.y)

  toSVGPoint: -> @toLineTo()

  reverse: ->
    # Note: this makes it lose its source
    new LineSegment(@b, @a)

  bounds: (useCached = false) ->
    if @boundsCached? and useCached
      return @boundsCached

    minx = Math.min(@a.x, @b.x)
    maxx = Math.max(@a.x, @b.x)
    miny = Math.min(@a.y, @b.y)
    maxy = Math.max(@a.y, @b.y)

    width = @width()
    height = @height()

    # Cache the bounds and return them at the same time

    @boundsCached = new Bounds(minx, miny, width, height)

  boundsCached: undefined

  rotate: (angle, origin) -> new LineSegment(@a.rotate(angle, origin), @b.rotate(angle, origin))

  width: ->
    Math.abs(@a.x - @b.x)

  height: ->
    Math.abs(@a.y - @b.y)

  xRange: ->
    # Returns a Range of x values covered
    #
    # O/P : a Range
    new Range(Math.min(@a.x, @b.x), Math.max(@a.x, @b.x))


  yRange: ->
    # Returns a Range of y values covered
    #
    # O/P : a Range
    new Range(Math.min(@a.y, @b.y), Math.max(@a.y, @b.y))


  xDiff: ->
    # Difference between x values of a and b points
    #
    # O/P : number

    Math.max(@b.x, @a.x) - Math.min(@b.x, @a.x)


  xbaDiff: ->
    # Difference between second point x and first point x
    #
    # O/P: number

    @b.x - @a.x


  yDiff: ->
    # Difference between y values of a and b points
    #
    # O/P : number

    Math.max(@b.y, @a.y) - Math.min(@b.y, @a.y)


  ybaDiff: ->
    # Difference between secoind point y and first point y
    #
    # O/P: number

    @b.y - @a.y


  yAtX: (x, extrapolate = true) ->
    if not extrapolate and not @xRange().containsInclusive(x)
      return null
    @a.y + ((x - @a.x) * @slope)


  xAtY: (y, extrapolate = true) ->
    if not extrapolate and not @yRange().containsInclusive(y)
      return null
    @a.x + ((y - @a.y) / @slope)


  ends: ->
    [a, b]

  posnAtPercent: (p) ->
    # I/P: p, number between 0 and 1
    # O/P: Posn at that point on the LineSegment

    new Posn(@a.x + (@b.x - @a.x) * p, @a.y + (@b.y - @a.y) * p)


  findPercentageOfPoint: (p) ->
    # I/P: A single Posn
    # O/P: A floating point value

    distanceA = p.distanceFrom(@a)
    distanceA / (distanceA + p.distanceFrom(@b))


  splitAt: (p, forced = null) ->
    # I/P: p, a float between 0 and 1
    #
    # O/P: Array with two LineSegments

    # So we're allowed to pass either a floating point value
    # or a Posn. Or a list of Posns.
    #
    # If given Posns, we have to calculate the float for each and then recur.

    if typeof p is "number"
      split = if forced then forced else @posnAtPercent p
      return [new LineSegment(@a, split), new LineSegment(split, @b)]

    else if p instanceof Array
      segments = []
      distances = {}

      for posn in p
        distances[posn.distanceFrom(@a)] = posn

      distancesSorted = Object.keys(distances).map(parseFloat).sort(sortNumbers)
       # ARE YOU FUICKING SERIOUS JAVASCRIPT

      nextA = @a

      for key in distancesSorted
        posn = distances[key]
        segments.push new LineSegment(nextA, posn)
        nextA = posn

      segments.push new LineSegment(nextA, @b)

      return segments


    else if p instanceof Posn
      # Given a single Posn, find how far along it is on the line
      # and recur with that floating point value.
      return [new LineSegment(@a, p), new LineSegment(p, @b)]

  midPoint: ->
    @splitAt(0.5)[0].b

  nudge: (x, y) ->
    @a.nudge(x, y)
    @b.nudge(x, y)

  scale: (x, y, origin) ->
    @a.scale(x, y, origin)
    @b.scale(x, y, origin)

  equal: (ls) ->
    return false if ls instanceof CubicBezier
    ((@a.equal ls.a) && (@b.equal ls.b)) || ((@a.equal ls.b) && (@b.equal ls.a))

  intersects: (s) ->
    # Does it have an intersection with ...?
    inter = @intersection(s)
    inter instanceof Posn or inter instanceof Array

  intersection: (s) ->
    # What is its intersection with ...?
    if s instanceof LineSegment
      return @intersectionWithLineSegment(s)
    else if s instanceof Circle
      return @intersectionWithCircle(s)
    else if s instanceof CubicBezier
      return s.intersectionWithLineSegment @


  intersectionWithLineSegment: (s) ->
    ###
      Get intersection with another LineSegment

      I/P : LineSegment

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###

    ana_s = s.xbaDiff() * (@a.y - s.a.y) - s.ybaDiff() * (@a.x - s.a.x)
    ana_m = @xbaDiff() * (@a.y - s.a.y) - @ybaDiff() * (@a.x - s.a.x)
    crossDiff  = s.ybaDiff() * @xbaDiff() - s.xbaDiff() * @ybaDiff()

    if crossDiff isnt 0
      anas = ana_s / crossDiff
      anam = ana_m / crossDiff

      if 0 <= anas and anas <= 1 and 0 <= anam and anam <= 1
        return new Posn(@a.x + anas * (@b.x - @a.x), @a.y + anas * (@b.y - @a.y))
      else
        return null
    else
      if ana_s is 0 or ana_m is 0
        # Coinicident (identical)
        return Infinity
      else
        # Parallel
        return 0


  intersectionWithEllipse: (s) ->
    ###
     Get intersection with an ellipse

     I/P: Ellipse

     O/P: null if no intersections, or Array of Posn(s) if there are

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###


    rx = s.data.rx
    ry = s.data.ry
    cx = s.data.cx
    cy = s.data.cy

    origin = new Posn(@a.x, @a.y)
    dir    = new Posn(@b.x - @a.x, @b.y - @a.y)
    center = new Posn(cx, cy)
    diff   = origin.subtract center
    mDir   = new Posn(dir.x / (rx * rx), dir.y / (ry * ry))
    mDiff  = new Posn(diff.x / (rx * rx), diff.y / (ry * ry))

    results = []

    a = dir.dot mDir
    b = dir.dot mDiff
    c = diff.dot(mDiff) - 1.0
    d = b * b - a * c

    if d < 0
      # Line is outside ellipse
      return null
    else if d > 0
      root = Math.sqrt d
      t_a = (-b - root) / a
      t_b = (-b + root) / a

      if (t_a < 0 or 1 < t_a) and (t_b < 0 or 1 < t_b)
        if (t_a < 0 and t_b < 0) and (t_a > 1 and t_b > 1)
          # Line is outside ellipse
          return null
        else
          # Line is inside ellipse
          return null
      else
        if 0 <= t_a and t_a <= 1
          results.push @a.lerp @b, t_a
        if 0 <= t_b and t_b <= 1
          results.push @a.lerp @b, t_b
    else
        t = -b / a
        if 0 <= t and t <= 1
          results.push @a.lerp @b, t
        else
          return null

    results


  intersectionWithCircle: (s) ->
    ###
      Get intersection with a circle

      I/P : Circle

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###

    a = Math.pow(@xDiff(), 2) + Math.pow(@yDiff(), 2)
    b = 2 * ((@b.x - @a.x) * (@a.x - s.data.cx) + (@b.y - @a.y) * (@a.y - s.data.cy))
    cc = Math.pow(s.data.cx, 2) + Math.pow(s.data.cy, 2) + Math.pow(@a.x, 2) + Math.pow(@a.y, 2) -
         2 * (s.data.cx * @a.x + s.data.cy * @a.y) - Math.pow(s.data.r, 2)
    deter = b * b - 4 * a * cc

    if deter < 0
      return null # No intersection
    else if deter is 0
      return 0 # Tangent
    else
      e = Math.sqrt(deter)
      u1 = (-b + e) / (2 * a)
      u2 = (-b - e) / (2 * a)

      if (u1 < 0 or u1 > 1) and (u2 < 0 or u2 > 1)
        if (u1 < 0 and u2 < 0) or (u1 > 1 and u2 > 1)
          return null # No intersection
        else
          return true # It's inside
      else
        ints = []

        if 0 <= u1 and u1 <= 1
          ints.push @a.lerp(@b, u1)

        if 0 <= u2 and u2 <= 1
          ints.push @a.lerp(@b, u2)

        return ints



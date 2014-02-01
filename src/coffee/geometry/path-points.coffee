###

  Path points

  MoveTo
    Mx,y
    Begin a path at x,y

  LineTo
    Lx,y
    Draw straight line from pvx,pvy to x,y

  CurveTo
    Cx1,y1 x2,y2 x,y
    Draw a line to x,y.
    x1,y1 is the control point put on the previous point
    x2,y2 is the control point put on this point (x,y)

  SmoothTo
    Sx2,y2 x,y
    Shorthand for curveto. x1,y1 becomes x2,y2 from previous CurveTo.

  HorizTo
    Hx
    Draw a horizontal line inheriting the y-value from precessor

  VertiTo
    Vy
    Draw a vertical line inheriting the x-value from precessor

###


class MoveTo extends Point
  constructor: (@x, @y, @owner, @prec, @rel) ->
    super @x, @y, @owner


  relative: ->
    if @at is 0
      @rel = false
      return @
    else
      return @ if @rel

      precAbs = @prec.absolute()
      x = precAbs.x
      y = precAbs.y

      m = new MoveTo(@x - x, @y - y, @owner)
      m.rel = true
      return m

  absolute: ->
    if @at is 0
      @rel = false
      return @
    else
      return @ if not @rel

      precAbs = @prec.absolute()
      x = precAbs.x
      y = precAbs.y

      m = new MoveTo(@x + x, @y + y, @owner)
      m.rel = false
      return m

    new Point(point, @owner) for point in points.match(/[MLCSHV][\-\de\.\,\-\s]+/gi)

  p2: ->
    if @antlers?.succp2?
      return new Posn(@antlers.succp2.x, @antlers.succp2.y)
    else
      return null

  toString: -> "#{if @rel then "m" else "M"}#{@x},#{@y}"

  toLineSegment: ->
    @prec.toLineSegment()

  # I know this can be abstracted somehow with bind and apply but I
  # don't have time to figure that out before launch - already wasted time trying
  clone: -> new MoveTo(@x, @y, @owner, @prec, @rel)


class LineTo extends Point
  constructor: (@x, @y, @owner, @prec, @rel) ->
    super @x, @y, @owner

  relative: ->
    return @ if @rel

    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    l = new LineTo(@x - x, @y - y, @owner)
    l.rel = true
    return l

  absolute: ->
    return @ if not @rel
    if @absoluteCached
      return @absoluteCached


    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    l = new LineTo(@x + x, @y + y, @owner)
    l.rel = false

    @absoluteCached = l

    return l

  toString: -> "#{if @rel then 'l' else 'L'}#{@x},#{@y}"

  clone: -> new LineTo(@x, @y, @owner, @prec, @rel)




class HorizTo extends Point
  constructor: (@x, @owner, @prec, @rel) ->
    @inheritFromPrec(@prec)
    super @x, @y, @owner

  inheritFromPrec: (@prec) ->
    @y = @prec.absolute().y

  toString: ->
    "#{if @rel then 'h' else 'H'}#{@x}"

  convertToLineTo: ->
    # Converts and replaces this with an equivalent LineTo
    # Returns the resulting LineTo so it can be operated on.
    lineTo = new LineTo(@x, @y)
    @replaceWith lineTo
    lineTo

  rotate: (a, origin) ->
    @convertToLineTo().rotate(a, origin)

  absolute: ->
    return @ if not @rel
    return @absoluteCached if @absoluteCached
    @absoluteCached = new HorizTo(@x + @prec.absolute().x, @owner, @prec, false)

  relative: ->
    return @ if @rel
    new HorizTo(@x - @prec.absolute().x, @owner, @prec, true)

  clone: -> new HorizTo(@x, @owner, @prec, @rel)



class VertiTo extends Point
  constructor: (@y, @owner, @prec, @rel) ->
    @inheritFromPrec(@prec)
    super @x, @y, @owner

  inheritFromPrec: (@prec) ->
    @x = @prec.absolute().x

  toString: -> "#{if @rel then 'v' else 'V'}#{@y}"

  convertToLineTo: ->
    # Converts and replaces this with an equivalent LineTo
    # Returns the resulting LineTo so it can be operated on.
    lineTo = new LineTo(@x, @y)
    @replaceWith lineTo
    lineTo

  rotate: (a, origin) ->
    @convertToLineTo().rotate(a, origin)

  absolute: ->
    return @ if not @rel
    return @absoluteCached if @absoluteCached
    @absoluteCached = new VertiTo(@y + @prec.absolute().y, @owner, @prec, false)

  relative: ->
    return @ if @rel
    new VertiTo(@y - @prec.absolute().y, @owner, @prec, true)

  clone: -> new VertiTo(@y, @owner, @prec, @rel)







###

  CurvePoint

  A Point that has handles. Builds the handles in its constructor.

###

class CurvePoint extends Point
  constructor: (@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel) ->
    ###

      This Class just extends into CurveTo and SmoothTo as a way of abstracting out the curve
      handling the control points. It has two control points in addition to the base point (handled by super)

      Each point has a predecessor and a successor (in terms of line segments).

      It has two control points:
        (@x2, @y2) is the first curve control point (p2), which becomes @p2h
        (@x3, @y3) is the second (p3), which becomes @p3h
      (Refer to ASCII art at top of cubic-bezier-line-segment.coffee for point name reference)

      Dragging these mofos will alter the correct control point(s), which will change the curve

      I/P:
        x2, y2: control point (p2)
        x3, y3: control point (p3)
        x, y:   next base point (like any other point)
        owner:  elem that owns this shape (supered into Point)
        prec:   point that comes before it
        rel:    bool - true if it's relative or false if it's absolute

    ###

    super @x, @y, @owner


  p2: ->
    new Posn(@x2, @y2)


  p3: ->
    new Posn(@x3, @y3)


  p: ->
    new Posn(@x, @y)


  absorb: (p, n) ->
    # I/P: p, Posn
    #      n, 2 or 3 (p2 or p3)
    # Given a Posn/Point and an int (2 or 3), sets @x2/@x3 and @y2/@y3 to p's coordinats.
    # Abstracted method for updating a specific bezier curve control point.

    @["x#{n}"] = p.x
    @["y#{n}"] = p.y


  show: ->
    return @ if not @owner # Orphan points should be ignored (usually used in testing)
    super


  cleanUp: ->
    return
    @x2 = cleanUpNumber @x2
    @y2 = cleanUpNumber @y2
    @x3 = cleanUpNumber @x3
    @y3 = cleanUpNumber @y3
    super


  scale: (x, y, origin) ->
    @absorb(@p2().scale(x, y, origin), 2)
    @absorb(@p3().scale(x, y, origin), 3)
    super x, y, origin


  rotate: (a, origin) ->
    @absorb(@p2().rotate(a, origin), 2)
    @absorb(@p3().rotate(a, origin), 3)
    super a, origin


  relative: ->
    return @ if @rel

    # Assuming it's absolute now we want to subtract the precessor...
    # The base case here is a MoveTo, which will always be absolute.
    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    # Now we make a new one of whatever this is.
    # @constructor will point to either CurveTo or SmoothTo, in this case.
    # Since those both take the same arguments, simply subtract the precessor's absolute coords
    # from this one's absolute coords and we're in business!
    args = [@x2 - x, @y2 - y, @x3 - x, @y3 - y, @x - x, @y - y, @owner, @prec]
    if @constructor is SmoothTo
      args = args.slice(2)
    args.unshift(null)

    c = new (Function.prototype.bind.apply(@constructor, args))
    c.rel = true
    return c

  absolute: ->
    # This works the same way as relative but opposite.
    return @ if not @rel

    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    args = [@x2 + x, @y2 + y, @x3 + x, @y3 + y, @x + x, @y + y, @owner, @prec]
    if @constructor is SmoothTo
      args = args.slice(2)
    args.unshift(null)

    c = new (Function.prototype.bind.apply(@constructor, args))

    c.rel = false

    return c


class CurveTo extends CurvePoint
  constructor: (@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel) ->
    super @x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel

  toString: -> "#{if @rel then 'c' else 'C'}#{@x2},#{@y2} #{@x3},#{@y3} #{@x},#{@y}"

  reverse: ->
    new CurveTo(@x3, @y3, @x2, @y2, @x, @y, @owner, @prec, @rel).inheritPosition @

  clone: -> new CurveTo(@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel)


class SmoothTo extends CurvePoint
  constructor: (@x3, @y3, @x, @y, @owner, @prec, @rel) ->

    @inheritFromPrec @prec

    super @x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel

  inheritFromPrec: (@prec) ->
    # Since a SmoothTo's p2 is a reflection of its precessor's p3 over
    # its previous point, we need to query that info from its precessor.
    if @prec instanceof CurvePoint
      precAbs = @prec.absolute()
      p2 = new Posn(precAbs.x3, precAbs.y3).reflect precAbs
    else
      p2 = new Posn(@x, @y) # No p2 to inherit, so just nullify it

    @x2 = p2.x
    @y2 = p2.y


  toCurveTo: (p2 = null) ->
    if p2 is null
      if @prec instanceof CurvePoint
        p2 = @prec.p3().reflect(@prec.p())
      else
        p2 = new Posn(@x, @y)

    ct = new CurveTo(p2.x, p2.y, @x3, @y3, @x, @y, @owner, @prec, @rel)
    ct.at = @at
    ct

  replaceWithCurveTo: (p2 = null) ->
    @replaceWith(@toCurveTo(p2))

  toString: -> "#{if @rel then 's' else 'S'}#{@x3},#{@y3} #{@x},#{@y}"

  reverse: -> new CurveTo @x3, @y3, @x2, @y2, @x, @y, @owner, @prec, @rel

  clone: -> new SmoothTo(@x3, @y3, @x, @y, @owner, @prec, @rel)


###

  Line

###


class Line extends Monsvg
  type: 'line'


  a: ->
    new Posn(@data.x1, @data.y1)


  b: ->
    new Posn(@data.x2, @data.y2)


  absorbA: (a) ->
    @data.x1 = a.x
    @data.y1 = a.y


  absorbB: (b) ->
    @data.x2 = b.x
    @data.y2 = b.y


  asLineSegment: ->
    new LineSegment(@a(), @b())


  fromLineSegment: (ls) ->

    # Inherit points from a LineSegment
    #
    # I/P : LineSegment
    #
    # O/P : self

    @absorbA(ls.a)
    @absorbB(ls.b)


  xRange: -> @asLineSegment().xRange()


  yRange: -> @asLineSegment().yRange()


  nudge: (x, y) ->
    @data.x1 += x
    @data.x2 += x
    @data.y1 -= y
    @data.y2 -= y
    @commit()


  scale: (x, y, origin) ->
    @absorbA @a().scale(x, y, origin)
    @absorbB @b().scale(x, y, origin)
    @commit()


  overlapsRect: (rect) ->
    ls = @asLineSegment()

    return true if @a().insideOf rect
    return true if @b().insideOf rect

    for l in rect.lineSegments()
      return true if l.intersects ls
    false





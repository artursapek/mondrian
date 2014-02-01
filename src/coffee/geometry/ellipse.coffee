###

  Ellipse

###


class Ellipse extends Monsvg
  type: 'ellipse'


  constructor: (@data) ->
    super @data

    @data.cx = parseFloat @data.cx
    @data.cy = parseFloat @data.cy
    @data.rx = parseFloat @data.rx
    @data.ry = parseFloat @data.ry


  xRange: ->
    new Range(@data.cx - @data.rx, @data.cx + @data.rx)


  yRange: ->
    new Range(@data.cy - @data.ry, @data.cy + @data.ry)


  c: ->
    new Posn(@data.cx, @data.cy)


  top: ->
    new Posn(@data.cx, @data.cy - @data.ry)


  right: ->
    new Posn(@data.cx + @data.rx, @data.cy)


  bottom: ->
    new Posn(@data.cx, @data.cy + @data.ry)


  left: ->
    new Posn(@data.cx - @data.rx, @data.cy)


  overlapsRect: (r) ->
    for l in r.lineSegments()
      if (l.intersectionWithEllipse @) instanceof Array
        return true


  nudge: (x, y) ->
    @data.cx += x
    @data.cy -= y
    @commit()


  scale: (x, y, origin) ->
    c = @c().scale(x, y, origin)
    @data.cx = c.x
    @data.cy = c.y
    @data.rx *= x
    @data.ry *= y
    @commit()


  convertToPath: ->
    p = new Path(
      d: "M#{@data.cx},#{@data.cy - @data.ry}")

    p.eyedropper @

    top = @top()
    right = @right()
    bottom = @bottom()
    left = @left()

    rx = @data.rx
    ry = @data.ry

    ky = Math.KAPPA * ry
    kx = Math.KAPPA * rx

    p.points.push new CurveTo(top.x + kx, top.y, right.x, right.y - ky, right.x, right.y)
    p.points.push new CurveTo(right.x, right.y + ky, bottom.x + kx, bottom.y, bottom.x, bottom.y)
    p.points.push new CurveTo(bottom.x - kx, bottom.y, left.x, left.y + ky, left.x, left.y)
    p.points.push new CurveTo(left.x, left.y - ky, top.x - kx, top.y, top.x, top.y)
    p.points.close()
    p.points.drawBasePoints()

    p.updateDataArchived()

    p



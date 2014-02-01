###

  Helper geometry layer

###

annotations =

  uiMainColor: '#4982E0'

  drawLine: (a, b, stroke = @uiMainColor) ->
    return if not dom.main

    line = new Line(
      x1: a.x
      y1: a.y
      x2: b.x
      y2: b.y
      fill: 'none'
      stroke: stroke
    )

    line.commit()
    line.appendTo('svg#annotations', false)
    line

  drawDot: (p, fill = @uiMainColor, r = 3) ->
    return if not dom.main

    dot = new Circle(
      cx: p.x
      cy: p.y
      r: r
      fill: fill
      stroke: 'none'
    )

    dot.commit()
    dot.appendTo('svg#annotations', false)
    dot

  drawDots: (posns, color, r) ->
    posns.forEach (posn) =>
      @drawDot posn, color, r

  clear: ->
    $("#annotations").empty()


ui.annotations = annotations

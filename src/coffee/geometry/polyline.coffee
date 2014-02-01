# Exactly like a polygon, but not closed

class Polyline extends Polygon

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

    path



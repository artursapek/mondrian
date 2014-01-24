# Geometry conversions and operations

lab.conversions =
  pathSegment: (a, b = a.succ) ->
    # Returns the LineSegment or BezierCurve that connects two bezier points
    #   (MoveTo, LineTo, CurveTo, SmoothTo)
    #
    # I/P:
    #   a: first point
    #   b: second point
    # O/P: LineSegment or CubiBezier


    if b instanceof LineTo or b instanceof MoveTo or b instanceof HorizTo or b instanceof VertiTo
      return new LineSegment(new Posn(a.x, a.y), new Posn(b.x, b.y), b)

    else if b instanceof CurveTo
      # CurveTo creates a CubicBezier

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b)

    else if b instanceof SmoothTo
      # SmoothTo creates a CubicBezier also, but it derives its p2 as the
      # reflection of the previous point's p3 reflected over its p4

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b)


  nextSubstantialPathSegment: (point) ->
    # Skip any points within 1e-6 of each other
    while point.within(1e-6, point.succ)
      point = point.succ

    return @pathSegment point, point.succ

  previousSubstantialPathSegment: (point) ->
    # Skip any points within 1e-6 of each other
    while point.within(1e-6, point.prec)
      point = point.prec

    return @pathSegment point, point.prec

  stringToAlop: (string, owner) ->
    # Given a d="M204,123 C9023........." string,
    # return an array of Points.

    results = []
    previous = undefined

    all_matches = string.match(CONSTANTS.MATCHERS.POINT)

    for point in all_matches
      # Point's constructor decides what kind of subclass to make
      # (MoveTo, CurveTo, etc)
      p = new Point(point, owner, previous)

      if p instanceof Point
        p.setPrec previous if previous?
        previous = p # Set it for the next point

        # Don't remember why I did this.
        if (p instanceof SmoothTo) and (owner instanceof Point)
          p.setPrec owner

        results.push p

      else if p instanceof Array
        # There's an edge case where you can get an array of a MoveTo followed by LineTos.
        # Terrible function signature design, I know
        # TODO fix this hack garbage
        if previous?
          p[0].setPrec previous
          p.reduce (a, b) -> b.setPrec a

        results = results.concat p

    results




class Ray extends LineSegment

  constructor: (@a, @angle) ->
    # subclass of LineSegment
    # Just makes a LineSegment that's insanely long lol
    #
    # I/P:
    #   a: Posn
    #   angle: number from 0 to 360
    super @a, @a.clone().nudge(0, -1e5).rotate(@angle, @a)



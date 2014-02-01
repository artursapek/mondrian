###

  PointsList

  Stores points, keeps them in order, lets you do shit
  Basically a linked-list.

###


class PointsList
  constructor: (alop, @owner, @segments = []) ->
    # Build this thing out of PointsSegment objects.
    #
    # I/P:
    #   alop: a list of Points or a string
    #   @owner: Mongsvg element these points belong to

    # This is just one big for-loop with intermediate calls
    # to commitSegment every time we run into a MoveTo.
    #
    # Effectively we create many PointsSegments starting with MoveTos
    # and going until the next MoveTo (which is the start of the
    # next PointsSegment)

    # First, if we were given a string of SVG points let's
    # parse that into what we work with, an array of Points
    if typeof alop is "string"
      alop = lab.conversions.stringToAlop alop, @owner

    # Now set up some helper variables to keep track of things

    # The point segment we are working on right now
    # This gets shoved into @segments when commitSegment is called
    accumulatedSegment = []

    # The last point we made.
    # Used to keep track of prec and succ relationships.
    lastPoint = undefined

    commitSegment = =>
      # Helper method that gets called for every MoveTo we bump into.
      # Basically we stack points up starting with a MoveTo and
      # until the next MoveTo, then we call this and it takes
      # that stack and makes a PointsSegment with them.

      return if accumulatedSegment.length is 0

      # Make the PointsSegment
      sgmt = new PointsSegment accumulatedSegment, @

      # Keep track of which is our last segment
      @lastSegment = sgmt

      # Only set it as the first segment if that hasn't been set yet
      # (which would mean that it is indeed the first segment)
      if @firstSegment is null
        @firstSegment = sgmt

      # Commit the PointsSegment to this PointsList's @segments!
      @segments.push sgmt

      # Reset the accumulated points stack array
      accumulatedSegment = []

    # We can call PointsList with pre-constructed PointsSegments.
    # In this case, set up these two variables manually.
    if @segments.length isnt 0
      @firstSegment = @segments[0]
      @lastSegment = @segments[@segments.length - 1]

    return if alop.length is 0 # Initiate empty PointsList

    # Now we iterate thru the points and split them into PointsSegment objects
    for own ind, point of alop

      # Get integer of index number, save it as point.at attribute
      ind = parseInt ind, 10
      point.at = ind

      # Set the @first and @last aliases as we get to them
      @first = point if ind is 0
      @last = point if ind is alop.length - 1

      point.setPrec (if lastPoint? then lastPoint else alop[alop.length - 1])
      lastPoint?.setSucc point

      if point instanceof MoveTo
        # Close up the last segment, start a new one.
        commitSegment()

      accumulatedSegment.push point

      # Now we're done, so set this as the lastPoint for the next point ;^)
      lastPoint = point

    # Get the last one we never got to.
    commitSegment()
    lastPoint.setSucc @first

  first: null
  last: null

  firstSegment: null
  lastSegment: null

  closed: false

  moveSegmentToFront: (segment) ->
    return if not (@segments.has segment)
    @segments = @segments.cannibalizeUntil segment

  movePointToFront: (point) ->
    @moveSegmentToFront point.segment
    point.segment.movePointToFront point


  firstPointThatEquals: (point) ->
    @filter((p) -> p.equal(point))[0]


  closedOnSameSpot: ->
    @closed and (@last.equal @first)


  length: ->
    @segments.reduce (a, b) ->
      a + b.points.length
    , 0


  all: ->
    pts = []
    for s in @segments
      pts = pts.concat s.points
    pts


  renumber: ->
    @all().map (p, i) ->
      p.at = i
      p

  pushSegment: (sgmt) ->
    @lastSegment = sgmt
    @segments.push sgmt


  push: (point, after) ->
    # Add a new point!

    if @segments.length is 0
      @pushSegment new PointsSegment [], @

    point.owner = @owner

    if not after?
      point.at = @lastSegment.points.length
      @lastSegment.points.push point

      if @last?
        @last.setSucc point
        point.setPrec @last
      else
        point.setPrec point

      if @first?
        @first.setPrec point
        point.setSucc @first
      else
        point.setSucc point

      @last = point

      return @


  replace: (old, replacement) ->
    @segmentContaining(old).replace old, replacement


  reverse: ->
    # Reverse the order of the points, while maintaining the exact same shape.
    new PointsList([], @owner, @segments.map (s) -> s.reverse())


  at: (n) ->
    @segmentContaining(parseInt(n, 10)).at n

  close: ->
    @closed = true
    @

  relative: ->
    @segments = @segments.map (s) ->
      s.points = s.points.map (p) ->
        abs = p.relative()
        abs.inheritPosition p
        abs
      s
    @

  absolute: ->
    @segments = @segments.map (s) ->
      s.points = s.points.map (p) ->
        abs = p.absolute()
        abs.inheritPosition p
        abs
      s
    @

  drawBasePoints: ->
    @map (p) ->
      p.baseHandle?.remove()
      p.draw()
      p.makeAntlers()
    @

  removeBasePoints: ->
    @map (p) ->
      p.baseHandle?.remove()
    @


  hide: ->
    @map (p) -> p.hide()

  unhover: ->
    @map (p) -> p.unhover()

  join: (x) ->
    @all().join x

  segmentContaining: (a) ->
    if typeof a is "number"
      for s in @segments
        if s.startsAt <= a
          segm = s
        else break
      return segm
    else
      segments = @segments.filter (s) ->
        s.points.indexOf(a) > -1
      return segments[0] if segments.length is 1
    return []


  hasPointWithin: (tolerance, point) ->
    @filter((p) -> p.within(tolerance, point)).length > 0


  remove: (x) ->
    if typeof x is "number"
      x = @at x
    if x instanceof Array
      for p in x
        @remove p
    else if x instanceof Point
      @segmentContaining(x).remove x

  filter: (fun) ->
    @all().filter fun

  filterSegments: (fun) ->
    @segments.map (segment) ->
      new PointsSegment(segment.points.filter fun)

  fetch: (cl) ->
    # Given a class like MoveTo or CurveTo or Point or CurvePoint,
    # return all points of that class.
    @all().filter (p) -> p instanceof cl

  map: (fun) ->
    @segments.map (s) ->
      s.points.map fun

  forEach: (fun) ->
    @segments.forEach (s) ->
      s.points.forEach fun

  mapApply: (fun) ->
    @segments.map (s) ->
      s.points = s.points.map fun

  xRange: ->
    xs = @all().map (p) -> p.x
    new Range(Math.min.apply(@, xs), Math.max.apply(@, xs))

  yRange: ->
    ys = @all().map (p) -> p.y
    new Range(Math.min.apply(@, ys), Math.max.apply(@, ys))

  toString: ->
    @segments.join(' ') + (if @closed then "z" else "")

  insideOf: (other) ->
    @all().filter (p) ->
      p.insideOf other

  notInsideOf: (other) ->
    @all().filter (p) ->
      !p.insideOf other

  withoutMoveTos: ->
    new PointsList([], @owner, @filterSegments (p) ->
        not (p instanceof MoveTo)
    )


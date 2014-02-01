###

  Point



     o -----------
    /
   /
  /

  Tangible body for posn.
  Stored in PointsList for every shape.
  Comes in many flavors for a Path:
    MoveTo
    LineTo
    HorizTo
    VertiTo
    CurvePoint
      CurveTo
      SmoothTo

  This is the most heavily sub-classed class, even heavier than Monsvg.
  It's also the most heavily used, since all shapes are made of many of these.

  Needless to say, this is a very important class.
  Its efficiency basically decides the entire application's speed.
  (Not sure it's as good as it could be right now)

###

class Point extends Posn

  constructor: (@x, @y, @owner) ->
    @constructArgs = arguments
    return if (not @x?) and (not @y?)


    # Robustness principle!
    # You can make a Point in many ways.
    #
    #   Posn: Give a posn, and it will just inherit the x and y positions
    #   Event:
    #     Give it an event with clientX and clientY
    #   Object:
    #     Give it a generic Object with an x and y
    #   String:
    #     Give it an SVG string like "M10 20"
    #
    # It will do what's most appropriate in each case; for the first three
    # it will just inherit x and y values from the input. In the third case
    # given an SVG string it will actually return a subclass of itself based
    # on what the string is.

    if @x instanceof Posn
      @owner = @y
      @y = @x.y
      @x = @x.x
    else if @x instanceof Object
      @owner = @y
      if @x.clientX?
        # ...then it's an Event object
        @y = @x.clientY
        @x = @x.clientX
      else if @x.x? and @x.y?
        # ...then it's some generic object
        @y = @x.y
        @x = @x.x
    else if typeof @x is "string"
      # Call signature in this case:
      # new Point(pointString, owner, prec)
      # Example in lab.conversions.stringToAlop
      prec   = @owner if @owner?
      @owner = @y if @y?
      p = @fromString(@x, prec)
      return p

    console.warn('NaN x') if isNaN @x
    console.warn('NaN y') if isNaN @y

    @_flags = []

    @makeAntlers()

    super @x, @y



  fromString: (point, prec) ->
    # Given a string like "M 10.2 502.19"
    # return the corresponding Point.
    # Returns one of:
    #   MoveTo
    #   CurveTo
    #   SmoothTo
    #   LineTo
    #   HorizTo
    #   VertiTo

    patterns =
      moveTo:   /M[^A-Za-z]+/gi
      lineTo:   /L[^A-Za-z]+/gi
      curveTo:  /C[^A-Za-z]+/gi
      smoothTo: /S[^A-Za-z]+/gi
      horizTo:  /H[^A-Za-z]+/gi
      vertiTo:  /V[^A-Za-z]+/gi

    classes =
      moveTo:   MoveTo
      lineTo:   LineTo
      curveTo:  CurveTo
      smoothTo: SmoothTo
      horizTo:  HorizTo
      vertiTo:  VertiTo

    lengths =
      moveTo:   2
      lineTo:   2
      curveTo:  6
      smoothTo: 4
      horizTo:  1
      vertiTo:  1

    pairs = /[-+]?\d*\.?\d*(e\-)?\d*/g

    # It's possible in SVG to list several sets of coords
    # for one character key. For example, "L 10 20 40 50"
    # is actually two seperate LineTos: a (10, 20) and a (40, 50)
    #
    # So we build the point(s) into an array, and return points[0]
    # if there's one, or the whole array if there's more.
    points = []

    for key, val of patterns
      # Find which pattern this string matches.
      # This check uses regex to also validate the point's syntax at the same time.

      matched = point.match val

      if matched isnt null

        # Matched will not be null when we find the correct point from the 'pattern' regex collection.
        # Match for the cooridinate pairs inside this point (1-3 should show up)
        # These then get mapped with parseFloat to get the true values, as coords

        coords = (point.match pairs).filter((p) -> p.length > 0).map parseFloat

        relative = point.substring(0,1).match(/[mlcshv]/) isnt null # Is it lower-case? So it's relative? Shit!

        clen = coords.length
        elen = lengths[key] # The expected amount of values for this kind of point

        # If the number of coordinates checks out, build the point(s)
        if clen % elen is 0

          sliceAt = 0

          for i in [0..(clen / elen) - 1]
            set = coords.slice(sliceAt, sliceAt + elen)

            if i > 0
              if key is "moveTo"
                key = "lineTo"

            values = [null].concat set

            values.push @owner # Point owner
            values.push prec
            values.push relative

            debugger if values.join(' ').mentions "NaN"

            # At this point, values should be an array that looks like this:
            #   [null, 100, 120, 300.5, 320.5, Path]
            # The amount of numbers depends on what kind of point we're making.

            # Build the point from the appropriate constructor

            constructed = new (Function.prototype.bind.apply(classes[key], values))

            points.push constructed

            sliceAt += elen

        else
          # We got a weird amount of points. Dunno what to do with that.
          # TODO maybe I should actually rethink this later to be more robust: like, parse what I can and
          # ignore the rest. Idk if that would be irresponsible.
          throw new Error("Wrong amount of coordinates: #{point}. Expected #{elen} and got #{clen}.")

        # Don't keep looking
        break

    if points.length is 0
      # We have no clue what this is, cuz
      throw new Error("Unreadable path value: #{point}")

    if points.length is 1
      return points[0]
    else
      return points

  select: ->
    @show()
    @showHandles()
    @antlers.refresh()
    @baseHandle.setAttribute 'selected', ''
    @

  deselect: ->
    @baseHandle.removeAttribute 'selected'
    @hideHandles?()
    @hide()
    @

  draw: ->
    # Draw the main handle DOM object.
    @$baseHandle = $('<div class="transform handle point"></div>')

    @baseHandle = @$baseHandle[0]
    # Set up the handle to have a connection to this elem

    if @at is undefined
      debugger if not (@ instanceof AntlerPoint)

    @baseHandle.setAttribute 'at', @at
    @baseHandle.setAttribute 'owner', @owner.metadata.uuid if @owner?

    @updateHandle @baseHandle, @x, @y
    dom.ui?.appendChild @baseHandle

    @


  makeAntlers: () ->
    if @succ?
      p2 = if @succ.p2? then @succ.p2()
    else
      p2 = null
    p3 = if @p3? then @p3() else null
    @antlers = new Antlers(@, p3, p2)
    @

  showHandles: ->
    @antlers.show()

  hideHandles: ->
    @antlers.hide()

  absoluteCached: undefined #

  prec: null
  succ: null

  actionHint: ->
    @baseHandle.setAttribute 'action', ''

  hideActionHint: ->
    @baseHandle.removeAttribute 'action'


  updateHandle: (handle = @baseHandle, x = @x, y = @y) ->
    return if handle is undefined

    # Since Point objects actually affect the data for Paths but they always
    # need to be the same size on the UI, their zoom behavior
    # falls in the annotation category. (#1)
    #
    # That means we need to scale its UI rep without actually affecting
    # the source of its coordinates. In this case, we simply scale the
    # left and top attributes of the DOM point handle.

    handle.style.left = x * ui.canvas.zoom
    handle.style.top = y * ui.canvas.zoom
    @


  inheritPosition: (from) ->
    # Maintain linked-list order in a PointsList
    @at         = from.at
    @prec       = from.prec
    @succ       = from.succ
    @prec.succ  = @
    @succ.prec  = @
    @owner      = from.owner
    @baseHandle = from.baseHandle if from.baseHandle?
    @



  nudge: (x, y, checkForFirstOrLast = true) ->
    old = @clone()
    super x, y
    @antlers?.nudge(x, y)
    @updateHandle()

    if @owner.type is 'path'
      if checkForFirstOrLast and @owner.points.closed
        # Check if this is the point overlapping the original MoveTo.
        if (@ is @owner.points.first) and @owner.points.last.equal old
          @owner.points.last.nudge(x, y, false)
        else if (@ is @owner.points.last) and @owner.points.first.equal old
          @owner.points.first.nudge(x, y, false)


  rotate: (a, origin) ->
    super a, origin
    @antlers?.rotate(a, origin)
    @updateHandle()


  scale: (x, y, origin, angle) ->
    super x, y, origin, angle
    @antlers?.scale(x, y, origin, angle)
    @updateHandle()
    @


  replaceWith: (point) ->
    @owner.points.replace(@, point)


  toPosn: ->
    new Posn(@x, @y)


  toLineSegment: ->
    new LineSegment @prec, @


  ###

    Linked list action

  ###

  setSucc: (succ) ->
    @succ = succ
    succ.prec = @

  setPrec: (prec) ->
    prec.setSucc @


  ###

   Visibility functions for the UI

  ###

  show: ->
    return if not @baseHandle?
    if not @baseHandle
      @draw()
    @baseHandle.style.display = 'block'
    @baseHandle.style.opacity = 1


  hide: (force = false) ->
    return if not @baseHandle?
    if not @baseHandle.hasAttribute('selected') or force
      @baseHandle.style.opacity = 0
      @baseHandle.removeAttribute 'action'
      @hideHandles()
      @unhover()


  hover: ->
    @baseHandle?.setAttribute 'hover', ''
    console.log "base handle missing" if not @baseHandle?

    if @at is 0
      @owner.points.last.baseHandle.setAttribute 'hover', ''
    else if @ is @owner.points.last
      @owner.points.first.baseHandle.setAttribute 'hover', ''


  unhover: ->
    @baseHandle?.removeAttribute 'hover'


  clear: ->
    @baseHandle.style.display = 'none'
    @


  unclear: ->
    @baseHandle.style.display = 'block'
    @


  remove: ->
    @antlers?.hide()
    @baseHandle?.remove()


  toStringWithZoom: ->
    @multiplyByMutable ui.canvas.zoom
    str = @toString()
    @multiplyByMutable (1 / ui.canvas.zoom)
    str

  flag: (flag) -> @_flags.ensure flag

  unflag: (flag) -> @_flags.remove flag

  flagged: (flag) -> @_flags.has flag

  annotate: (color, radius) ->
    ui.annotations.drawDot(@, color, radius)


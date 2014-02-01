###

  UI selected elements transformer

###


ui.transformer =


  angle: 0


  resetAccum: ->
    @accumX = 1.0
    @accumY = 1.0
    @accumA = 0.0
    @origin = undefined
    @


  hide: ->
    for own i, r of @reps
      r.style.display = "none"


  show: ->
    @resetAccum()
    for own i, r of @reps
      r.style.display = "block"


  center: ->
    new LineSegment(@tl, @br).midPoint()


  refresh: ->

    @deriveCorners(ui.selection.elements.all) # Just to get the center

    center = @center()

    if ui.selection.elements.all.length is 0
      return @hide()
    else
      @show()

    angles = new Set(ui.selection.elements.all.map((elem) ->
      elem.metadata.angle
    ))

    if angles.length is 1
      @angle = parseFloat angles[0]
    else
      ui.selection.elements.all.map (elem) ->
        elem.metadata.angle = 0

    for elem in ui.selection.elements.all
      if @angle isnt 0
        elem.rotate(360 - @angle, center)
        elem.clearCachedObjects()
      elem.clearCachedObjects()
      elem.lineSegments()

    @deriveCorners(ui.selection.elements.all)

    if @angle isnt 0
      for elem in ui.selection.elements.all
        elem.rotate(@angle, center)
      toAngle = @angle
      @angle = 0
      @rotate(toAngle, center)

    @redraw()

    @

  deriveCorners: (shapes) ->
    if shapes.length == 0
      @tl = @tr = @br = @bl = new Posn 0, 0
      @width = @height = 0
      return

    xRanges = (elem.xRange() for elem in shapes)
    yRanges = (elem.yRange() for elem in shapes)

    getMin = (rs) -> (Math.min.apply(@, rs.map (a) -> a.min))
    getMax = (rs) -> (Math.max.apply(@, rs.map (a) -> a.max))

    xMin = getMin(xRanges)
    xMax = getMax(xRanges)
    yMin = getMin(yRanges)
    yMax = getMax(yRanges)

    @tl = new Posn(xMin, yMin)
    @tr = new Posn(xMax, yMin)
    @br = new Posn(xMax, yMax)
    @bl = new Posn(xMin, yMax)

    @lc = new Posn(xMin, yMin + (yMax - yMin) / 2)
    @rc = new Posn(xMax, yMin + (yMax - yMin) / 2)
    @tc = new Posn(xMin + (xMax - xMin) / 2, yMin)
    @bc = new Posn(xMin + (xMax - xMin) / 2, yMax)

    @width = xMax - xMin
    @height = yMax - yMin

    if @width is 0
      @width = 1
    if @height is 0
      @height = 1


  pixelToFloat: (amt, length) ->
    return 1 if amt is 0
    return 1 + (amt / length)


  redraw: ->

    if ui.selection.elements.all.length is 0
      return @hide()

    tl = @correctAngle(@tl)

    zl = ui.canvas.zoom

    center = @center().zoomed()

    # This is so fucking ugly I'm sorry

    for corner in ["tl", "tr", "br", "bl", "tc", "rc", "bc", "lc"]
      cp = @[corner].zoomedc()
      @reps[corner].style.left = Math.floor(cp.x, 10)
      @reps[corner].style.top = Math.floor(cp.y, 10)
      @reps[corner].style.WebkitTransform = "rotate(#{@angle}deg)"
      @reps[corner].style.MozTransform = "rotate(#{@angle}deg)"

    @reps.outline.style.width = "#{Math.ceil(@width * zl, 10)}px"
    @reps.outline.style.height = "#{Math.ceil(@height * zl, 10)}px"

    tl.zoomed()

    @reps.outline.style.left = "#{Math.floor(tl.x, 10)}px"
    @reps.outline.style.top = "#{Math.floor(tl.y, 10)}px"
    @reps.outline.style.WebkitTransform = "rotate(#{@angle}deg)"
    @reps.outline.style.MozTransform = "rotate(#{@angle}deg)"

    @reps.c.style.left = "#{Math.ceil(center.x, 10)}px"
    @reps.c.style.top = "#{Math.ceil(center.y, 10)}px"

    @


  correctAngle: (p) ->
    p.clone().rotate(360 - @angle, @center())


  drag: (e) ->
    change =
      x: 0
      y: 0

    center = @center()

    # Just for readability's sake...
    cursor = e.canvasPosnZoomed.clone().rotate(360 - @angle, center)

    # This will be "tl"|"top"|"tr"|"right"|"br"|"bottom"|"bl"|"left"
    direction = e.target.className.replace('transform handle ', '').split(' ')[1]

    origins =
      tl:     @br
      tr:     @bl
      br:     @tl
      bl:     @tr
      top:    @bc
      right:  @lc
      bottom: @tc
      left:   @rc

    origin = origins[direction]

    # Change x
    if ["tr", "right", "br"].has direction
      change.x = cursor.x - @correctAngle(@rc).x
    if ["tl", "left", "bl"].has direction
      change.x = @correctAngle(@lc).x - cursor.x

    # Change y
    if ["tl", "top", "tr"].has direction
      change.y = @correctAngle(@tc).y - cursor.y
    if ["bl", "bottom", "br"].has direction
      change.y = cursor.y - @correctAngle(@bc).y

    x = @pixelToFloat(change.x, @width)
    y = @pixelToFloat(change.y, @height)

    # Flipping logic

    if x < 0
      # Flip it horizontally
      opposites =
        tl:     @reps.tr
        tr:     @reps.tl
        br:     @reps.bl
        bl:     @reps.br
        top:    @reps.bc
        right:  @reps.lc
        bottom: @reps.tc
        left:   @reps.rc

      ui.cursor.lastDownTarget = opposites[direction]
      switch direction
        when "left", "bl", "tl"
          return @_flipOver "R"
        when "right", "br", "tr"
          return @_flipOver "L"

    if y < 0
      opposites =
        tl:     @reps.bl
        tr:     @reps.br
        br:     @reps.tr
        bl:     @reps.tl
        top:    @reps.bc
        right:  @reps.lc
        bottom: @reps.tc
        left:   @reps.rc

      ui.cursor.lastDownTarget = opposites[direction]
      switch direction
        when "bottom", "bl", "br"
          return @_flipOver "T"
        when "top", "tl", "tr"
          return @_flipOver "B"

    if ui.hotkeys.modifiersDown.has "shift"
      # Constrain proportions
      if direction[0] is "side"
        if x == 1
          x = y
        else if y == 1
          y = x
      if x < y
        y = x
      else x = y

    if ui.hotkeys.modifiersDown.has "alt"
      # Scale around the center
      origin = center
      x = x * x
      y = y * y

    x = x.ensureRealNumber()
    y = y.ensureRealNumber()

    x = Math.max(1e-5, x)
    y = Math.max(1e-5, y)

    @scale x, y, origin
    @redraw()

    ui.selection.scale x, y, origin


  clonedPosns: ->
    [@tl, @tc, @tr, @rc, @br, @bc, @bl, @lc].map (p) -> p.clone()


  _flipOver: (side) ->
    # side
    #   either "T", "R", "B", "L"

    [tl, tc, tr, rc, br, bc, bl, lc] = @clonedPosns()

    switch side
      when "T"
        @tl = @bl.reflect tl
        @tc = @bc.reflect tc
        @tr = @br.reflect tr

        @rc = @rc.reflect tr
        @lc = @lc.reflect tl

        @bc = tc
        @bl = tl
        @br = tr

        ui.selection.scale(1, -1, @bc)

      when "B"
        @bl = @tl.reflect bl
        @bc = @tc.reflect bc
        @br = @tr.reflect br

        @rc = @rc.reflect br
        @lc = @lc.reflect bl

        @tc = bc
        @tl = bl
        @tr = br

        ui.selection.scale(1, -1, @tc)

      when "L"
        @tl = @tr.reflect tl
        @lc = @rc.reflect lc
        @bl = @br.reflect bl

        @tc = @tc.reflect tl
        @bc = @bc.reflect bl

        @rc = lc
        @br = bl
        @tr = tl

        ui.selection.scale(-1, 1, @rc)

      when "R"
        @tr = @tl.reflect tr
        @rc = @lc.reflect rc
        @br = @bl.reflect br

        @tc = @tc.reflect tr
        @bc = @bc.reflect br

        @lc = rc
        @bl = br
        @tl = tr

        ui.selection.scale(-1, 1, @lc)

    @redraw()


  flipOriginHorizontally: (o) ->
    switch o
      when @tl
        @tr
      when @tr
        @tl
      when @br
        @bl
      when @bl
        @br
      when @rc
        @lc
      when @lc
        @rc

  flipOriginVertically: (o) ->
    switch o
      when @tl
        @tr
      when @tr
        @tl
      when @br
        @bl
      when @bl
        @br
      when @rc
        @lc
      when @lc
        @rc

  scale: (x, y, @origin) ->
    # I/P:
    #   y: Float
    #   origin: Posn

    center = @center()

    for p in @pointsToScale @origin
      p.rotate(360 - @angle, center) if @angle isnt 0
      p.scale x, y, @origin.clone().rotate(360 - @angle, center)
      p.rotate(@angle, center) if @angle isnt 0
    @

    @width *= x
    @height *= y

    if @width is 0
      @width = 1
    if @height is 0
      @height = 1

    @accumX *= x
    @accumY *= y

    @


  pointsToScale: (origin) ->
    switch origin
      when @tc then return [@bl, @bc, @br, @rc, @lc]
      when @rc then return [@bl, @lc, @tl, @tc, @bc]
      when @bc then return [@tl, @tc, @tr, @rc, @lc]
      when @lc then return [@br, @rc, @tr, @bc, @tc]
      when @tl then return [@tr, @br, @bl, @tc, @rc, @bc, @lc]
      when @tr then return [@tl, @br, @bl, @tc, @rc, @bc, @lc]
      when @br then return [@tl, @tr, @bl, @tc, @rc, @bc, @lc]
      when @bl then return [@tl, @tr, @br, @tc, @rc, @bc, @lc]
      else return [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]


  nudge: (x, y) ->
    for p in [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]
      p.nudge x, -y
    @

  rotate: (a, @origin) ->
    @angle += a
    @angle %= 360

    @accumA += a
    @accumA %= 360

    for p in [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]
      p.rotate a, @origin
    @


  setup: ->
    @resetAccum()
    @reps =
      tl: q "#trfm-tl"
      tr: q "#trfm-tr"
      br: q "#trfm-br"
      bl: q "#trfm-bl"
      tc: q "#trfm-tc"
      rc: q "#trfm-rc"
      bc: q "#trfm-bc"
      lc: q "#trfm-lc"
      c:  q "#trfm-c"
      outline: q "#trfm-outline"


  tl: new Posn(0,0)
  tr: new Posn(0,0)
  br: new Posn(0,0)
  bl: new Posn(0,0)
  tc: new Posn(0,0)
  rc: new Posn(0,0)
  bc: new Posn(0,0)
  lc: new Posn(0,0)

  onRotatingMode: ->
    $(@reps.c).hide()

  offRotatingMode: ->
    return if ui.selection.elements.all.length is 0
    $(@reps.c).show()


setup.push -> ui.transformer.setup()

###

  Antlers

     \
        \ O  -  (succx, succy)
          \\
            \
             \
              o
               \
                \
                \\
                \ O  -  (basex, basey)
                |
                |
               /
              /


  Control handles for any vector Point. Edits base's x3 and base's succ's p2
  Each CurvePoint gets one of these. It keeps track of coordinates locally so we can
  draw these pre-emptively. For example, if you take the Pen tool and just drag a curve point right away,
  those curves don't exist yet but they come into play as soon as you add another point
  (...which will have to be a CurvePoint even if it's a static click)

  This class handles the GUI and updating the base and its succ's x2 y2 x3 y3. :)

###




class Antlers

  constructor: (@base, @basep3, @succp2) ->
    # I/P: base, a CurvePoint
    #      basex3 - either a Posn or null
    #      succx2 - either a Posn or null

    # Decide whether or not to lock the angle
    # (ensure points are always on a straight line)

    if @basep3? and @succp2?
      diff = Math.abs(@basep3.angle360(@base) - @succp2.angle360(@base))
      @lockAngle = diff.within(@angleLockThreshold, 180)
    else
      @lockAngle = false

    @

  angleLockThreshold: 0.5

  commit: () ->
    # Export the data to the element
    if @basep3?
      @base.x3 = @basep3.x
      @base.y3 = @basep3.y
    if @succp2? and @succ()
      @succ().x2 = @succp2.x
      @succ().y2 = @succp2.y
    @

  importNewSuccp2: (@succp2) ->
    if @succp2?
      @basep3 = @succp2.reflect(@base)
    @commit().refresh()

  killSuccp2: ->
    @succp2 = new Posn(@base.x, @base.y)
    @commit().refresh()

  succ: ->
    @base.succ

  refresh: ->
    return if not @visible
    @hide().show()

  visible: false

  show: ->
    @hide()
    @visible = true
    # Actually draws it, instead of just revealing it.
    # We don't keep the elements for this unless they're actually being shown.
    # We refresh it whenever we want it.
    if @basep3?
      @basep = new AntlerPoint @basep3.x, @basep3.y, @base.owner, @, -1

    if @succp2?
      @succp = new AntlerPoint @succp2.x, @succp2.y, @base.owner, @, 1

    return (=> @hide())

  hide: ->
    @visible = false
    # Removes elements from DOM to avoid needlessly updating them.
    @basep?.remove()
    @succp?.remove()
    @base.owner.antlerPoints?.remove [@basep, @succp]
    @

  redraw: ->
    @hide()
    @show()
    @

  hideTemp: (p) ->
    (if p is 2 then @succp else @basep)?.hideTemp()

  nudge: (x, y) ->

    @basep3?.nudge x, y
    @succp2?.nudge x, y
    if @succ() instanceof CurvePoint
      @succ().x2 += x
      @succ().y2 -= y
    @commit()

  scale: (x, y, origin) ->
    # When the shape is closed, this gets handled by the last point's antlers.

    @basep3?.scale x, y, origin
    @succp2?.scale x, y, origin

  rotate: (a, origin) ->

    @basep3?.rotate a, origin
    @succp2?.rotate a, origin
    @

  other: (p) ->
    if p is @succp then @basep else @succp

  angleDiff: (a, b) ->
    x = a - b
    if x < 0
      x += 360
    x

  flatten: ->
    return if not @succp2? or not @basep3?

    # Whichever one's ahead keeps moving ahead


    angleSuccp2 = @succp2.angle360(@base)
    angleBasep3 = @basep3.angle360(@base)

    p2p3d = @angleDiff(angleSuccp2, angleBasep3)
    p3p2d = @angleDiff(angleBasep3, angleSuccp2)

    if p2p3d < p3p2d
      ahead = "p2"
    else
      ahead = "p3"

    if ahead == "p2"
      # Move p2 forward, p3 back
      if p2p3d < 180
       compensate = (180 - p2p3d) / 2
       @succp2 = @succp2.rotate(compensate, @base)
       @basep3 = @basep3.rotate(-compensate, @base)
    else
      # Move p2 forward, p3 back
      if p3p2d < 180
       compensate = (180 - p3p2d) / 2
       @succp2 = @succp2.rotate(-compensate, @base)
       @basep3 = @basep3.rotate(compensate, @base)


class AntlerPoint extends Point
  constructor: (@x, @y, @owner, @family, @role) ->
    # I/P: x: int
    #      y: int
    #      owner: Monsvg
    #      family: Antlers
    #      role: int, -1 or 1 (-1 = base p3, 1 = succ p2)
    super @x, @y, @owner
    @draw()
    @baseHandle.className += ' bz-ctrl'
    @line = ui.annotations.drawLine(@zoomedc(), @family.base.zoomedc())
    @owner.antlerPoints?.push @

  succ: -> @family.base.succ

  base: -> @family.base

  hideTemp: ->
    @line.rep.style.display = 'none'
    @baseHandle.style.display = 'none'
    return =>
      @line.rep.style.display = 'block'
      @baseHandle.style.display = 'block'

  remove: ->
    @line.remove()
    super


  nudge: (x, y) ->

    if not @family.lockAngle
      super x, y
      @persist()
    else
      oldangle = @angle360(@family.base)
      super x, y

      newangle = @angle360(@family.base)
      @family.other(@)?.rotate(newangle - oldangle, @family.base)
      @persist()

    if @role is -1 and @family.base.succ instanceof SmoothTo
      s = @family.base.succ
      s.replaceWith(s.toCurveTo())


  scale: (x, y, origin) ->
    super x, y, origin
    @persist()

  rotate: (a, origin) ->
    super a, origin
    @persist()

  persist: ->
    if @role is -1# or @family.lockedTogether
      @family.basep3.copy @

    if @role is 1# or @family.lockedTogether
      @family.succp2.copy @

    if @family.base is @owner.points.last
      # Special case for when they are moving the last point's
      # antlers. We need to make the same changes on the first point's
      # antlers IF THE SHAPE IS CLOSED.

      first = @owner.points.first

      if @family.base.equal first
        # Make sure the first point's antlers
        # have the same succp2 and basep3 as this does
        #
        # Copy this antler's succp2 and basep3 and give them to
        # the first point's antlers as well.
        first.antlers.succp2 = @family.succp2.clone()
        first.antlers.basep3 = @family.basep3.clone()
        first.antlers.commit()

    @line.absorbA @family.base.zoomedc()
    @line.absorbB @zoomedc()

    @line.commit()

    @family.commit()



###

  PointsSegment

  A segment of points that starts with a MoveTo.
  A PointsList is composed of a list of these.

###


class PointsSegment
  constructor: (@points, @list) ->
    @startsAt = if @points.length isnt 0 then @points[0].at else 0

    if @list?
      @owner = @list.owner

    if @points[0] instanceof MoveTo
      @moveTo = @points[0]

    @points.forEach (p) =>
      p.segment = @

    @


  insert: (point, at) ->
    head = @points.slice 0, at
    tail = @points.slice at

    if point instanceof Array
      tail.forEach (p) ->
        p.at += point.length

      head = head.concat point

    else if point instanceof Point
      tail.forEach (p) ->
        p.at += 1

      head[head.length - 1].setSucc point
      tail[0].setPrec point

      head.push point



    else
      throw new Error "PointsList: don't know how to insert #{point}."



  toString: ->
    @points.join(' ')


  at: (n) ->
    @points[n - @startsAt]


  remove: (x) ->
    # Relink things
    x.prec.succ = x.succ
    x.succ.prec = x.prec
    if x is @list.last
      @list.last = x.prec
    if x is @list.first
      @list.first = x.succ
    @points = @points.remove x

    # Remove it from the canvas if it's there
    x.remove()


  movePointToFront: (point) ->
    return if not (@points.has point)

    @removeMoveTo()
    @points = @points.cannibalizeUntil(point)
    @


  moveMoveTo: (otherPoint) ->
    tail = @points.slice 1

    for i in [0 .. otherPoint.at - 1]
      segment = segment.cannibalize()

    @moveTo.copy otherPoint

    @points = [@moveTo].concat segment


  replace: (old, replacement) ->
    if replacement instanceof Point
      replacement.inheritPosition old
      @points = @points.replace old, replacement

    else if replacement instanceof Array
      replen = replacement.length
      at = old.at
      prec = old.prec
      succ = old.succ
      old.succ.prec = replacement[replen - 1]
      # Sus
      for np in replacement
        np.owner = @owner

        np.at = at
        np.prec = prec
        np.succ = succ
        prec.succ = np
        prec = np
        at += 1

      @points = @points.replace old, replacement

      for p in @points.slice at
        p.at += (replen - 1)

    replacement

  validateLinks: ->
    # Sortova debug tool <3
    console.log @points.map (p) -> "#{p.prec.at} #{p.at} #{p.succ.at}"
    prev = @points.length - 1
    for own i, p of @points
      i = parseInt i, 10
      if not (p.prec is @points[prev])
        console.log p, "prec wrong. Expecting", prev
        debugger
        return false
        break
      succ = if i is @points.length - 1 then 0 else i + 1
      if not (p.succ is @points[succ])
        console.log p, "succ wrong"
        return false
        break
      prev = i

    true


  # THIS IS FUCKED UP
  reverse: ->
    @removeMoveTo()

    positions = []
    stack = []

    for own index, point of @points
      stack.push point
      positions.push
        x: point.x
        y: point.y

    tailRev = stack.slice(1).reverse().map (p) ->
      return if p instanceof CurvePoint then p.reverse() else p

    positions = positions.reverse()

    stack = stack.slice(0, 1).concat tailRev

    stack = stack.map (p, i) ->
      c = positions[0]
      p.x = c.x
      p.y = c.y

      # Relink: swap succ and prec
      succ = p.succ
      p.succ = p.prec
      p.prec = succ

      p.at = i
      # Cut the head off as we go, this should be faster than just going positions[i] ^_^
      positions = positions.slice 1
      p
    new PointsSegment stack, @list


  removeMoveTo: ->
    @points = @points.filter (p) -> not (p instanceof MoveTo)


  ensureMoveTo: ->
    lastPoint = @points.last()
    firstPoint = @points.first()

    moveTo = new MoveTo(lastPoint.x, lastPoint.y, lastPoint.owner, lastPoint)
    moveTo.at = 0

    lastPoint.succ = firstPoint.prec = moveTo
    moveTo.succ = firstPoint
    @points.unshift(moveTo)

    @




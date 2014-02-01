###


  MapEvent

  An efficient way to store a nudge, scale, or rotate
  of an entire shape's points


###

class MapEvent extends Event
  constructor: (@funKey, @indexes, @args) ->
    # funKey: str, which method we're mapping
    #   "nudge"
    #   "scale"
    #   "rotate"
    #
    # indexes: array OR object
    #   if we're mapping on elements, an array of zindex numbers
    #   if we're mapping on points, an object where the keys are
    #   the element's zindex and the value is an array of point indexes
    #
    # args:
    #   args given to the method we're mapping
    #
    #   for nudge ("n")
    #     x: number
    #     y: number
    #
    #   for scale ("s")
    #     x: number
    #     y: number
    #     origin: posn
    #
    #   for rotate ("r")
    #     a: number
    #     origin: posn
    #

    # Determine whether this event happens to points or elements
    # This depends on if we're given input in the
    # form of [1,2,3,4] or { 4: [1,2,3,4] }
    @operatingOn = if @indexes instanceof Array then "elems" else "points"


    switch @funKey
      # Build the private undo and do map functions
      # that will get called on each member of elements

      when "nudge"
        @_undo = (e) =>
          e.nudge(-@args.x, -@args.y, true)
        @_do = (e) =>
          e.nudge(@args.x, @args.y, true)

      when "scale"
        # Damn NaN bugs
        @args.x = Math.max @args.x, 1e-5
        @args.y = Math.max @args.y, 1e-5

        @_undo = (e) =>
          e.scale(1 / @args.x, 1 / @args.y, new Posn @args.origin)
        @_do = (e) =>
          e.scale(@args.x, @args.y, new Posn @args.origin)

      when "rotate"
        @_undo = (e) =>
          e.rotate(-@args.angle, new Posn @args.origin)
        @_do = (e) =>
          e.rotate(@args.angle, new Posn @args.origin)


  undo: () ->
    @_execute @_undo

  do: () ->
    @_execute @_do

  _execute: (method) ->
    # method
    #   _do or _undo
    #
    # Abstraction on mapping over given elements of points

    if @operatingOn is "elems"
      # Get elem at each index in @indexes
      # and run method on it
      if not archive.simulating
        ui.selection.points.deselectAll()
        ui.selection.elements.deselectAll()

      for index in @indexes
        elem = queryElemByZIndex(parseInt(index, 10))
        if not archive.simulating
          ui.selection.elements.selectMore elem
        method(elem)
        elem.redrawHoverTargets()


    else
      # Get elem for each key value and the list of point indexes for it
      # Then get the point in the elem for each point index and run the method on it
      for own index, pointIndexes of @indexes
        elem = queryElemByZIndex(parseInt(index, 10))
        if not archive.simulating
          ui.selection.elements.deselectAll()
          ui.selection.points.deselectAll()
        for pointIndex in pointIndexes
          point = elem.points.at(parseInt(pointIndex, 10))
          if @args.antler?
            switch @args.antler
              when "p2"
                if point.antlers.succp2?
                  oldAngle = point.antlers.succp2.angle360(point)
                  method(point.antlers.succp2)
                  newAngle = point.antlers.succp2.angle360(point)

                  if point.antlers.lockAngle
                    point.antlers.basep3.rotate(newAngle - oldAngle, point)

                  point.antlers.redraw() if point.antlers.visible
                else
                  console.log "wtf"

              when "p3"
                oldAngle = point.antlers.basep3.angle360(point)
                method(point.antlers.basep3)
                newAngle = point.antlers.basep3.angle360(point)

                if point.antlers.lockAngle
                  point.antlers.succp2.rotate(newAngle - oldAngle, point)

                point.antlers.redraw() if point.antlers.visible

            point.antlers.commit()
          else
            method(point)
          if not archive.simulating
            ui.selection.points.selectMore point
        elem.commit()
        elem.redrawHoverTargets()


  toJSON: ->
    # t = type, "m:" = map:
    #   "n" = nudge, "s" = scale, "r" = rotate
    # i = z-indexes of elements mapping on
    # a = args
    t: "m:#{ { nudge: "n", scale: "s", rotate: "r" }[@funKey] }"
    i: @indexes
    a: @args


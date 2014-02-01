###

  PointExistenceEvent

###

class PointExistenceEvent extends Event
  constructor: (@ei, @point, at) ->
    # Given an elem's z-index and a point (index or value) this
    # acts just like the ExistenceEvent.
    #
    # elem: int - z-index of elem being affected
    #
    # point: int (for deletion) or string (for creation)
    #        The point we are changing.

    elem = @getElem()

    if typeof @point is "number"
      # Deleting the point
      @mode = "remove"
      @point = elem.points.at @point
      @pointIndex = @point

    else
      @mode = "create"

      if typeof @point is "string"
        # Adding the point
        @point = new Point(@point)

      if at?
        @pointIndex = at
      else
        @pointIndex = elem.points.all().length - 1

  do: ->
    if @mode is "remove" then @remove() else @add()

  undo: ->
    if @mode is "remove" then @add() else @remove()

  getElem: -> queryElemByZIndex @ei

  add: ->
    # Clone the point so our copy of the point can never be edited in the UI
    clonedPoint = @point.clone()

    elem = @getElem()
    elem.hidePoints()
    # Push it into the points linked list
    elem.points.push clonedPoint

    # If this point's coordinates are the same as the elem's first point's
    # but it's not actually the same point object
    if (clonedPoint.equal elem.points.first) and not (clonedPoint == elem.points.first)
      #
      elem.points.close()
    elem.commit()
    clonedPoint.draw()
    if not archive.simulating
      ui.selection.elements.deselectAll()
      ui.selection.points.select clonedPoint
    @getElem().redrawHoverTargets()

  remove: ->
    elem = @getElem()
    elem.points.remove @pointIndex

    # Show the most recent point
    elem.hidePoints()
    if not archive.simulating
      ui.selection.elements.deselectAll()
      ui.selection.points.select elem.points.last
    elem.commit()

  toJSON: ->
    t: "p:#{ { "remove": "d", "create": "c" }[@mode] }"
    e: @ei
    p: @point.toString()
    i: @pointIndex






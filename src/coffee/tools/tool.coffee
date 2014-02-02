###

  Tools class and organization object.
  Higher-level tool event method dispatcher and event augmentation.
  Includes template for all possible methods.

###

# All tools are stored under this namespace
window.tools = {}

class Tool

  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

    if @hotkey?
      ui.hotkeys.sets.app.down[@hotkey] = (e) =>
        e.preventDefault()
        ui.switchToTool @

  tearDown: ->

  setup: ->

  activateModifier: (modifier) ->

  deactivateModifier: (modifier) ->

  followingAngle: false

  typeOf: (target) ->
    # Depending on what is being clicked on/hovered over/dragged,
    # tools will do different things. This method performs various tests
    # on event.target. Return what is being clicked on as a string.

    if isSVGElementInMain target
      return "elem"
    else if isBezierControlHandle target
      return "antlerPoint"
    else if isPointHandle target
      return "point"
    else if isTransformerHandle target
      return "transformerHandle"
    else if isHoverTarget target
      return "hoverTarget"
    else
      return "background"



  buildEvent: (e) ->
    # Viewport coordinates are those of the actual white board we are drawing on,
    # the canvas.
    #
    # I/P: e: event object
    # O/P: e: augmented event object

    e.clientPosn = new Posn(e.clientX, e.clientY)

    e.canvasX = (e.clientX - ui.canvas.normal.x) / ui.canvas.zoom
    e.canvasY = (e.clientY - ui.canvas.normal.y) / ui.canvas.zoom

    e.canvasPosn = lab.conversions.posn.clientToCanvas(e.clientPosn)
    e.canvasPosnZoomed = lab.conversions.posn.clientToCanvasZoomed(e.clientPosn)

    if ui.grid.visible()
      e = ui.snap.supplementForGrid e
    if ui.snap.supplementEvent?
      e = ui.snap.supplementEvent e

    e.modifierKeys = e.shiftKey or e.metaKey or e.ctrlKey or e.altKey

    # Amt the cursor has moved on this event
    if ui.cursor.lastPosn?
      e.changeX = e.clientX - ui.cursor.lastPosn.x
      e.changeY = -(e.clientY - ui.cursor.lastPosn.y)

      e.changeX /= ui.canvas.zoom
      e.changeY /= ui.canvas.zoom

      e.changeXSnapped = e.changeX + ui.cursor.snapChangeAccum.x
      e.changeYSnapped = e.changeY + ui.cursor.snapChangeAccum.y

    e.typeOfTarget = @typeOf e.target

    # Now we query the appropriate JS object representations of the target,
    # and potentially its relatives. Store this in the event object as well.
    switch e.typeOfTarget
      when "elem"
        e.elem = ui.queryElement e.target # Monsvg object

      when "point"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.point = e.elem.points.at e.target.getAttribute("at") # Point object

      when "antlerPoint"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.point = e.elem.queryAntlerPoint(e.target) # Point object

      when "hoverTarget"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.pointA = e.elem.points.at parseInt(e.target.getAttribute 'a') # Point object
        e.pointB = e.elem.points.at parseInt(e.target.getAttribute 'b') # Point object
        e.hoverTarget = e.pointB.hoverTarget # HoverTarget object

    # By now, the event object should have a typeOfTarget attribute
    # and the appropriate JS object(s) embedded in it for the tool
    # to interface with the objects on the screen appropriately.
    #
    # From now on, ONLY (clientX, clientY) or (canvasX, canvasY)
    # should ever be used in tool methods. OK MOTHERFUCKERS? LETS KEEP THIS STANDARD.
    #
    # So let's return the new event now.

    e


  dispatch: (e, eventType) ->
    # Sends a mouse event to the appropriate tool method.
    # I/P: e: event object
    #      eventType: "hover", "unhover", "click", "startDrag", "continueDrag", "stopDrag"
    #                 Basically, a string describing the actual behavior of the mouse.
    #                 Brought in from ui/cursor_tracking.coffee
    # O/P: Nothing, simply calls the appropriate method.

    # If we're unhovering, this is a special case where we actually target the LAST hover target,
    # not the current one. We need to set this before we run @buildEvent

    # First let's get the additional info we need to carry this out no matter what.
    e = @buildEvent e

    # A note about how methods should be organized:
    # The method should be named after the event.typeOfTarget (output from tool.typeOf)
    # and it should live in an object named after the eventType given this by ui/ui.coffee
    # The eventType will be one of the strings listed in the I/P section for this method above.
    #
    # So hovering over a point with the cursor will call tools.cursor.hover.point(e)

    args = [e]

    if eventType is 'startDrag'
      for modifier in ui.hotkeys.modifiersDown
        @activateModifier modifier
      @draggingType = e.typeOfTarget

    if eventType is "doubleclick" and @ignoreDoubleclick
      eventType = "click"

    if @[eventType]?
      # If a method explicitly for this target type exists, run it. This is the most common case.
      if @[eventType][e.typeOfTarget]?
        return @[eventType][e.typeOfTarget]?.apply @, args

      # If it doesn't, check for events that apply to multiple target types.
      # Multi-target keys should be named by separating the targets with underscores.
      # For example, hovering over a point might trigger hover.point_elem or hover.hoverTarget_elem_point
      for own key, value of @[eventType]
        if key.mentions e.typeOfTarget
          return value.apply @, args

      # If there are none that mention it, check for an "all" event.
      # This should seldom be in use.
      if @[eventType].all?
        return @[eventType].all.apply @, args

      # By now, we clearly don't care about this event/target combo. So do nothing.


  recalculateLastDrag: ->
    if ui.cursor.dragging
      ui.cursor._mousemove ui.cursor.lastEvent


noop =
  background: (e) ->
  elem: (e) ->
  point: (e) ->
  antlerPoint: (e) ->
  toolPlaceholder: (e) ->
  hoverTarget: (e) ->

Tool::hover        = noop
Tool::unhover      = noop
Tool::click        = noop
Tool::rightClick   = noop
Tool::mousedown    = noop
Tool::mouseup      = noop
Tool::startDrag    = noop
Tool::continueDrag = noop
Tool::stopDrag     = noop


###

  Cursor tool

  Default tool that performs selection and transformation.


      #
      #   #
      #      #
      #         #
      #            #
      #               #
      #      #  #  #  #  #
      #   #
      ##
      #

###

tools.cursor = new Tool

  # Cursor image action point coordinates
  offsetX: 1
  offsetY: 1

  # CSS "tool" attribute given to the body when this tool is selected
  # to have its custom cursor show up.
  cssid: 'cursor'
  id: 'cursor'

  hotkey: 'V'

  tearDown: ->
    for elem in ui.elements
      if not ui.selection.elements.all.has elem
        elem.hidePoints()

  initialDragPosn: undefined

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        switch @draggingType
          when "elem", "hoverTarget", "point"
            op = @initialDragPosn
            if op?
              ui.snap.presets.every45(op)

            # Recalculate the last drag event, so it snaps
            # as soon as Shift is pushed.
            @recalculateLastDrag()
      when "alt"
        switch @draggingType
          when "elem"
            3
            #@duplicateElemModeOn()


  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        switch @draggingType
          when "elem", "hoverTarget"
            ui.snap.toNothing()
            @recalculateLastDrag()
      when "alt"
        switch @draggingType
          when "elem"
            3
            #@duplicateElemModeOff()


  hover:
    background: (e) ->
      for elem in ui.elements
        elem.hidePoints?()
      ui.unhighlightHoverTargets()
    elem: (e) ->
      e.elem.hover()

      ###
      if not ui.selection.elements.all.has e.elem
        e.elem.hover()

        if e.elem.group?
          e.elem.group.map (elem) -> elem.showPoints()

      ui.unhighlightHoverTargets()
      ###

    point: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.elem.unhoverPoints()
        e.elem.showPoints()
        ui.unhighlightHoverTargets()

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.elem.unhoverPoints()
        e.elem.showPoints()
        e.hoverTarget.highlight()

  unhover:
    background: (e) ->
    elem: (e) ->
      e.elem.unhover()

    point: (e) ->
      e.elem.hidePoints()

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      if e.currentHover isnt e.elem.rep
        e.elem.unhoverPoints()
        e.elem.hidePoints()
      e.hoverTarget.unhighlight()

  click:
    background: (e) ->
      if not e.modifierKeys
        ui.selection.elements.deselectAll()
      ui.selection.points.deselectAll()
    elem: (e) ->
      # Is this shit selected already?
      elem = e.elem
      selected = ui.selection.elements.all.has elem
      ui.selection.points.deselectAll()

      # If the shift key is down, this is a toggle operation.
      # Whether or not the element is already selected, do the opposite.
      # It's also additive/subtractive from the current selection
      # which might include many elements.
      if e.shiftKey
        if selected
          ui.selection.elements.deselect elem
          elem.showPoints()
          elem.hover()
        else
          if elem.group?
            ui.selectMore elem.group.elements
          else
            ui.selection.elements.selectMore elem
            elem.unhover()
            elem.removePoints()
      else
        if not selected
          if elem.group?
            ui.selection.elements.select elem.group.elements
            elem.group.map (elem) -> elem.removePoints()
          else
            ui.selection.elements.select elem
            elem.unhover()
            elem.removePoints()

      ui.unhighlightHoverTargets()

    point: (e) ->
      if e.shiftKey
        ui.selection.points.selectMore e.point
      else
        ui.selection.points.select e.point

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      ui.selection.points.selectMore(e.hoverTarget.a)
      ui.selection.points.selectMore(e.hoverTarget.b)

  doubleclick:
    elem: (e) ->
      trackEvent "Text", "Doubleclick edit"
      if e.elem instanceof Text
        e.elem.selectAll()


  startDrag:

    # This happens once at the beginning of every time the user drags something.
    background: (e) ->
      ui.dragSelection.start(new Posn(e))
    elem: (e) ->

      e.elem.unhover()

      # If we're dragging an elem, deselect any selected points.
      ui.selection.points.deselectAll()

      # Also hide any hover targets that may be visible.
      ui.unhighlightHoverTargets()

      # Is the element selected already? If so, we're going to be dragging
      # the entire selection that it's a part of.
      #
      # If not, select this element and anything it may be grouped with.
      if not ui.selection.elements.all.has e.elem
        if e.elem.group?
          ui.selection.elements.select e.elem.group.elements
        else
          ui.selection.elements.select e.elem

      # Remove the select elements' points entirely
      # so we don't accidentally start dragging those.
      for elem in ui.selection.elements.all
        elem.removePoints()

      ui.selection.elements.all.map (elem) -> elem.commit()
      @guidePointA = ui.transformer.center()

    antlerPoint: (e) ->

    point: (e) ->
      e.point.antlers?.show()
      e.point.owner.removeHoverTargets()
      ui.selection.points.select e.point

      if ui.selection.elements.all.has e.elem and ui.hotkeys.modifiersDown.has "alt"
          e.elem.clone().appendTo('#main')

    transformerHandle: (e) ->

    hoverTarget: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.hoverTarget.active()

        ui.selection.elements.deselectAll()
        ui.selection.points.deselectAll()

        @guidePointA = ui.transformer.center()

  snapChange:
    x: 0
    y: 0

  changeAccum:
    x: 0
    y: 0

  continueDrag:
    background: (e) ->
      ui.dragSelection.move(new Posn(e.clientX, e.clientY))
    elem: (e) ->
      # Hide point UI elements
      e.elem.removePoints()

      # If there is an accum from last snap to undo, do that first
      ac = @snapChange
      if ac.x isnt 0 and ac.y isnt 0
        # Only bother if there is something to do
        ui.selection.nudge(-ac.x, -ac.y)
      # Move the shape in its "true" position
      ui.selection.nudge(e.changeX + @changeAccum.x, e.changeY + @changeAccum.y, false)

      # resnap

      if ui.grid.visible()
        bl = ui.transformer.bl
        nbl = ui.snap.snapPointToGrid bl.clone()

        @snapChange =
          x: nbl.x - bl.x
          y: bl.y - nbl.y

        if @snapChange.x is -e.changeX
          @changeAccum.x += e.changeX
        else
          @changeAccum.x = 0

        if @snapChange.y is -e.changeY
          @changeAccum.y += e.changeY
        else
          @changeAccum.y = 0

        ui.selection.nudge(@snapChange.x, @snapChange.y, false)


    point: (e) ->
      if ui.selection.elements.all.has e.elem
        return @continueDrag.elem(e)

      e.point.nudge(e.changeX, e.changeY)
      e.point.antlers?.refresh()

      # We're moving a single point individually,
      # ruining any potential virginal integrity
      e.elem.woohoo()

      e.elem.commit()

    antlerPoint: (e) ->
      e.point.nudge(e.changeX, e.changeY)
      e.elem.commit()

    transformerHandle: (e) ->
      ui.transformer.drag e

    hoverTarget: (e) ->
      if ui.selection.elements.all.has e.elem
        return @continueDrag.elem.call tools.cursor, e
      else
        e.hoverTarget.nudge(e.changeX, e.changeY)


  stopDrag:
    background: (e) ->
      ui.dragSelection.end (b) -> ui.selection.elements.selectWithinBounds b

    elem: (e) ->
      for elem in ui.selection.elements.all
        elem.redrawHoverTargets()
        elem.commit()

      # Save this event
      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)

      if @duping
        archive.addExistenceEvent(@duping.rep)
      else
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: nudge.x, y: -nudge.y })
      @changeAccum =
        x: 0
        y: 0

      #@duping = undefined

    point: (e) ->
      e.elem.redrawHoverTargets()
      e.elem.clearCachedObjects()
      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)
      archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x,
        y: -nudge.y
      })

    antlerPoint: (e) ->
      e.elem.redrawHoverTargets()

      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)

      archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x
        y: -nudge.y
        antler: (if e.point.role is -1 then "p3" else "p2")
      })


    transformerHandle: (e) ->
      ui.utilities.transform.refresh()
      for elem in ui.selection.elements.all
        elem.redrawHoverTargets()
      archive.addMapEvent("scale", ui.selection.elements.zIndexes(), {
        x: ui.transformer.accumX
        y: ui.transformer.accumY
        origin: ui.transformer.origin
      })
      ui.transformer.resetAccum()

    hoverTarget: (e) ->
      e.elem.redrawHoverTargets()
      e.elem.clearCachedObjects()

      ui.selection.points.selectMore(e.hoverTarget.a)
      ui.selection.points.selectMore(e.hoverTarget.b)

      nudge = new Posn(e).subtract(ui.cursor.lastDown)

      eventData = {}
      zi = e.elem.zIndex()
      eventData[zi] = []
      eventData[zi].push(e.hoverTarget.a.at, e.hoverTarget.b.at)

      archive.addMapEvent("nudge", eventData, {
        x: nudge.x
        y: -nudge.y
      })




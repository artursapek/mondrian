$.extend ui.selection,
  macro: (actions) ->
    # Given an object with 'elements' and/or 'points'
    # functions, maps these on all selected objects of that type
    # 'transformer' function optional as well, where the
    # transformer is the context

    if actions.elements?
      @elements.each (e) -> actions.elements.call e
    if actions.points?
      @points.each (p) -> actions.points.call p
    if actions.transformer? and @elements.exists()
      actions.transformer.call ui.transformer

    ui.utilities.transform.refreshValues()

  nudge: (x, y, makeEvent = true) ->
    @macro
      elements: ->
        @nudge x, y
      points: ->
        @nudge x, y
        @antlers?.refresh()
        @owner.commit()
      transformer: ->
        @nudge(x, -y).redraw()

    if makeEvent
      # I think this is wrong
      archive.addMapEvent 'nudge', @elements.zIndexes(), { x: x, y: y }
      @elements.each (e) -> e.refreshUI()


  scale: (x, y, origin = ui.transformer.center()) ->
    @macro
      elements: ->
        @scale x, y, origin


  rotate: (a, origin = ui.transformer.center()) ->
    @macro
      elements: ->
        @rotate a, origin
      transformer: ->
        @rotate(a, origin).redraw()


  delete: ->
    @macro
      elements: ->
        @delete()


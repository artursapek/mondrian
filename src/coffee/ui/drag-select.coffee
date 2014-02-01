# ui.dragSelection
#
# Drag rectangle over elements to select many
# Sort of a ghost-tool/utility


ui.dragSelection =

  origin:
    x: 0
    y: 0

  tl:
    x: 0
    y: 0

  width: 0
  height: 0

  asRect: ->
    new Rect
      x: dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x
      y: dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y
      width: @width
      height: @height

  bounds: ->
    new Bounds(
      dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x,
      dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y,
      @width, @height)

  start: (posn) ->
    @origin.x = posn.x
    @origin.y = posn.y
    dom.$dragSelection.show()

  move: (posn) ->
    @tl = new Posn(Math.min(posn.x, @origin.x), Math.min(posn.y, @origin.y))
    @width = Math.max(posn.x, @origin.x) - @tl.x - 1
    @height = Math.max(posn.y, @origin.y) - @tl.y

    dom.$dragSelection.css
      top: @tl.y
      left: @tl.x
      width: @width
      height: @height

  end: (resultFunc, fuckingStopRightNow = false) ->
    dom.$dragSelection.hide()

    return if fuckingStopRightNow

    # Don't bother checking all the elements, this is
    # essentially a click on the background turned
    # to an accidental drag.
    if (@width < 3 and @height < 3)
      return ui.selection.elements.deselectAll()

    iz = 1 / ui.canvas.zoom

    resultFunc @bounds().scale(iz, iz, ui.canvas.origin)

    # Selection bounds should disappear right away
    dom.$dragSelection.hide().css
      left: ''
      top: ''
      width: ''
      height: ''



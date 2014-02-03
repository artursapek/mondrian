###

  TopUI

  An agnostic sort of "tool" that doesn't care what tool is selected.
  Specifically for dealing with top UI elements like utilities.

  Operates much like a Tool object, but the keys are classnames of top UI objects.

###

ui.topUI =

  _tooltipShowTimeout: undefined
  _tooltipHideTimeout: undefined
  _$tooltipVisible:    undefined

  dispatch: (e, event) ->
    for cl in e.target.className.split(" ")
      @[event]["." + cl]?(e)
    @[event]["#" + e.target.id]?(e)

  hover:
    ".tool-button": (e) ->
      ui.tooltips.activate(e.target.getAttribute("tool"))

  unhover:
    ".tool-button": (e) ->
      ui.tooltips.deactivate(e.target.getAttribute("tool"))

  click:
    ".swatch": (e) ->
      return if e.target.parentNode.className == "swatch-duo"
      $swatch = $(e.target)
      offset = $swatch.offset()
      ui.utilities.color.setting = e.target
      ui.utilities.color.toggle().position(offset.left + 41, offset.top).ensureVisibility()

    "#transparent-permanent-swatch": ->
      ui.utilities.color.set ui.colors.null
      ui.utilities.color.updateIndicator()
      if ui.selection.elements.all.length
        archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"))

    ".tool-button": (e) ->
      tool = e.target.getAttribute('tool')
      ui.switchToTool tools[tool]
      ui.tooltips.hideVisible()

    ".slider": (e) ->
      $(e.target).trigger("release")


  mousemove:
    "slider knob": ->


  mousedown:
    "slider knob": ->


  mouseup:
    "#color-pool": (e) ->
      ui.utilities.color.selectColor e

      trackEvent "Color", "Choose", ui.utilities.color.selectedColor.toString()

      if ui.selection.elements.all.length > 0
        archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"))


  startDrag:
    ".slider-container": (e) ->
      console.log 5
      ui.cursor.lastDownTarget = $(e.target).find(".knob")[0]


  continueDrag:
    "#color-pool": (e) ->
      ui.utilities.color.selectColor e

    ".knob": (e) ->
      change = new Posn(e).subtract(ui.cursor.lastPosn)
      $(e.target).nudge(change.x, 0)


  stopDrag:
    ".knob": (e) ->
      $(e.target).trigger("stopDrag")






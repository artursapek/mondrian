###

  TopUI

  An agnostic sort of "tool" that doesn't care what tool is selected.
  Specifically for dealing with top UI elements like utilities.

  Operates much like a Tool object, but the keys are classnames of top UI objects.

###

ui.topUI =

  _tooltipTimeouts: {}

  dispatch: (e, event) ->
    for cl in e.target.className.split(" ")
      @[event]["." + cl]?(e)
    @[event]["#" + e.target.id]?(e)


  hover:
    "slider knob": (e) ->

    ".tool-button": (e) ->
      # clearTimeout automatically discards invalid / undefined values.
      clearTimeout ui.topUI._tooltipTimeouts[e.target.id]
      # The target can change while async (in the timeout).
      elem = $(e.target)

      ui.topUI._tooltipTimeouts[e.target.id] = setTimeout(->
        elem.children(".tool-info").fadeIn()
      , 960)

  unhover:
    "slider knob": ->

    ".tool-button": (e) ->
      clearTimeout ui.topUI._tooltipTimeouts[e.target.id]
      # The target can change while async (in the timeout).
      elem = $(e.target)

      ui.topUI._tooltipTimeouts[e.target.id] = setTimeout(->
        elem.children(".tool-info").fadeOut()
      , 340)

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
      ui.switchToTool tools[e.target.id.replace("-btn", "")]

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






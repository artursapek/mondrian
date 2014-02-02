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
    "slider knob": (e) ->

    ".tool-button": (e) ->
      $tooltip = $(e.target).find(".tool-info")
      $visible = ui.topUI._$tooltipVisible

      if $visible? and $visible.text() == $tooltip.text()
        return clearTimeout ui.topUI._tooltipHideTimeout

      if $visible?
        clearTimeout ui.topUI._tooltipHideTimeout
        $visible.hide()
        $tooltip.show()
        ui.topUI._$tooltipVisible = $tooltip
      else
        clearTimeout ui.topUI._tooltipShowTimeout
        ui.topUI._tooltipShowTimeout = setTimeout =>
          $tooltip.fadeIn(50)
          ui.topUI._$tooltipVisible = $tooltip
        , 500

  unhover:
    "slider knob": ->

    ".tool-button": (e) ->
      $tooltip = $(e.target).find(".tool-info")
      $visible = ui.topUI._$tooltipVisible

      if $visible?
        if $visible.text() == $tooltip.text()
          ui.topUI._tooltipHideTimeout = setTimeout =>
            $tooltip.fadeOut(50)
            ui.topUI._$tooltipVisible = undefined
          , 300
      else
        clearTimeout ui.topUI._tooltipShowTimeout

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
      # Don't show the tooltip if the user selects the tool,
      # or hide the tooltip if it has already come up.
      clearTimeout ui.topUI._tooltipShowTimeout
      ui.topUI._$tooltipVisible?.hide()
      ui.topUI._$tooltipVisible = undefined

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






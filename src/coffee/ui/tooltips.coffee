###

  Tooltips
  ______   ___________
  |  |  | |           |
  | |x| | |  Pen   P  |
  |_____| |___________|

###

ui.tooltips =
  FADEIN_DELAY: 500
  FADEOUT_DELAY: 300
  FADE_DURATION: 50

  _showTimeout: undefined
  _hideTimeout: undefined
  _$visible:    undefined

  $elemFor: (tool) ->
    $(".tool-button[tool=\"#{tool}\"] .tool-info")

  activate: (tool) ->
    $tooltip = @$elemFor(tool)

    if @_$visible? and @_$visible.text() == $tooltip.text()
      return clearTimeout @_hideTimeout

    if @_$visible?
      clearTimeout @_hideTimeout
      @_$visible.hide()
      $tooltip.show()
      @_$visible = $tooltip
    else
      clearTimeout @_showTimeout
      @_showTimeout = setTimeout =>
        $tooltip.fadeIn(@FADE_DURATION)
        @_$visible = $tooltip
      , @FADEIN_DELAY


  deactivate: (tool) ->
    $tooltip = @$elemFor(tool)

    if @_$visible?
      if @_$visible.text() == $tooltip.text()
        @_hideTimeout = setTimeout =>
          $tooltip.fadeOut(@FADE_DURATION)
          @_$visible = undefined
        , @FADEOUT_DELAY
    else
      clearTimeout @_showTimeout

  hideVisible: (tool) ->
    clearTimeout @_showTimeout
    @_$visible?.hide()
    @_$visible = undefined

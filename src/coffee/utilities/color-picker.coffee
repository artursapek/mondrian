###

  Color picker

###

ui.utilities.color = new Utility
  setup: ->

    @rep = q("#color-picker-ut")
    @poolContainer = q("#pool-container")
    @poolContext = q("#color-picker-ut canvas#color-pool").getContext("2d")
    @saturationSliderContainer = q("#saturation-slider")
    # We get two of these bad boys due to how the infinite scroll illusion works.
    @currentIndicator1 = q("#color-marker1")
    @currentIndicator2 = q("#color-marker2")
    @inputs =
      r: q("#color-r")
      g: q("#color-g")
      b: q("#color-b")
      hex: q("#color-hex")

    @hide()

    # Build the infinite color pool.
    @drawPool()

    # Set up infinite scroll.
    @poolContainer.onscroll = (e) ->
      if @scrollTop == 0
        @scrollTop = 1530
      else if @scrollTop == 3060 - 260
        @scrollTop = 1530 - 260
      # This lets us keep the mouse down and scroll at the same time.
      # Super cool effect nobody will notice, but it's 2 loc so w/e
      if ui.cursor.down
        ui.utilities.color.selectColor(ui.cursor.lastEvent)

    @saturationSlider = new Slider
      rep: @saturationSliderContainer,
      commit: (val) =>
        @drawPool val
        @set @getColorAt @selected
        @center

    @rControl = new NumberBox
      rep: @inputs.r
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("r", val)

    @gControl = new NumberBox
      rep: @inputs.g
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("g", val)

    @gControl = new NumberBox
      rep: @inputs.b
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("b", val)

    @hexControl = new TextBox
      rep: @inputs.hex
      value: 0
      commit: (val) =>
        @set new Color(val)
        @refresh()
        @selectedColor.updateHex()
        @hexControl.write(@selectedColor.hex)
      hotkeys:
        blacklist: null
      maxLength: 6


  alterVal: (which, val) ->
    @selectedColor[which] = val
    @selectedColor.recalculateHex()
    @set @selectedColor
    @refresh()


  refresh: ->
    # Update the color pool saturation
    @drawPool(@selectedColor.saturation())

    # Update the saturation slider
    @saturationSlider.write(@selectedColor.saturation())

    # Update the position of the indicator
    @selected = @getPositionOf @selectedColor
    @updateIndicator().centerOnIndicator()


  shouldBeOpen: -> no # lol


  onshow: ->
    @poolContainer.scrollTop = 600
    @selectedColor = new Color(@setting.getAttribute("val"))
    @selected = @getPositionOf @selectedColor
    @saturationSlider.set(@selectedColor.saturation())
    @drawPool(@selectedColor.saturation())
    @updateIndicator()
    @centerOnIndicator()
    trackEvent "Color", "Open picker"


  ensureVisibility: ->
    @rep.style.top = "#{Math.min(ui.window.height() - 360, parseFloat(@rep.style.top))}px"
    @saveOffset()


  centerOnIndicator: ->
    @poolContainer.scrollTop = parseFloat(@currentIndicator1.style.top) - 130
    @


  setting: null


  set: (color) ->
    @selectedColor = color

    $(@setting).trigger("set", [color])

    $(@inputs.r).val(color.r)
    $(@inputs.g).val(color.g)
    $(@inputs.b).val(color.b)
    $(@inputs.hex).val(color.hex)


  selectColor: (e) ->
    @selected = new Posn(e).subtract(@offset).subtract(new Posn(10, 12))
    @selected.x = Math.max(0, @selected.x)
    @selected.x = Math.min(260, @selected.x)
    @selected.y += @poolContainer.scrollTop
    color = @getColorAt @selected
    @set color
    @updateIndicator()


  updateIndicator: ->
    if @selectedColor.toString() == "none"
      @hideIndicator(@currentIndicator1)
      @hideIndicator(@currentIndicator2)
    else
      @showIndicator(@currentIndicator1)
      @showIndicator(@currentIndicator2)
      @positionIndicator @currentIndicator1, @selected
      @selected.y = (@selected.y + 1530) % 3060
      @positionIndicator @currentIndicator2, @selected
      @


  showIndicator: (indicator) ->
    indicator.style.display = "block"

  hideIndicator: (indicator) ->
    indicator.style.display = "none"


  getColorAt: (posn) ->
    data = @poolContext.getImageData(posn.x, posn.y, 1, 1)
    new Color(data.data[0], data.data[1], data.data[2])


  getPositionOf: (color) ->
    primary = color.max()
    secondary = color.mid()
    tertiary = color.min()

    switch primary
      when color.r
        y = 0
        switch secondary
          when color.g
            y += secondary
          when color.b
            y -= secondary

      when color.g
        y = 510
        switch secondary
          when color.b
            y += secondary
          when color.r
            y -= secondary

      when color.b
        y = 1020
        switch secondary
          when color.r
            y += secondary
          when color.g
            y -= secondary

    if y < 0
      y += 1530

    y %= 1530

    x = 260 - (color.lightness() * 260)

    new Posn(x, y)


  positionIndicator: (indicator, posn) ->
    indicator.className = if posn.x < 130 then "indicator black" else "indicator white"
    indicator.style.left = posn.x.px()
    indicator.style.top = (posn.y).px()


  sample: (elem) ->
    @setting = ui.fill.rep
    @set(if elem.data.fill? then elem.data.fill else ui.colors.null)
    @setting = ui.stroke.rep
    @set(if elem.data.stroke? then elem.data.stroke else ui.colors.null)


  drawPool: (saturation = 1.0) ->

    gradient = @poolContext.createLinearGradient(0, 0, 0, 3060)

    colors = [ui.colors.red, ui.colors.yellow, ui.colors.green,
              ui.colors.teal, ui.colors.blue, ui.colors.pink]

    for i in [0..12]
      gradient.addColorStop((1 / 12) * i, colors[i % 6].clone().desaturate(1.0 - saturation).toHexString())

    @poolContext.fillStyle = gradient
    @poolContext.fillRect(0, 0, 260, 3060)

    # 1530 3060

    wb = @poolContext.createLinearGradient(0, 0, 260, 0)
    wb.addColorStop(0.02, "#FFFFFF")
    wb.addColorStop(0.5, "rgba(255, 255, 255, 0.0)")
    wb.addColorStop(0.5, "rgba(0, 0, 0, 0.0)")
    wb.addColorStop(0.98, "#000000")

    @poolContext.fillStyle = wb
    @poolContext.fillRect(0, 0, 260, 3060)



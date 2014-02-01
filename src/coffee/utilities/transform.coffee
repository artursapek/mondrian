###

  Transform utility

  Allows you to read and input changes to
  selected elements' dimensions and position.

###



ui.utilities.transform = new Utility

  setup: ->
    @rep = q("#transform-ut")

    @canvas = q("#transform-ut canvas#preview-canvas")
    @$canvas = $(@canvas)

    @origin = q("#transform-ut #origin-icon")
    @$origin = $(@origin)

    @widthBracket  = q("#transform-ut #width-bracket")
    @$widthBracket = $(@widthBracket)

    @heightBracket  = q("#transform-ut #height-bracket")
    @$heightBracket = $(@heightBracket)

    @outline  = q("#transform-ut #subtle-blue-outline")
    @$outline = $(@outline)

    @inputs =
      originX: q("#transform-ut #origin-x-val")
      originY: q("#transform-ut #origin-y-val")
      width:   q("#transform-ut #width-val")
      height:  q("#transform-ut #height-val")

    @context = @canvas.getContext "2d"

    @widthControl = new NumberBox
      rep:   @inputs.width
      value: 0
      min: 0.00001
      places: 5
      commit: (val) =>
        @alterVal("width", val)

    @heightControl = new NumberBox
      rep:   @inputs.height
      value: 0
      min: 0.00001
      places: 5
      commit: (val) =>
        @alterVal("height", val)

    @originXControl = new NumberBox
      rep:   @inputs.originX
      value: 0
      commit: (val) =>
        @alterVal("origin-x", val)

    @originYControl = new NumberBox
      rep:   @inputs.originY
      value: 0
      commit: (val) =>
        @alterVal("origin-y", val)

    @hide()

  shouldBeOpen: -> ui.selection.elements.all.length > 0

  trueVals:
    x: 0
    y: 0
    width: 0
    height: 0

  alterVal: (which, val) ->
    # Ayyyy. Take the changes in the text box and make them to the elements.
    center = ui.transformer.tl

    switch which
      when "width"
        scale = val / @trueVals.width

        # NaN/Infinity check
        scale = scale.ensureRealNumber()
        ui.transformer.scale(scale, 1, center).redraw()
        ui.selection.scale(scale, 1, center)
        archive.addMapEvent("scale", ui.selection.elements.zIndexes(), { x: scale, y: 1, origin: center })
        @trueVals.width = val
      when "height"
        scale = val / @trueVals.height

        # NaN/Infinity check
        scale = scale.ensureRealNumber()
        ui.transformer.scale(1, scale, center).redraw()
        ui.selection.scale(1, scale, center)
        archive.addMapEvent("scale", ui.selection.elements.zIndexes(), { x: 1, y: scale, origin: center })
        @trueVals.height = val
      when "origin-x"
        change = val - @trueVals.x
        ui.selection.nudge(change, 0)
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: change, y: 0 })
        @trueVals.x = val
      when "origin-y"
        change = val - @trueVals.y
        ui.selection.nudge(0, -change)
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: 0, y: -change })
        @trueVals.y = val


  refresh: ->
    return if ui.selection.elements.empty()
    png = ui.selection.elements.exportAsPNG(trim: true)
    @drawPreview png.maxDimension(105).exportAsDataURI()
    png.destroy()


  refreshValues: ->
    return if not @visible

    @trueVals.x = ui.transformer.tl.x
    @trueVals.y = ui.transformer.tl.y
    @trueVals.width = ui.transformer.width
    @trueVals.height = ui.transformer.height

    $(@inputs.originX).val @trueVals.x.places(4)
    $(@inputs.originY).val @trueVals.y.places(4)
    $(@inputs.width).val @trueVals.width.places(4)
    $(@inputs.height).val @trueVals.height.places(4)


  onshow: ->
    @refreshValues()


  clearPreview: ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)
    @origin.style.display = "none"
    @widthBracket.style.display = "none"
    @heightBracket.style.display = "none"


  drawPreview: (datauri, bounds) ->
    @clearPreview()

    # This means we've selected nothing.
    return @hide() if datauri is "data:image/svg+xml;base64,"

    @show()

    img = new Image()

    img.onload = =>
      @context.drawImage(img,0,0)

    img.src = datauri

    twidth = ui.transformer.width + 2
    theight = ui.transformer.height + 2

    @refreshValues()

    scale = Math.min(105 / twidth, 105 / theight)

    topOffset = (125 - (theight * scale)) / 2
    leftOffset = (125 - (twidth * scale)) / 2

    @$canvas.css
      top: "#{topOffset}px"
      left: "#{leftOffset}px"
    .attr
      height: theight * scale +  2
      width: twidth * scale + 2

    @$origin.show().css
      top: "#{Math.round(topOffset) - 3}px"
      left: "#{Math.round(leftOffset) - 3}px"

    @$widthBracket.show().css
      left: "#{Math.round(leftOffset)}px"
      width: "#{twidth * scale - 2}px"

    @$heightBracket.show().css
      top: "#{Math.round(topOffset)}px"
      height: "#{theight * scale - 2}px"

    @$outline.show().css
      top: "#{Math.round(topOffset)}px"
      left: "#{Math.round(leftOffset)}px"
      height: theight * scale - 2
      width: twidth * scale - 2




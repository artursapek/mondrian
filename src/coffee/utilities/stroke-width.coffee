###

  Stroke thickness utility

###


ui.utilities.strokeWidth = new Utility
  setup: ->
    @$rep = $("#stroke-width-ut")
    @rep = @$rep[0]
    @$preview = @$rep.find("#stroke-width-preview")
    @$noStroke = @$rep.find("#no-stroke-width-hint")

    @strokeControl = new NumberBox
      rep: @$rep.find('input')[0]
      value: 1
      min: 0
      max: 100
      places: 2
      commit: (val) =>
        @alterVal val
        @drawPreview()

      onDone: ->
        archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          "stroke-width")

  alterVal: (val) ->
    return if isNaN val # God damn this fucking language
    val = Math.max(val, 0).places(2)
    for elem in ui.selection.elements.all
      elem.data['stroke-width'] = val
      if not elem.data.stroke? or elem.data.stroke.hex == "none"
        elem.data.stroke = ui.colors.black
      elem.commit()
    @drawPreview()
    ui.uistate.set 'strokeWidth', parseInt(val, 10)

  drawPreview: ->
    preview = Math.min(20, Math.max(0, @strokeControl.value))
    @$preview.css
      opacity: Math.min(preview, 1.0)
      height: "#{Math.max(1, preview)}px"
      top: "#{Math.ceil(30 - Math.round(preview / 2))}px"

    if @strokeControl.value is 0
      @$noStroke.css("opacity", "0.4")
    else
      @$noStroke.css("opacity", "0.0")

  onshow: ->
    @refresh()

  refresh: ->
    if ui.selection.elements.all.length is 1
      width = ui.selection.elements.all[0].data['stroke-width']
      ui.uistate.set 'strokeWidth', parseInt(width, 10)
    else
      width = ui.uistate.get 'strokeWidth'
    if width?
      @strokeControl.set width
    else
      @strokeControl.set 0
    @drawPreview()

  shouldBeOpen: ->
    (ui.selection.elements.all.length > 0) or ([tools.pen, tools.line, tools.ellipse, tools.rectangle, tools.crayon, tools.type].has ui.uistate.get('tool'))

setup.push ->
  ui.utilities.strokeWidth.alterVal(1)


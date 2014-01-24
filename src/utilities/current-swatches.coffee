


ui.utilities.currentSwatches = new Utility
  setup: ->
    @$rep = $("#current-swatches-ut")
    @rep = @$rep[0]
    ui.selection.elements.on 'change', =>
      @generateSwatches()
      if ui.selection.elements.empty()
        @clear()
      else if ui.selection.elements.all.length == 1
        ui.utilities.color.sample(ui.selection.elements.all[0])

  shouldBeOpen: ->
    ui.selection.elements.all.length > 0

  clear: ->
    @rep.innerHTML = ""


  generateSwatches: ->
    @clear()
    @getSelectedSwatches()

    if @swatches.length == 1
      ui.utilities.color.sample(ui.selection.elements.all[0])
      @clear()
    else
      for swatch in @swatches
        if swatch.fill.equal(ui.fill) and swatch.stroke.equal(ui.stroke)
          @$rep.prepend(swatch.rep)
        else
          @$rep.append(swatch.rep)


  getSelectedSwatches: ->
    @swatches = []
    @swatchMap = {}

    add = (key, val) =>
      if @swatchMap[key]?
        @swatchMap[key].push val
      else
        @swatchMap[key] = [val]

    for elem in ui.selection.elements.all
      swatchDuo = new SwatchDuo(elem)
      key = swatchDuo.toString()
      @swatches.push(swatchDuo) if not @swatchMap[key]?
      add(key, elem)

      $srep = swatchDuo.$rep

      $srep.click ->
        ui.selection.elements.select ui.utilities.currentSwatches.swatchMap[@getAttribute("key")]
      .mouseover (e) ->
        e.stopPropagation()
        for elem in ui.utilities.currentSwatches.swatchMap[@getAttribute("key")]
          elem.showPoints()
      .mouseout (e) ->
        for elem in ui.utilities.currentSwatches.swatchMap[@getAttribute("key")]
          elem.removePoints().hidePoints()






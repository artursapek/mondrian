###


  In-app Clipboard

  Cut, Copy, and Paste


###



ui.clipboard =


  data: undefined


  cut: ->
    return if ui.selection.elements.all.length is 0
    @copy()
    for elem in ui.selection.elements.all
      elem.delete()


  copy: ->
    return if ui.selection.elements.all.length is 0
    @data = ui.selection.elements.export()


  paste: ->
    return if not @data?

    # Parse the stringified clipboard data
    parsed = io.parseAndAppend(@data, false)

    # Create a fit func that adjusts elements to fit in their bounds
    # adjusted to be in the center of the window
    bounds = new Bounds((p.bounds() for p in parsed))
    fit = bounds.clone()
    fit.centerOn(ui.canvas.posnInCenterOfWindow())

    # Center the elements
    adjust = bounds.adjustElemsTo(fit)
    for elem in parsed
      adjust(elem)

    # Select them
    ui.selection.elements.select parsed

    archive.addExistenceEvent parsed.map (p) -> p.rep




###


###

grid =

  frequency:
    x: 20
    y: 20

  dots: []

  posns: []

  visible: ->
    @dots.length

  toggle: ->
    if @visible()
      @clear()
    else
      @draw()

  clear: ->
    dom.$grid.empty()
    # I think this might help garbage collection
    # But I'm probably wrong
    @dots = null
    @dots = []


  draw: ->
    @clear()

    [width, height] = [ui.canvas.width, ui.canvas.height]

    for y in [0..height / @frequency.y]
      for x in [0..width / @frequency.x]
        posn = new Posn(x * @frequency.x, y * @frequency.y)
        dot = @dot posn
        dot.appendTo("svg#grid", false)
        @dots.push dot
        @posns.push posn

    async =>
      @refreshRadii()

  dot: (p) ->
    new Circle
      cx: p.x
      cy: p.y
      r:  1
      dontTrack: true
      fill: new Color(0,0,0,0.6)
      stroke: 'none'

  refreshRadii: ->
    return if not @visible()
    dom.$grid.hide()
    @dots.map (dot) ->
      dot.attr
        r: 1 / ui.canvas.zoom
      dot.commit()
    dom.$grid.show()




ui.grid = grid

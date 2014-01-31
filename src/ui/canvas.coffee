###

  The canvas

   _______________
  |               |
  |               |
  |               |
  |               |
  |               |
  |_______________|

  Manages canvas panning/zooming

###


ui.canvas =

  ###

  A note about zoom:

  There are three categories of elements in Mondrian regarding zoom:


  1 Annotation
    Elements who scale with zoom, but retain certain aesthetic features.
    They don't literally stretch with the zoom.

    Examples:
      HoverTargets: their position and size changes, but not their strokeWidth
      Points:       their position changes, but stay the same size
      The canvas:   its size changes but its 1px outline remains 1px


  2 Canvas
    Elements who scale with zoom entirely, meaning "real" zoom. Their stroke gets
    thicker, their position gets larger.

    Examples:
      The actual SVG elements being drawn.


  3 Client
    Elements who don't give a flying fuck how far you've zoomed in.
    These guys still alter their functionality a bit but 10,10 will always
    mean 10,10 visually. Sole difference between this and Annotation
    is the position of this relies not on the SVG Elements but the cursor/client.

    Examples:
      Drag selection
      Cursor

  ###


  zoom: 1.0

  width: 1000
  height: 800

  panLimitX: ->
    Math.max(500, ((ui.window.width() - @width * @zoom) / 2) + ui.window.width() / 3)

  panLimitY: ->
    Math.max(500, ((ui.window.height() - @height * @zoom) / 2) + ui.window.height() / 3)

  origin: new Posn(0, 0)

  normal: new Posn(-1, -1)

  show: ->
    dom.canvas.style.display = "block"

  hide: ->
    dom.canvas.style.display = "none"

  redraw: (centering = false) ->
    # Ay sus

    dom.main?.style.width = (@width).px()
    dom.main?.style.height = (@height).px()

    dom.main?.setAttribute("width", @width)
    dom.main?.setAttribute("height", @height)

    dom.main?.setAttribute("viewbox", "0 0 #{@width} #{@height}")
    dom.main?.setAttribute("enable-background", "new 0 0 #{@width} #{@height}")

    dom.grid?.setAttribute("width", @width)
    dom.grid?.setAttribute("height", @height)

    transformScaleRule =
      "transform": "scale(#{ui.canvas.zoom})"
      "-webkit-transform": "scale(#{ui.canvas.zoom})"
      "-moz-transform": "scale(#{ui.canvas.zoom})"

    dom.$main.css transformScaleRule
    dom.$grid.css transformScaleRule

    stretch = (e) =>
      e.style.width = (@width * ui.canvas.zoom).px()
      e.style.height = (@height * ui.canvas.zoom).px()

    [dom.bg, dom.annotations, dom.hoverTargets].map stretch

    ww = ui.window.width()
    wh = ui.window.height()

    if centering
      if @width < ww
        diff = ww - @width
        @normal.x = diff / 2

      if @height < wh
        diff = wh - @height
        @normal.y = diff / 2

    @refreshPosition()
    @

  nudge: (x, y) ->
    # Nudge the canvas a certain amount.
    #
    # I/P:
    #   x: number
    #   y: number
    #
    # No O/P

    @normal = @normal.add new Posn(x, -y)
    @ensureVisibility()
    @snapToIntegers()
    @refreshPosition()

  snapToIntegers: ->
    @normal.x = Math.round(@normal.x)
    @normal.y = Math.round(@normal.y)

  ensureVisibility: ->
    limitX = @panLimitX()
    limitY = @panLimitY()

    width = ui.window.width()
    height = ui.window.height()

    if @normal.x > limitX
      @normal.x = limitX
    if @normal.x < -limitX - (@width * @zoom) + width
      @normal.x = -limitX - (@width * @zoom) + width
    if @normal.y > limitY
      @normal.y = limitY
    if @normal.y < -limitY - (@height * @zoom) + height
      @normal.y = -limitY - (@height * @zoom) + height
    @refreshPosition()


  refreshPosition: ->
    dom.canvas?.style.left = @normal.x
    dom.canvas?.style.top = @normal.y
    ui.uistate?.set 'normal', @normal
    @


  setZoom: (zoom, origin = ui.window.center()) ->
    # Set the zoom level, sus
    #
    # I/P:
    #   amt: float (1.0 == 100%)
    #   origin: client-level posn origin for the transformation
    #
    # No O/P
    #
    # NOTE: For things to work properly, you must call
    # ui.refreshAfterZoom() when you're done zooming.
    #
    # This doesn't do it automatically because often the user will
    # zoom more than once before even touching the cursor again,
    # so we don't want to do unnecessary work redrawing the hover
    # targets at each interval.
    #
    # This should just always be called at the appropriate
    # time in every tool/utility which can zoom (not many)

    canvasPosnAtOrigin = lab.conversions.posn.clientToCanvasZoomed(origin)

    ui.selection.points.hide()

    # Change the zoom level
    @zoom = zoom
    @redraw()
    ui.transformer.redraw(true)

    # Realign the image so the same posn is under the cursor as before we zoomed
    @alignWithClient(canvasPosnAtOrigin, origin)

    # Make sure the canvas is within the visible limits in any direction
    @ensureVisibility()

    ui.uistate?.set 'zoom', @zoom


  center: ->
    @normal.add(new Posn((@width * @zoom) / 2, (@height * @zoom) / 2))


  centerOn: (posn) ->
    posn = posn.subtract @center()
    @normal.x += posn.x
    @normal.y += posn.y
    @refreshPosition()


  alignWithClient: (canvasZoomedPosn, clientPosn) ->
    canvasEquivalentOfGivenPosn = lab.conversions.posn.clientToCanvasZoomed(clientPosn)
    @nudge((canvasEquivalentOfGivenPosn.x - canvasZoomedPosn.x) * @zoom,
           (canvasZoomedPosn.y - canvasEquivalentOfGivenPosn.y) * @zoom)

  posnInCenterOfWindow: ->
    ui.window.center().subtract(@normal).setZoom(ui.canvas.zoom)


  zoomIn: (o) ->
    @setZoom(@zoom * 1.15, o)


  zoomOut: (o) ->
    @setZoom(@zoom * 0.85, o)


  zoom100: ->
    @setZoom(1)
    @centerOn ui.window.center()


  zoomToFit: (bounds) ->
    oldnormal = @normal.clone()
    center = bounds.center()

    widthChange = (ui.window.width() / @zoom) / bounds.width
    heightChange = (ui.window.height() / @zoom) / bounds.height

    zoomAmt = Math.min(widthChange, heightChange)
    @setZoom(ui.canvas.zoom * zoomAmt)

    ui.window.centerOn center

    async => ui.refreshAfterZoom()

  petrified: false

  petrify: ->
    @petrified = true
    $mainpetrified = dom.$main.clone()
    $mainpetrified.attr('id', 'main-petrified')
    dom.$hoverTargets.hide()
    dom.$annotations.hide()
    dom.$main.hide().after($mainpetrified)

  depetrify: ->
    @petrified = false
    dom.$hoverTargets.show()
    dom.$annotations.show()
    dom.$main.show().next().remove()


setup.push ->
  ui.canvas.redraw()


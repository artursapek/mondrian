###


###


class Text extends Monsvg
  type: 'text'


  constructor: (@data, @content = "") ->

    @data = $.extend
      x: 0
      y: 0
      'font-size': ui.utilities.typography.sizeControl.read()
      'font-family': ui.utilities.typography.faceControl.selected.val
    , @data

    @data.x = float(@data.x)
    @data.y = float(@data.y)

    super @data

    @transformations = new Transformations(@, [
      new RotateTransformation(0)
      new ScaleTransformation(1, 1)
      new TranslateTransformation(0, 0)
    ])

    @origin = new Posn(@data.x, @data.y)
    @textEditable = new TextEditable @

    @

  caching: false

  setContent: (@content) ->
    @commit()

  setSize: (size) ->
    @data['font-size'] = size

  setFace: (face) ->
    @data['font-family'] = face

  commit: ->
    @data.x = @origin.x
    @data.y = @origin.y
    @rep.textContent = @content
    @transformations.commit()
    super

  editableMode: ->
    @textEditable.show()
    @hide()
    ui.textEditing = @
    ui.selection.elements.deselectAll()

  displayMode: ->
    @textEditable.hide()
    @show()
    ui.textEditing = undefined
    @adjustForScale()

  show: ->
    @rep.style.display = "block"

  hide: ->
    @rep.style.display = "none"

  originRotated: ->
    @origin.clone().rotate(@metadata.angle, @center())

  simulateInSandbox: ->
    $("#text-sandbox").text(@content).css
      'font-size':   @data['font-size']
      'font-family': @data['font-family']

  selectAll: ->
    @editableMode()
    @textEditable.focus()
    document.execCommand('selectAll', false, null)
    return

  delete: ->
    super
    # Make sure we never leave behind stray textEditable divs
    @textEditable.hide()

  toSVG: ->
    # Text elements are not self-closing so
    # we need to do a bit more work here
    self = super
    self.textContent = @content
    self

  normalizedOrigin: ->
    @origin.clone().rotate(-@metadata.angle, @center())

  nudge: (x, y) ->
    @origin.nudge(x, y)
    @adjustForScale()
    @commit()

  rotate: (a, origin = @center(), adjust=true) ->
    @metadata.angle += a
    @metadata.angle %= 360

    oc = @center()
    nc = @center().rotate(a, origin)

    # Don't use nudge method because we don't want adjustments made
    @origin.nudge(nc.x - oc.x, oc.y - nc.y)
    @transformations.get('rotate').rotate(a)

    @adjustForScale() if adjust

    @commit()

  scale: (x, y, origin) ->
    # Look at path.coffee#scale for better annotations of this same procedure
    angle = @metadata.angle

    unless angle is 0
      # Normalize rotation
      @rotate(360 - angle, origin)

    # The only real point in text objects is the origin
    @origin.scale(x, y, origin)
    @transformations.get('scale').scale(x, y)
    @adjustForScale()

    unless angle is 0
      # Rotate back into place
      @rotate(angle, origin)

    @commit()

  adjustForScale: ->
    scale = @transformations.get('scale')
    translate = @transformations.get('translate')

    a = @metadata.angle
    @rotate(-a, @center(), false)
    translate.y = ((scale.y - 1) / scale.y) * -@origin.y
    translate.x = ((scale.x - 1) / scale.x) * -@origin.x
    @rotate(a, @center(), false)
    @commit()


  hover: ->
    return if ui.selection.elements.all.has @
    ###
    $("#text-underline").show().css
      left: @origin.x * ui.canvas.zoom
      top:  @origin.y * ui.canvas.zoom
      width: "#{@width() * ui.canvas.zoom}px"
    ###

  unhover: ->
    $("#text-underline").hide()

  drawToCanvas: ->

  clone: ->
    cloned = super
    cloned.setContent @content
    cloned

  width: ->
    @simulateInSandbox()
    $("#text-sandbox")[0].clientWidth * @transformations.get('scale').x

  height: ->
    @data['font-size'] * @transformations.get('scale').y

  xRange: ->
    new Range(@origin.x, @origin.x + @width())

  yRange: ->
    new Range(@origin.y - @height(), @origin.y)

  overlapsRect: (rect) ->
    @bounds().toRect().overlaps(rect)

  setupToCavnas: (context) ->
    scale = @transformations.get('scale')
    orr = @originRotated()

    context.translate(orr.x, orr.y)
    context.rotate(@metadata.angle * (Math.PI / 180))

    context.scale(scale.x, scale.y)

    context.font = "#{@data['font-size']}px #{@data['font-family']}"
    context

  drawToCanvas: (context) ->
    scale = @transformations.get('scale')
    context = @setupToCavnas(context)

    context.fillText(@content.strip(), 0, 0)
    context = @finishToCanvas(context)

  finishToCanvas: (context) ->
    scale = @transformations.get('scale')
    orr = @originRotated()

    context.scale(1 / scale.x, 1 / scale.y)

    context.rotate(-@metadata.angle * (Math.PI / 180))
    context.translate(-orr.x, -orr.y)
    context


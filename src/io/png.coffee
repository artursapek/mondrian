###

  Pseudo-PNG class that just draws to
  an off-screen canvas and exports that

###

class PNG

  constructor: (elements) ->

    # Given either an SVG file as a string,
    # an SVG file as an SVG object,
    # or a list of Monsvg elements
    @_parseInput elements

    # Put down an off-screen
    # canvas element for us to draw on
    @_buildRep()


  maxDimension: (dimen) ->
    context = @context()

    # Scale the canvas dimensions
    scale = Math.max(@width, @height) / dimen
    @setDimensions(@width / scale, @height / scale)

    # Scale the context
    bounds = @svg._bounds
    boundsScale = Math.max(bounds.width, bounds.height) / dimen
    context.scale(1 / boundsScale, 1 / boundsScale)
    @


  export: ->
    # PNG clusterfuck
    atob @exportAsBase64()


  exportAsBase64: ->
    # Raw B64
    @exportAsDataURI().replace(/^.*\,/, '')


  exportAsDataURI: ->
    # Draw @elements to the canvas only when we have to
    @_draw()
    @rep.toDataURL 'png'


  destroy: ->
    @elements = null
    @rep.remove()
    @rep = null
    @


  clear: ->
    @context().clearRect(0, 0, @width, @height)


  @_setScale: (x, y) ->
    @context().scale(x / @_contextScaleX, y / @_contextScaleY)
    @_contextScaleX = x
    @_contextScaleY = y


  _draw: ->
    @clear()
    context = @context()
    @elements.forEach (element) =>
      element.drawToCanvas context


  _parseInput: (elements) ->
    if typeof(elements) == 'string'
      @svg = new SVG elements
      @elements = @svg.elements

    else if elements instanceof SVG
      @svg = elements
      @elements = @svg.elements

    else if elements instanceof Array
      @elements = elements
      @svg = new SVG @elements


  _buildRep: ->
    # Make a throwaway canvas, append it to body
    @rep = document.createElement 'canvas'
    @rep.classList.add 'offscreen-throwaway'
    @setDimensions(
      @svg.metadata.width,
      @svg.metadata.height)

    @_contextScaleX = 1.0
    @_contextScaleY = 1.0

    q('body').appendChild @rep


  attr: (attr, val) ->
    @rep.setAttribute attr, val


  setDimensions: (@width, @height) ->
    @attr 'width',  @width
    @attr 'height', @height


  context: ->
    @_context ?= @rep.getContext '2d'


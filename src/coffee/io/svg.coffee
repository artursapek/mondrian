###

  SVG representation class/API

###

class SVG

  constructor: (contents) ->

    @_ensureDoc contents

    @_svgRoot ?= @doc.querySelector 'svg'
    if not @_svgRoot?
      throw new Error 'No svg element found'

    @_buildMetadata()
    @_buildElements() if not @elements?
    @_assignMondrianNamespace()

  # Constructor helpers

  _ensureDoc: (contents) ->
    if typeof(contents) == 'string'
      # Parse the SVG string
      @doc = new DOMParser().parseFromString contents, @MIMETYPE

    else if contents.documentURI?
      # This means it's already a parsed document
      @doc = contents

    else if contents instanceof Array
      # We've been given a list of Monsvg elements
      @elements = contents

      # Create the document from scratch
      @doc = document.implementation.createDocument(CONSTANTS.SVG_NAMESPACE, 'svg')

      # Have to do this for some reason
      # It gets created with an <undefined></undefined> element
      @doc.removeChild(@doc.childNodes[0])

      @_svgRoot = @doc.createElementNS(CONSTANTS.SVG_NAMESPACE, "svg")

      @doc.appendChild @_svgRoot

      @elements.forEach (elem) =>
        @_svgRoot.appendChild elem.rep

      # If we haven't been given an SVG element with
      # a canvas size, just derive it from the elements.
      # This will mean it's "trimmed" from the beginning.
      @_deriveBoundsFromElements()

    else
      throw new Error 'Bad input'

  _buildMetadata: ->
    @metadata = {}

    @metadata.width = parseInt(@_svgAttr 'width', 10)
    @metadata.height = parseInt(@_svgAttr 'height', 10)

    unless @_bounds?
      @_bounds = new Bounds(0, 0, @metadata.width, @metadata.height)


  _buildElements: ->
    @elements = io.parse @toString(), false

  _assignMondrianNamespace: ->
    # Make the mondrian: namespace legal
    @_svgRoot.setAttribute('xmlns:mondrian', 'http://mondrian.io/xml')

  _deriveBoundsFromElements: ->
    # Get the bounds of all the elements
    @_bounds = @_elementsBounds()

    width = @_bounds.width + @_bounds.x
    height = @_bounds.height + @_bounds.y

    @_applyBounds()

  _applyBounds: ->
    @_svgRoot.setAttribute 'width', @_bounds.width
    @_svgRoot.setAttribute 'height', @_bounds.height


  _elementsBounds: ->
    new Bounds(@elements.map (elem) -> elem.bounds())


  trim: ->
    # No I/O
    # Trim edges to elements

    @_normalizeRotations()
    bounds = @_elementsBounds()

    @elements.forEach (elem) ->
      elem.nudge(bounds.x.invert(), bounds.y)

    @_bounds.width = bounds.width
    @_bounds.height = bounds.height

    @_applyBounds()


  _normalizeRotations: ->
    angle = ui.transformer.angle
    @elements.forEach (elem) =>
      elem.rotate(360 - angle, @center())
      # If there's more than one unique angle we abandon them all
      # because there's no other fair way to resolve that.


  _svgAttr: (attr) ->
    @_svgRoot.getAttribute attr


  toString: ->
    new XMLSerializer().serializeToString(@doc)


  toBase64: ->
    "data:#{@MIMETYPE};charset=#{@CHARSET};base64,#{@toString()}"


  appendTo: (selector) ->
    q(selector).appendChild(@_svgRoot)


  center: ->
    new Posn(@metadata.width / 2, @metadata.height / 2)

  # Constants

  MIMETYPE: 'image/svg+xml'

  CHARSET: 'utf-8'






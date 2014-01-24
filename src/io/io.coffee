###

  io

  The goal of this is an IO that can take anything that could
  conceivably be SVG and convert it to Monsvg.

###


io =

  parse: (input, makeNew = true) ->
    $svg = @findSVGRoot(input)
    svg = $svg[0]

    bounds = @getBounds $svg

    # Set the proper dimensions

    bounds.width = 1000 if not bounds.width?
    bounds.height = 1000 if not bounds.height?


    if makeNew
      ui.new(bounds.width, bounds.height)

    parsed = @recParse $svg

    viewbox = svg.getAttribute("viewBox")

    if viewbox
      # If there's a viewBox attr, we adjust the contents to fit in the actual canvas
      # the way they fit in the viewBox.
      viewbox = viewbox.split " "
      viewbox = new Bounds(viewbox[0], viewbox[1], viewbox[2], viewbox[3])
      #parsed.map viewbox.adjustElemsTo bounds
      #TODO FIX

    parsed

  getBounds: (input) ->
    $svg = @findSVGRoot(input)
    svg = $svg[0]
    width = svg.getAttribute "width"
    height = svg.getAttribute "height"
    viewbox = svg.getAttribute "viewBox"

    if not width?
      if viewbox?
        width = viewbox.split(" ")[2]
      else
        console.warn("No width, defaulting to 1000")
        width = 1000

    if not height?
      if viewbox?
        height = viewbox.split(" ")[3]
      else
        console.warn("No height, defaulting to 1000")
        height = 1000

    width = parseFloat(width)
    height = parseFloat(height)

    if isNaN(width)
      console.warn("Width is NaN, defaulting to 1000")
      width = 1000

    if isNaN(height)
      console.warn("Width is NaN, defaulting to 1000")
      height = 1000

    new Bounds 0, 0, parseFloat(width), parseFloat(height)

  recParse: (container) ->
    results = []
    for elem in container.children()

      # <defs> symbols... for now we don't do much with this.
      if elem.nodeName is "defs"
        continue
        inside = @recParse $(elem)
        results = results.concat inside

      # <g> group tags... drill down.
      else if elem.nodeName is "g"
          # The Group class just isnt ready, so we're not supporting it for now.
          # Ungroup everything.
          parsedChildren = @recParse $(elem)
          results = results.concat(parsedChildren)
          console.warn "Group element not implemented yet. Ungrouping #{parsedChildren.length} elements."
          # TODO implement groups properly

      else

        # Otherwise it must be a shape element we have a class for.
        parsed = @parseElement(elem)

        if parsed == false
          continue

        # Any geometric shapes
        if parsed instanceof Monsvg
          results.push parsed

        # <use> tag
        else if parsed instanceof Object and parsed["xlink:href"]?
          parsed.reference = true
          results.push parsed

    monsvgs = results.filter (e) -> e instanceof Monsvg

    results


  findSVGRoot: (input) ->
    if input instanceof Array
      return input[0].$rep.closest("svg")
    else if input instanceof $
      input = input.filter('svg')
      if input.is "svg"
        return input
      else
        $svg = input.find "svg"
        if $svg.length is 0
          throw new Error("io: No svg node found.")
        else
          return $svg[0]
    else
      @findSVGRoot $(input)


  parseElement: (elem) ->
    classes =
      'path': Path
      'text': Text
    virgins =
      'rect': Rect
      'ellipse': Ellipse
      'polygon': Polygon # TODO
      'polyline': Polyline # TODO

    # Ignore attributes that have these words in them.
    # They're useless old crap that Inkscape jizzes all over its SVG files.

    if elem instanceof $
      $elem = elem
      elem = elem[0]

    attrs = elem.attributes

    transform = null
    for own key, attr of attrs
      if attr.name is "transform"
        transform = attr.value

    data = @makeData(elem)
    type = elem.nodeName.toLowerCase()

    if classes[type]? or virgins[type]?
      result = null

      if classes[type]?
        result = new classes[elem.nodeName.toLowerCase()](data)
        if type is "text"
          result.setContent elem.textContent

      else if virgins[type]?
        virgin = new virgins[elem.nodeName.toLowerCase()](data)
        result = virgin.convertToPath()
        result.virgin = virgin

      if transform and elem.nodeName.toLowerCase() isnt "text"
        result.carryOutTransformations transform
        delete result.data.transform
        result.rep.removeAttribute("transform")
        result.commit()

      return result

    else if type is "use"
      return false # No use tags for now fuck that ^_^

    else
      return null # Unknown tag, ignore it


  makeData: (elem) ->
    blacklist = ["inkscape", "sodipodi", "uuid"]

    blacklistCheck = (key) ->
      for x in blacklist
        if key.indexOf(x) > -1
          return false
      true

    attrs = elem.attributes
    data = {}

    for key, val of attrs
      key = val.name
      val = val.value
      continue if key is ""

      # Don't keep style attributes. Carry them out.
      # style should only be used for temporary transformations,
      # not permanent ones.
      if key is "style" and elem.nodeName isnt "text"
        data = @applyStyles(data, val)
      else if val? and blacklistCheck(key)
        if /^\d+$/.test val
          val = float val
        data[key] = val

    # By now any transform attrs should be permanent
    #elem.removeAttribute("transform")

    data

  applyStyles: (data, styles) ->
    blacklist = ["display", "transform"]
    styles = styles.split ";"
    for style in styles
      style = style.split ":"
      key = style[0]
      val = style[1]
      continue if blacklist.has key
      data[key] = val
    data


  parseAndAppend: (input, makeNew) ->
    parsed = @parse(input, makeNew)
    parsed.map (elem) -> elem.appendTo('#main')
    ui.refreshAfterZoom()
    parsed


  prepareForExport: ->
    for elem in ui.elements
      if elem.type is "path"
        if elem.virgin?
          elem.virginMode()
      elem.cleanUpPoints?()


  cleanUpAfterExport: ->
    for elem in ui.elements
      if elem.type is "path"
        if elem.virgin?
          elem.editMode()


  makeFile: () ->
    @prepareForExport()

    # Get the file
    main = new XMLSerializer().serializeToString dom.main

    @cleanUpAfterExport()

    # Newlines! This is hacky.
    # Make better whitespace management happen later
    main = main.replace(/>/gi, ">\n")

    # Attributes to never export, for internal use at runtime only
    blacklist = ["uuid"]

    for attr in blacklist
      main = main.replace(new RegExp(attr + '\\=\\"\[\\d\\w\]*\\"', 'gi'), '')

    # Return the file with a comment in the beginning
    # linking to Mondy
    """
    <!-- Made in Mondrian.io -->
    #{main}
    """


  makeBase64: ->
    btoa @makeFile()


  makeBase64URI: ->
    "data:image/svg+xml;charset=utf-8;base64,#{@makeBase64()}"


  makePNGURI: (elements = ui.elements, maxDimen = undefined) ->
    sandbox = dom.pngSandbox
    context = sandbox.getContext("2d")

    if elements.length
      bounds = @getBounds(elements)
    else
      bounds = @getBounds(dom.main)

    sandbox.setAttribute "width", bounds.width
    sandbox.setAttribute "height", bounds.height

    if maxDimen?
      s = Math.max(context.canvas.width, context.canvas.height) / maxDimen
      context.canvas.width /= s
      context.canvas.height /= s
      context.scale(1 / s, 1 / s)

    if typeof elements is "string"
      elements = @parse elements, false

    for elem in elements
      elem.drawToCanvas(context)

    sandbox.toDataURL("png")


window.io = io

###
Mondrian vector editor
http://mondrian.io

This software is available under the MIT License. Have fun with it.
Contact: me@artur.co
###
###

  Built-in prototype extensions

###


# Math

Math.lerp = (a, b, c) -> b + a * (c - b)

# Used in approximating circle/ellipse with cubic beziers.
# References:
#   http://www.whizkidtech.redprince.net/bezier/circle/
#   http://www.whizkidtech.redprince.net/bezier/circle/kappa/
Math.KAPPA = 0.5522847498307936


# String

String::toFloat = -> # Take only digits and decimals, then parseFloat.
  return parseFloat(@valueOf().match(/[\d\.]/g).join(''))

# Does phrase exist within a string, verbatim?
String::mentions = (phrase) ->
  if typeof(phrase) is 'string'
    return @indexOf(phrase) > -1
  else if phrase instanceof Array
    for p in phrase
      return true if @mentions p
    return false

# Same thing for this silly shit, idk ¯\_(ツ)_/¯
SVGAnimatedString::mentions = (phrase) ->
  @baseVal.mentions(phrase)

String::capitalize = ->
  # 'artur' => 'Artur'
  @charAt(0).toUpperCase() + @slice(1)

String::camelCase = ->
  # 'slick duba' => 'slickDuba'
  @split(/[^a-z]/gi).map((x, ind) ->
    if ind is 0 then x else x.capitalize()
  ).join('')

String::strip = ->
  # Strip spaces on beginning and end
  @replace /(^\s*)|(\s+$)|\n/g, ''


# Number

Number::px = ->
  # 212.12345 => '212.12345px'
  "#{@toPrecision()}px"

Number::invert = ->
  # 4 => -4
  # -4 => 4
  @ * -1

Number::within = (tolerance, other) ->
  # I/P: Two numbers
  # O/P: Is this within tolerance of other?
  d = @ - other
  d < tolerance and d > -tolerance

Number::roundIfWithin = (tolerance) ->
  if (Math.ceil(@) - @) < tolerance
    return Math.ceil @
  else if (@ - Math.floor(@)) < tolerance
    return Math.floor(@)
  else
    return @valueOf()

Number::ensureRealNumber = ->
  # For weird edgecases that cause NaN bugs,
  # which are incredibly annoying
  val = @valueOf()
  fuckedUp = (val is Infinity or val is -Infinity or isNaN val)
  if fuckedUp then 1 else val

Number::toNearest = (n, tolerance) ->
  # Round to the nearest increment of n, starting at 0
  # Used in snapping.
  #
  # I/P: n: any value
  #      tolerance: optional tolerance:
  #                 only round if it's within this
  #                 much of what it would round to
  # Examples:
  # x = 4.22
  #
  # x.toNearest(1) == 4
  # x.toNearest(0.1) == 4.2
  # x.toNearest(250) == 0
  #
  # Not within the tolerance:
  # x.toNearest(0.1, 0.01) == 4.22

  add = false
  val = @valueOf()
  if val < 0
    inverse = true
    val *= -1
  offset = val % n
  if offset > n / 2
    offset = n - offset
    add = true
  if tolerance? and offset > tolerance
    return val
  if offset < n / 2
    if add
      val = val + offset
    else
      val = val - offset
  else
    if add
      val = val - (n - offset)
    else
      val = val + (n - offset)
  if inverse
    val *= -1
   val


# Array

Array::remove = (el) ->
  # Remove elements
  # I/P: Regexp or Array or any other value
  # O/P: When given Regexp, removes all elements that
  #      match it (assumed strings).
  #      When Array, removes all elements that are
  #      in the given array.
  #      When any other value, removes all elements
  #      that equal that value. (compared with !==)

  if el instanceof RegExp
    return @filter((a) ->
      not el.test a
    )
  else
    if el instanceof Array
      return @filter((a) ->
        not el.has a)
    else
      return @filter((a) ->
        el isnt a)

Array::has = (el) ->
  # I/P: Anything
  # O/P: Bool: does it contain the given value?
  if el instanceof Function
    return @filter(el).length > 0
  else
    return @indexOf(el) > -1

Array::find = (func) ->
  for i in [0..@length]
    if func(@[i])
      return @[i]

Array::ensure = (el) ->
  # Push if not included already
  if @indexOf(el) == -1
    @push el

# Why not
Array::first = ->
  @[0]

Array::last = ->
  @[@length - 1]

Array::sortByZIndex = ->
  # This is really stupidly specific
  @sort (a, b) ->
    if a.zIndex() < b.zIndex()
      return -1
    else
      return 1

# Replace r with w
Array::replace = (r, w) ->
  ind = @indexOf(r)
  if ind == -1
    return @
  else
    return @slice(0, ind).concat(if w instanceof Array then w else [w]).concat(@slice(ind + 1))

Array::cannibalize = ->
  # Returns itself with first elem at the end
  @push @[0]
  @slice 1


Array::cannibalizeUntil = (elem) ->
  # Cannibalize until elem is at index 0
  placesAway = @indexOf elem
  head = @splice placesAway
  head.concat @

Array::without = (elem) ->
  @filter (x) -> x != elem


# DOM Element

Element::remove = ->
  if @parentElement isnt null
    @parentElement.removeChild @

Element::removeChildren = ->
  while @childNodes.length > 0
    @childNodes[0].remove()

Element::toString = ->
  new XMLSerializer.serializeToString @

Number::places = (x) ->
  parseFloat @toFixed(x)

# Simple yet helpful lil' guy

class Set extends Array

  constructor: (array) ->
    for elem in array
      unless @has elem
        @push elem
    super

  push: (elem) ->
    return if @has elem
    super elem

window.Set = Set
###

  Settings

  Production/development-dependent settings

  Meowset is Mondrian's backend server.

###

SETTINGS = {}
  # Flag: are we in production?

SETTINGS.PRODUCTION = (/mondrian/.test document.location.host)

SETTINGS.MEOWSET =
  # Show UI for backend features?
  # TODO implement
  AVAILABLE: true
  # Backend endpoint
  ENDPOINT: if SETTINGS.PRODUCTION then "http://meowset.mondrian.io" else "http://localhost:8000"

SETTINGS.BONITA =
  # New replacement app backend for Meowset
  ENDPOINT: if SETTINGS.PRODUCTION then "http://bonita.mondrian.io" else "http://localhost:8080"

SETTINGS.EMBED =
  AVAILABLE: true
  ENDPOINT: if SETTINGS.PRODUCTION then "http://embed.mondrian.io" else "http://localhost:8000"

  # Maths
SETTINGS.MATH =
  POINT_DECIMAL_PLACES: 5
  POINT_ROUND_DGAF: 1e-5
  # Cursor
SETTINGS.DOUBLE_CLICK_THRESHOLD = 600

SETTINGS.DRAG_THRESHOLD = 3

CONSTANTS =
  MATCHERS:
    POINT: /[MLCSHV][\-\de\.\,\-\s]+/gi

  SVG_NAMESPACE: "http://www.w3.org/2000/svg"
###

  Setup

  Bind $(document).ready
  Global exports

###

appLoaded = false

setup = []

# For state preservation, run setup functions
# after everything is initialized with the DOM
secondRoundSetup = []

$(document).ajaxSend -> ui.logo.animate()

$(document).ajaxComplete -> ui.logo.stopAnimating()

$(document).ready ->
  for procedure in setup
    procedure()

  appLoaded = true

  for procedure in secondRoundSetup
    procedure()

  # Make damn sure the window isnt off somehow because
  # they wont be able to undo it
  setTimeout ->
    window.scrollTo 0, 0
  , 500

###

  Utils

  Random little snippets to make things easier.
  Default prototype extensions for String, Array, Math... everything

  Add miscellaneous helpers that can be useful in more than one file here, since
  this gets compiled before everything else.

         _____
        /__    \
        ___) E| -_
       \_____  -_  -_
                 -_  -_
                   -_  -_
                     -_ o |
                       -_ /     This is a wrench ok?

###

print = -> console.log.apply console, arguments


async = (fun) ->
  # Shorthand for breaking out of current execution block
  # Usage:
  #
  # async ->
  #   do shit

  setTimeout fun, 1


# Shorthand for querySelector and querySelectorAll
# querySelectorAll is like six times slower,
# so only use it when necessary.
# That being said, it's still better
# than using $() just to select shit
q = (query) ->
  document.querySelector.call(document, query)

qa = (query) ->
  document.querySelectorAll.call(document,query)


window.uuid = (len = 20) ->
  # Generates
  id = ''
  chars = ('abcdefghijklmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
          '1234567890').split('')

  for i in [1..len]
    id += chars[parseInt(Math.random() * 62, 10)]
  id


# This shit sucks:
# TODO remove this or do it better
# Checks if a given event target is one of the shapes on the board
isSVGElement = (target) ->
  target.namespaceURI is 'http://www.w3.org/2000/svg'

isSVGElementInMain = (target) ->
  target.namespaceURI is 'http://www.w3.org/2000/svg' and $(target).closest("#main").length > 0 and target.id isnt 'main'

# Testing if target is certain type of handle
isPointHandle = (target) ->
  target.className is 'transform handle point'

isBezierControlHandle = (target) ->
  target.className is 'transform handle point bz-ctrl'

isTransformerHandle = (target) ->
  target.className.mentions 'transform handle'

isHoverTarget = (target) ->
  target.parentNode?.id is 'hover-targets'

# Testing if target is any type of handle
isHandle = (target) ->
  if target.nodeName.toLowerCase() is 'div'
    return target.className.mentions 'handle'
  return false

isTextInput = (target) ->
  target.nodeName.toLowerCase() is "input" and target.getAttribute("type") is "text"

isUtilityWindow = (target) ->
  target.className.mentions("utility-window") or $(target).closest('.utility-window').length > 0

isSwatch = (target) ->
  target.className.mentions("swatch")

# This really sucks
# TODO anything else
isOnTopUI = (target) ->
  if typeof target.className is "string"
    cl = target.className.split(" ")
    if cl.has("disabled")
      return false
    if cl.has("tool-button")
      return "tb"
    else if cl.has("menu")
      return "menu"
    else if cl.has("menu-item")
      return "menu-item"
    else if cl.has("menu-dropdown")
      return "dui"

  if target.hasAttribute("buttontext")
    return true

  if target.nodeName.toLowerCase() is "a"
    return true

  if target.id is "hd-file-loader"
    return "file-loader"
  else if isTextInput target
    return "text-input"
  else if isUtilityWindow target
    return "utility-window"
  else if isSwatch target
    return "swatch"

  false

# </sucks>


allowsHotkeys = (target) ->
  $(target).closest("[h]").length > 0

isDefaultQuarantined = (target) ->
  if target.hasAttribute "quarantine"
    return true
  else if $(target).closest("[quarantine]").length > 0
    return true
  else
    return false

queryElemByUUID = (uuid) ->
  ui.queryElement(q('#main [uuid="' + uuid + '"]'))

queryElemByZIndex = (zi) ->
  ui.queryElement(dom.$main.children()[zi])



cleanUpNumber = (n) ->
  n = n.roundIfWithin(SETTINGS.MATH.POINT_ROUND_DGAF)
  n = n.places(SETTINGS.MATH.POINT_DECIMAL_PLACES)
  n

int = (n) ->
  parseInt n, 10

float = (n) ->
  parseFloat n

oots = Object::toString

Object::toString = ->
  if @ instanceof $
    return "$('#{@selector}') object"
  else
    try
      return JSON.stringify @
    catch e
      oots.call @


objectValues = (obj) ->
  vals = []
  for own key, val of obj
    vals.push val
  vals


cloneObject = (obj) ->
  newo = new Object()
  for own key, val of obj
    newo[key] = val
  newo

sortNumbers = (a, b) ->
  if a < b
    return -1
  else if a > b
    return 1
  else if a == b
    return 0
###

  jQuery plugins
  Baw baw baw. Let's use these with moderation.

###


$.fn.hotkeys = (hotkeys) ->
  # Grant an input field its own hotkeys upon focus.
  # On blur, reset to the app hotkeys.
  self = @

  $(@).attr("h", "").focus ->
    ui.hotkeys.enable()
    ui.hotkeys.using =
      context: self
      ignoreAllOthers: false
      down: hotkeys.down
      up: hotkeys.up
      always: hotkeys.always
  .blur ->
    #ui.hotkeys.use "app"



$.fn.nudge = (x, y, min = {x: -1/0, y: -1/0}, max = {x: 1/0, y: 1/0}) ->
  $self = $ @
  left = $self.css("left")
  top = $self.css("top")

  if $self.attr("drag-x")
    minmax = $self.attr("drag-x").split(" ").map((x) -> parseInt(x, 10))
    min.x = minmax[0]
    max.x = minmax[1]
  if $self.attr("drag-y")
    minmax = $self.attr("drag-y").split(" ").map((x) -> parseInt(x, 10))
    min.y = minmax[0]
    max.y = minmax[1]

  $self.css
    left: Math.max(min.x, Math.min(max.x, (parseFloat(left) + x))).px()
    top:  Math.max(min.y, Math.min(max.y, (parseFloat(top) + y))).px()
  $self.trigger("nudge")


$.fn.fitToVal = (add = 0) ->
  $self = $ @
  resizeAction = (e) ->
    val = $self.val()
    $ghost = $("<div id=\"ghost\">#{val}</div>").appendTo(dom.$body)
    $self.css
      width: "#{$ghost.width() + add}px"
    $ghost.remove()

  $self.unbind('keyup.fitToVal').on('keyup.fitToVal', resizeAction)
  resizeAction()

$.fn.disable = ->
  $self = $ @
  $self.attr "disabled", ""

$.fn.enable = ->
  $self = $ @
  $self.removeAttr "disabled"

$.fn.error = (msg) ->
  $self = $ @
  $err = $self.siblings('.error-display').show()
  $err.find('.lifespan').removeClass('empty')
  $err.find('.msg').text(msg)
  async -> $err.find('.lifespan').addClass('empty')
  setTimeout ->
    $err.hide()
  , 5 * 1000

$.fn.pending = (html) ->
  $self = $ @
  oghtml = $self.html()
  $self.addClass "pending"
  $self.html html
  ->
    $self.html oghtml
    $self.removeClass "pending"

###

  Google Analytics tracking.

###

trackEvent = (category, event, lbl) ->
  # Abstraction for _gaq _trackEvent
  label = "#{ui.account}"
  label += ": #{lbl}" if lbl?
  if SETTINGS.PRODUCTION
    _gaq.push ['_trackEvent', category, event, label]
  else
    #print "track", category, event, label

###

  Common object mixins. To use a mixin,

    $.extend(myObject, mixins.desiredMixin)

###

mixins = {}

###

  Standard event system

###

mixins.events =

  _handlers: {}

  on: (event, handler) ->
    @_handlers[event] ?= []
    @_handlers[event].push handler

  off: (event) ->
    delete @_handlers[event]

  trigger: ->
    # I/P: event name, then arbitrary amt of arguments
    # ex: @trigger('change', @title, @message)

    @_handlers[arguments[0]]?.forEach (handler) ->
      args = Array::slice.call arguments, 1
      handler.apply @, args

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

###

  Management class for fontfaces

###

class Font
  constructor: (@name) ->

  toListItem: ->
    $("""
      <div class="dropdown-item" style="font-family: '#{@name}'">
        #{@name}
      </div>
    """)



###

  Color

  A nice lil' class for representing and manipulating colors.

###



class Color

  constructor: (@r, @g, @b, @a = 1.0) ->

    if @r instanceof Color
      return @r
    if @r is null
      @hex = "none"
    else if @r is "none"
      @hex = "none"
      @r = null
      @g = null
      @b = null
    else
      if typeof @r is "string"
        if @r.charAt(0) == "#" or @r.length == 6
          # Convert hex to rgba
          @hex = @r.toUpperCase().replace("#", "")
          rgb = @hexToRGB @hex
          @r = rgb.r
          @g = rgb.g
          @b = rgb.b
        else if @r.match(/rgba?\(.*\)/gi)?
          # rgb(r,g,b)
          vals = @r.match(/[\d\.]+/gi)
          @r = vals[0]
          @g = vals[1]
          @b = vals[2]
          if vals[3]?
            @a = parseFloat vals[3]
          @hex = @rgbToHex @r, @g, @b


      else
        if not @g? and not @b?
          @g = @r
          @b = @r
        @hex = @rgbToHex @r, @g, @b

      @r = Math.min(@r, 255)
      @g = Math.min(@g, 255)
      @b = Math.min(@b, 255)

      @r = Math.max(@r, 0)
      @g = Math.max(@g, 0)
      @b = Math.max(@b, 0)

    if isNaN @r or isNaN @g or isNaN @b
      @r = 0 if isNaN @r
      @g = 0 if isNaN @g
      @b = 0 if isNaN @b
      debugger
      @updateHex()



  clone: -> new Color(@r, @g, @b)


  absorb: (color) ->
    @r = color.r
    @g = color.g
    @b = color.b
    @a = color.a
    @hex = color.hex
    @refresh?()
    @


  min: ->
    [@r, @g, @b].sort((a, b) -> a - b)[0]


  mid: ->
    [@r, @g, @b].sort((a, b) -> a - b)[1]


  max: ->
    [@r, @g, @b].sort((a, b) -> a - b)[2]


  midpoint: -> @max() / 2


  valToHex: (val) ->
    chars = '0123456789ABCDEF'
    chars.charAt((val - val % 16) / 16) + chars.charAt(val % 16)


  hexToVal: (hex) ->
    chars = '0123456789ABCDEF'
    chars.indexOf(hex.charAt(0)) * 16 + chars.indexOf(hex.charAt(1))


  rgbToHex: (r, g, b) ->
    "#{@valToHex r}#{@valToHex g}#{@valToHex b}"


  hexToRGB: (hex) ->
    r = @hexToVal hex.substring(0, 2)
    g = @hexToVal hex.substring(2, 4)
    b = @hexToVal hex.substring(4, 6)
    r: r
    g: g
    b: b


  recalculateHex: ->
    @hex = @rgbToHex(@r, @g, @b)


  darken: (amt) ->
    macro = (val) ->
      val / amt
    new Color(macro(@r), macro(@g), macro(@b))


  lightness: ->
    # returns float 0.0 - 1.0
    ((@min() + @max()) / 2) / 255


  saturation: ->
    max = @max()
    min = @min()
    d = max - min

    sat = if @lightness() >= 0.5 then d / (510 - max - min) else d / (max + min)
    sat = 1.0 if isNaN sat
    sat


  desaturate: (amt = 1.0) ->
    mpt = @midpoint()
    @r -= (@r - mpt) * amt
    @g -= (@g - mpt) * amt
    @b -= (@b - mpt) * amt
    @hex = @rgbToHex @r, @g, @b
    @


  lighten: (amt = 0.5) ->
    amt *= 255
    @r = Math.min(255, @r + amt)
    @g = Math.min(255, @g + amt)
    @b = Math.min(255, @b + amt)
    @hex = @rgbToHex @r, @g, @b
    @


  toRGBString: ->
    if @r is null
      return "none"
    else
      return "rgba(#{@r}, #{@g}, #{@b}, #{@a})"


  toHexString: ->
    "##{@hex}"


  toString: ->
    @removeNaNs() # HACK
    @toRGBString()


  removeNaNs: ->
    # HACK BUT IT WORKS FOR NOW LOL FUCK NAN
    if isNaN @r
      @r = 0
    if isNaN @g
      @g = 0
    if isNaN @b
      @b = 0


  equal: (c) ->
    @toHexString() == c.toHexString()


  updateHex: ->
    @hex = @rgbToHex @r, @g, @b





window.Color = Color



###

  Lab

  Geometry conversions, operations, helpers

      ___
      | |
      | |
      | |
      | |
     -   -
    -   - -
   /    -  \
  |     -   |
  |    -    |
  |_________|

###

lab = {}



lab.analysis =

  intersections: (a, b) ->
    a.lineSegmentIntersections b


# Geometry conversions and operations

lab.conversions =
  pathSegment: (a, b = a.succ) ->
    # Returns the LineSegment or BezierCurve that connects two bezier points
    #   (MoveTo, LineTo, CurveTo, SmoothTo)
    #
    # I/P:
    #   a: first point
    #   b: second point
    # O/P: LineSegment or CubiBezier


    if b instanceof LineTo or b instanceof MoveTo or b instanceof HorizTo or b instanceof VertiTo
      return new LineSegment(new Posn(a.x, a.y), new Posn(b.x, b.y), b)

    else if b instanceof CurveTo
      # CurveTo creates a CubicBezier

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b)

    else if b instanceof SmoothTo
      # SmoothTo creates a CubicBezier also, but it derives its p2 as the
      # reflection of the previous point's p3 reflected over its p4

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b)


  nextSubstantialPathSegment: (point) ->
    # Skip any points within 1e-6 of each other
    while point.within(1e-6, point.succ)
      point = point.succ

    return @pathSegment point, point.succ

  previousSubstantialPathSegment: (point) ->
    # Skip any points within 1e-6 of each other
    while point.within(1e-6, point.prec)
      point = point.prec

    return @pathSegment point, point.prec

  stringToAlop: (string, owner) ->
    # Given a d="M204,123 C9023........." string,
    # return an array of Points.

    results = []
    previous = undefined

    all_matches = string.match(CONSTANTS.MATCHERS.POINT)

    for point in all_matches
      # Point's constructor decides what kind of subclass to make
      # (MoveTo, CurveTo, etc)
      p = new Point(point, owner, previous)

      if p instanceof Point
        p.setPrec previous if previous?
        previous = p # Set it for the next point

        # Don't remember why I did this.
        if (p instanceof SmoothTo) and (owner instanceof Point)
          p.setPrec owner

        results.push p

      else if p instanceof Array
        # There's an edge case where you can get an array of a MoveTo followed by LineTos.
        # Terrible function signature design, I know
        # TODO fix this hack garbage
        if previous?
          p[0].setPrec previous
          p.reduce (a, b) -> b.setPrec a

        results = results.concat p

    results

  posn:

    clientToCanvas: (p) ->
      p = p.clone()
      p.x -= ui.canvas.normal.x
      p.y -= ui.canvas.normal.y
      p

    canvasToClient: (p) ->
      p = p.clone()
      p.x += ui.canvas.normal.x
      p.y += ui.canvas.normal.y
      p

    canvasZoomedToClient: (p) ->
      p = p.multiplyBy(ui.canvas.zoom)
      @canvasToClient(p)

    clientToCanvasZoomed: (p) ->
      @clientToCanvas(p).multiplyBy(1 / ui.canvas.zoom)

class Transformations
  constructor: (@owner, @transformations) ->
    transform = @owner.rep.getAttribute "transform"
    @transformations.map (t) => t.family = @
    @parseExisting transform if transform?

  commit: ->
    @owner.data.transform = @toAttr()

  toAttr: ->
    @transformations.map((t) -> t.toAttr()).join " "

  toCSS: ->
    @transformations.map((t) -> t.toCSS()).join " "

  get: (key) ->
    f = @transformations.filter (t) -> t.key is key
    return f[0] if f.length > 0

  parseExisting: (transform) ->
    operations = transform.match /\w+\([^\)]*\)/g
    for op in operations
      # get the keyword, like "rotate" from "rotate(10)"
      keyword = op.match(/^\w+/g)[0]
      alreadyDefined = @get keyword
      if alreadyDefined?
        alreadyDefined.parse op
      else
        representative = {
          rotate: RotateTransformation
          scale:  ScaleTransformation
        }[keyword]
        if representative?
          newlyDefined = new representative().parse(op)
          newlyDefined.family = @
          @transformations.push newlyDefined

  applyAsCSS: (rep) ->
    og = "-#{@owner.origin.x} -#{@owner.origin.y}"
    tr = @toCSS()
    rep.style.transformOrigin = og
    rep.style.webkitTransformOrigin = og
    rep.style.mozTransformOrigin = og
    rep.style.transform = tr
    rep.style.webkitTransformOrigin = og
    rep.style.webkitTransform = tr
    rep.style.mozTransformOrigin = og
    rep.style.mozTransform = tr

class RotateTransformation
  constructor: (@deg, @family) ->

  key: "rotate"

  toAttr: ->
    "rotate(#{@deg.places 3} #{@family.owner.center().x.places 3} #{@family.owner.center().y.places 3})"

  toCSS: ->
    "rotate(#{@deg.places 3}deg)"

  rotate: (a) ->
    @deg += a
    @deg %= 360
    @

  parse: (op) ->
    [@deg, x, y] = op.match(/[\d\.]+/g).map parseFloat


class ScaleTransformation
  constructor: (@x = 1, @y = 1) ->

  key: "scale"

  toAttr: ->
    "scale(#{@x} #{@y})"

  toCSS: ->
    "scale(#{@x}, #{@y})"

  parse: (op) ->
    [@x, @y] = op.match(/[\d\.]+/g).map parseFloat

  scale: (x = 1, y = 1) ->
    @x *= x
    @y *= y

class TranslateTransformation
  constructor: (@x = 0, @y = 1) ->

  key: "translate"

  toAttr: ->
    "translate(#{@x} #{@y})"

  toCSS: ->
    "translate(#{@x}px, #{@y}px)"

  parse: (op) ->
    [@x, @y] = op.match(/[\-\d\.]+/g).map parseFloat

  nudge: (x, y) ->
    console.log x, y
    @x += x
    @y -= y


###

  Posn

    •
      (x, y)


  Lowest-level geometry class.

  Consists of x, y coordinates. Provides methods for manipulating or representing
  the point in two-dimensional space.

  Superclass: Point

###

class Posn

  constructor: (@x, @y, @zoomLevel = 1.0) ->
    # I/P:
    #   x: number
    #   y: number
    #
    #     OR
    #
    #   e: Event object with clientX and clientY values

    if @x instanceof Object
      # Support for providing an Event object as the only arg.
      # Reads the clientX and clientY values
      if @x.clientX? and @x.clientY?
        @y = @x.clientY
        @x = @x.clientX
      else if @x.left? and @x.top?
        @y = @x.top
        @x = @x.left
      else if @x.x? and @x.y?
        @y = @x.y
        @x = @x.x

    else if (typeof @x == "string") and (@x.mentions ",")
      # Support for giving a string of two numbers and a comma "12.3,840"
      split = @x.split(",").map parseFloat
      x = split[0]
      y = split[1]
      @x = x
      @y = y

    # That's fucking it.
    @

  # Rounding an you know

  cleanUp: ->
    # TODO
    # This was giving me NaN bullshit. Don't enable again until the app is stable
    # and we can test it properly
    return
    @x = cleanUpNumber @x
    @y = cleanUpNumber @y


  # Zoom compensation

  # By default, all Posns are interpreted as they are explicitly invoked. x is x, y is y.
  # You can call Posn.zoom() to ensure you're using a zoom-adjusted version of this Posn.
  #
  # In this case, x is x times the zoom level, and the same goes for y.
  #
  # Posn.unzoom() takes it back to zoom-agnostic mode - 1.0


  zoomed: (level = ui.canvas.zoom) ->
    # Return this Posn after ensuring it is at the given zoom level.
    # If no level is given, current zoom level of document is used.
    #
    # I/P: level: float (optional)
    #
    # O/P: adjusted Posn

    return @ if @zoomLevel is level

    @unzoomed()

    @alterValues (val) -> val *= level
    @zoomLevel = level
    @


  unzoomed: ->
    # Return this Posn after ensuring it is in 100% "true" mode.
    #
    # No I/P
    #
    # O/P: adjusted Posn

    return @ if @zoomLevel is 1.0

    @alterValues (val) => val /= @zoomLevel
    @zoomLevel = 1.0
    @


  setZoom: (@zoomLevel) ->
    @x /= @zoomLevel
    @y /= @zoomLevel
    @


  # Aliases:


  zoomedc: ->
    @clone().zoomed()


  unzoomedc: ->
    @clone.unzoomed()


  # Helper:


  alterValues: (fun) ->
    # Do something to all the values this Posn has. Kind of like map, but return is immediately applied.
    #
    # Since Posns get superclassed into Points which get superclassed into CurvePoints,
    # they may have x2, y2, x3, y3 attributes. This checks which ones it has and alters all of them.
    #
    # I/P: fun: one-argument function to be called on each of this Posn's values.
    #
    # O/P: self

    for a in ["x", "y", "x2", "y2", "x3", "y3"]
      @[a] = if @[a]? then fun(@[a]) else @[a]
    @


  toString: ->
    "#{@x},#{@y}"

  toJSON: ->
    x: @x
    y: @y

  toConstructorString: ->
    "new Posn(#{@x},#{@y})"


  nudge: (x, y) ->
    @x += x
    @y -= y

    @

  lerp: (b, factor) ->
    new Posn(@x + (b.x - @x) * factor, @y + (b.y - @y) * factor)

  gte: (p) ->
    @x >= p.x and @y >= p.y

  lte: (p) ->
    @x <= p.x and @y <= p.y

  directionRelativeTo: (p) ->
    "#{if @y < p.y then "t" else (if @y > p.y then "b" else "")}#{if @x < p.x then "l" else (if @x > p.x then "r" else "")}"

  squareUpAgainst: (p) ->
    # Takes another posn as an anchor, and nudges this one
    # so that it's on the nearest 45° going off of the anchor posn.

    xDiff = Math.abs(@x - p.x)
    yDiff = Math.abs(@y - p.y)
    direction = @directionRelativeTo p

    return p if (xDiff is 0) and (yDiff is 0)

    switch direction
      when "tl"
        if xDiff < yDiff
          @nudge(xDiff - yDiff, 0)
        else if yDiff < xDiff
          @nudge(0, xDiff - yDiff, 0)
      when "tr"
        if xDiff < yDiff
          @nudge(yDiff - xDiff, 0)
        else if yDiff < xDiff
          @nudge(0, xDiff - yDiff)
      when "br"
        if xDiff < yDiff
          @nudge(yDiff - xDiff, 0)
        else if yDiff < xDiff
          @nudge(0, yDiff - xDiff)
      when "bl"
        if xDiff < yDiff
          @nudge(xDiff - yDiff, 0)
        else if yDiff < xDiff
          @nudge(0, yDiff - xDiff)
      when "t", "b"
        @nudge(yDiff, 0)
      when "r", "l"
        @nudge(0, xDiff)
    @


  equal: (p) ->
    @x is p.x and @y is p.y

  min: (p) ->
    new Posn(Math.min(@x, p.x), Math.min(@y, p.y))

  max: (p) ->
    new Posn(Math.max(@x, p.x), Math.max(@y, p.y))

  angle360: (base) ->
    a = 90 - new LineSegment(base, @).angle
    return a + (if @x < base.x then 180 else 0)

  rotate: (angle, origin = new Posn(0, 0)) ->

    return @ if origin.equal @

    angle *= (Math.PI / 180)

    # Normalize the point on the origin.
    @x -= origin.x
    @y -= origin.y

    x = (@x * (Math.cos(angle))) - (@y * Math.sin(angle))
    y = (@x * (Math.sin(angle))) + (@y * Math.cos(angle))

    # Move points back to where they were.
    @x = x + origin.x
    @y = y + origin.y

    @

  scale: (x, y, origin = new Posn(0, 0)) ->
    @x += (@x - origin.x) * (x - 1)
    @y += (@y - origin.y) * (y - 1)
    @

  copy: (p) ->
    @x = p.x
    @y = p.y


  clone: ->
    # Just make a new Posn, and maintain the zoomLevel
    new Posn(@x, @y, @zoomLevel)


  snap: (to, threshold = Math.INFINITY) ->
    # Algorithm: bisect the line on this posn's x and y
    # coordinates and return the midpoint of that line.
    perpLine = @verti(10000)
    perpLine.rotate(to.angle360() + 90, @)
    perpLine.intersection to


  reflect: (posn) ->
    ###

      Reflect the point over an x and/or y axis

      I/P:
        posn: Posn

    ###

    x = posn.x
    y = posn.y

    return new Posn(x + (x - @x), y + (y - @y))

  distanceFrom: (p) ->
    new LineSegment(@, p).length

  perpendicularDistanceFrom: (ls) ->
    ray = @verti(1e5)
    ray.rotate(ls.angle360() + 90, @)
    #ui.annotations.drawLine(ray.a, ray.b)
    inter = ray.intersection ls
    if inter?
      ls = new LineSegment(@, inter)
      len = ls.length
      return [len, inter, ls]
    else
      return null

  multiplyBy: (s) ->
    switch typeof s
      when 'number'
        np = @clone()
        np.x *= s
        np.y *= s
        return np
      when 'object'
        np = @clone()
        np.x *= s.x
        np.y *= s.y
        return np

  multiplyByMutable: (s) ->
    @x *= s
    @y *= s

    if @x2?
      @x2 *= s
      @y2 *= s

    if @x3?
      @x3 *= s
      @y3 *= s

  add: (s) ->
    switch typeof s
      when 'number'
        return new Posn(@x + s, @y + s)
      when 'object'
        return new Posn(@x + s.x, @y + s.y)

  subtract: (s) ->
    switch typeof s
      when 'number'
        return new Posn(@x - s, @y - s)
      when 'object'
        return new Posn(@x - s.x, @y - s.y)

  setPrec: (@prec) ->

  setSucc: (@succ) ->


  ###
      I love you artur
      hackerkate nows the sick code
  ###

  inRanges: (xr, yr) ->
    xr.contains @x and yr.contains @y

  inRangesInclusive: (xr, yr) ->
    xr.containsInclusive(@x) and yr.containsInclusive(@y)

  verti: (ln) ->
    new LineSegment(@clone().nudge(0, -ln), @clone().nudge(0, ln))

  insideOf: (shape) ->
    # Draw a horizontal ray starting at this posn.
    # If it intersects the shape's perimeter an odd
    # number of times, the posn's inside of it.
    #
    #    _____
    #  /      \
    # |   o----X------------
    #  \______/
    #
    #  1 intersection - it's inside.
    #
    #    __         __
    #  /   \      /    \
    # |  o--X----X-----X---------
    # |      \__/      |
    #  \______________/
    #
    #  3 intersections - it's inside.
    #
    #  etc.

    if shape instanceof Polygon or shape instanceof Path
      ray = new LineSegment(@, new Posn(@x + 1e+20, @y))
      counter = 0
      shape.lineSegments().map((a) ->
        inter = a.intersection(ray)
        if inter instanceof Posn
          ++ counter
        else if inter instanceof Array
          counter += inter.length
      )

      # If there's an odd number of intersections, we are inside.
      return counter % 2 == 1

    # Rect
    # This one is trivial. Method lives in the Rect class.
    if shape instanceof Rect
      return shape.contains @


  dot: (v) ->
    @x * v.x + @y * v.y

  within: (tolerance, posn) ->
    Math.abs(@x - posn.x) < tolerance and Math.abs(@y - posn.y) < tolerance

  parseInt: ->
    @x = parseInt(@x, 10)
    @y = parseInt(@y, 10)


Posn.fromJSON = (json) ->
  new Posn(json.x, json.y)

###

  Point



     o -----------
    /
   /
  /

  Tangible body for posn.
  Stored in PointsList for every shape.
  Comes in many flavors for a Path:
    MoveTo
    LineTo
    HorizTo
    VertiTo
    CurvePoint
      CurveTo
      SmoothTo

  This is the most heavily sub-classed class, even heavier than Monsvg.
  It's also the most heavily used, since all shapes are made of many of these.

  Needless to say, this is a very important class.
  Its efficiency basically decides the entire application's speed.
  (Not sure it's as good as it could be right now)

###

class Point extends Posn

  constructor: (@x, @y, @owner) ->
    @constructArgs = arguments
    return if (not @x?) and (not @y?)


    # Robustness principle!
    # You can make a Point in many ways.
    #
    #   Posn: Give a posn, and it will just inherit the x and y positions
    #   Event:
    #     Give it an event with clientX and clientY
    #   Object:
    #     Give it a generic Object with an x and y
    #   String:
    #     Give it an SVG string like "M10 20"
    #
    # It will do what's most appropriate in each case; for the first three
    # it will just inherit x and y values from the input. In the third case
    # given an SVG string it will actually return a subclass of itself based
    # on what the string is.

    if @x instanceof Posn
      @owner = @y
      @y = @x.y
      @x = @x.x
    else if @x instanceof Object
      @owner = @y
      if @x.clientX?
        # ...then it's an Event object
        @y = @x.clientY
        @x = @x.clientX
      else if @x.x? and @x.y?
        # ...then it's some generic object
        @y = @x.y
        @x = @x.x
    else if typeof @x is "string"
      # Call signature in this case:
      # new Point(pointString, owner, prec)
      # Example in lab.conversions.stringToAlop
      prec   = @owner if @owner?
      @owner = @y if @y?
      p = @fromString(@x, prec)
      return p

    console.warn('NaN x') if isNaN @x
    console.warn('NaN y') if isNaN @y

    @_flags = []

    @makeAntlers()

    super @x, @y



  fromString: (point, prec) ->
    # Given a string like "M 10.2 502.19"
    # return the corresponding Point.
    # Returns one of:
    #   MoveTo
    #   CurveTo
    #   SmoothTo
    #   LineTo
    #   HorizTo
    #   VertiTo

    patterns =
      moveTo:   /M[^A-Za-z]+/gi
      lineTo:   /L[^A-Za-z]+/gi
      curveTo:  /C[^A-Za-z]+/gi
      smoothTo: /S[^A-Za-z]+/gi
      horizTo:  /H[^A-Za-z]+/gi
      vertiTo:  /V[^A-Za-z]+/gi

    classes =
      moveTo:   MoveTo
      lineTo:   LineTo
      curveTo:  CurveTo
      smoothTo: SmoothTo
      horizTo:  HorizTo
      vertiTo:  VertiTo

    lengths =
      moveTo:   2
      lineTo:   2
      curveTo:  6
      smoothTo: 4
      horizTo:  1
      vertiTo:  1

    pairs = /[-+]?\d*\.?\d*(e\-)?\d*/g

    # It's possible in SVG to list several sets of coords
    # for one character key. For example, "L 10 20 40 50"
    # is actually two seperate LineTos: a (10, 20) and a (40, 50)
    #
    # So we build the point(s) into an array, and return points[0]
    # if there's one, or the whole array if there's more.
    points = []

    for key, val of patterns
      # Find which pattern this string matches.
      # This check uses regex to also validate the point's syntax at the same time.

      matched = point.match val

      if matched isnt null

        # Matched will not be null when we find the correct point from the 'pattern' regex collection.
        # Match for the cooridinate pairs inside this point (1-3 should show up)
        # These then get mapped with parseFloat to get the true values, as coords

        coords = (point.match pairs).filter((p) -> p.length > 0).map parseFloat

        relative = point.substring(0,1).match(/[mlcshv]/) isnt null # Is it lower-case? So it's relative? Shit!

        clen = coords.length
        elen = lengths[key] # The expected amount of values for this kind of point

        # If the number of coordinates checks out, build the point(s)
        if clen % elen is 0

          sliceAt = 0

          for i in [0..(clen / elen) - 1]
            set = coords.slice(sliceAt, sliceAt + elen)

            if i > 0
              if key is "moveTo"
                key = "lineTo"

            values = [null].concat set

            values.push @owner # Point owner
            values.push prec
            values.push relative

            debugger if values.join(' ').mentions "NaN"

            # At this point, values should be an array that looks like this:
            #   [null, 100, 120, 300.5, 320.5, Path]
            # The amount of numbers depends on what kind of point we're making.

            # Build the point from the appropriate constructor

            constructed = new (Function.prototype.bind.apply(classes[key], values))

            points.push constructed

            sliceAt += elen

        else
          # We got a weird amount of points. Dunno what to do with that.
          # TODO maybe I should actually rethink this later to be more robust: like, parse what I can and
          # ignore the rest. Idk if that would be irresponsible.
          throw new Error("Wrong amount of coordinates: #{point}. Expected #{elen} and got #{clen}.")

        # Don't keep looking
        break

    if points.length is 0
      # We have no clue what this is, cuz
      throw new Error("Unreadable path value: #{point}")

    if points.length is 1
      return points[0]
    else
      return points

  select: ->
    @show()
    @showHandles()
    @antlers.refresh()
    @baseHandle.setAttribute 'selected', ''
    @

  deselect: ->
    @baseHandle.removeAttribute 'selected'
    @hideHandles?()
    @hide()
    @

  draw: ->
    # Draw the main handle DOM object.
    @$baseHandle = $('<div class="transform handle point"></div>')

    @baseHandle = @$baseHandle[0]
    # Set up the handle to have a connection to this elem

    if @at is undefined
      debugger if not (@ instanceof AntlerPoint)

    @baseHandle.setAttribute 'at', @at
    @baseHandle.setAttribute 'owner', @owner.metadata.uuid if @owner?

    @updateHandle @baseHandle, @x, @y
    dom.ui?.appendChild @baseHandle

    @


  makeAntlers: () ->
    if @succ?
      p2 = if @succ.p2? then @succ.p2()
    else
      p2 = null
    p3 = if @p3? then @p3() else null
    @antlers = new Antlers(@, p3, p2)
    @

  showHandles: ->
    @antlers.show()

  hideHandles: ->
    @antlers.hide()

  absoluteCached: undefined #

  prec: null
  succ: null

  actionHint: ->
    @baseHandle.setAttribute 'action', ''

  hideActionHint: ->
    @baseHandle.removeAttribute 'action'


  updateHandle: (handle = @baseHandle, x = @x, y = @y) ->
    return if handle is undefined

    # Since Point objects actually affect the data for Paths but they always
    # need to be the same size on the UI, their zoom behavior
    # falls in the annotation category. (#1)
    #
    # That means we need to scale its UI rep without actually affecting
    # the source of its coordinates. In this case, we simply scale the
    # left and top attributes of the DOM point handle.

    handle.style.left = x * ui.canvas.zoom
    handle.style.top = y * ui.canvas.zoom
    @


  inheritPosition: (from) ->
    # Maintain linked-list order in a PointsList
    @at         = from.at
    @prec       = from.prec
    @succ       = from.succ
    @prec.succ  = @
    @succ.prec  = @
    @owner      = from.owner
    @baseHandle = from.baseHandle if from.baseHandle?
    @



  nudge: (x, y, checkForFirstOrLast = true) ->
    old = @clone()
    super x, y
    @antlers?.nudge(x, y)
    @updateHandle()

    if @owner.type is 'path'
      if checkForFirstOrLast and @owner.points.closed
        # Check if this is the point overlapping the original MoveTo.
        if (@ is @owner.points.first) and @owner.points.last.equal old
          @owner.points.last.nudge(x, y, false)
        else if (@ is @owner.points.last) and @owner.points.first.equal old
          @owner.points.first.nudge(x, y, false)


  rotate: (a, origin) ->
    super a, origin
    @antlers?.rotate(a, origin)
    @updateHandle()


  scale: (x, y, origin, angle) ->
    super x, y, origin, angle
    @antlers?.scale(x, y, origin, angle)
    @updateHandle()
    @


  replaceWith: (point) ->
    @owner.points.replace(@, point)


  toPosn: ->
    new Posn(@x, @y)


  toLineSegment: ->
    new LineSegment @prec, @


  ###

    Linked list action

  ###

  setSucc: (succ) ->
    @succ = succ
    succ.prec = @

  setPrec: (prec) ->
    prec.setSucc @


  ###

   Visibility functions for the UI

  ###

  show: ->
    return if not @baseHandle?
    if not @baseHandle
      @draw()
    @baseHandle.style.display = 'block'
    @baseHandle.style.opacity = 1


  hide: (force = false) ->
    return if not @baseHandle?
    if not @baseHandle.hasAttribute('selected') or force
      @baseHandle.style.opacity = 0
      @baseHandle.removeAttribute 'action'
      @hideHandles()
      @unhover()


  hover: ->
    @baseHandle?.setAttribute 'hover', ''
    console.log "base handle missing" if not @baseHandle?

    if @at is 0
      @owner.points.last.baseHandle.setAttribute 'hover', ''
    else if @ is @owner.points.last
      @owner.points.first.baseHandle.setAttribute 'hover', ''


  unhover: ->
    @baseHandle?.removeAttribute 'hover'


  clear: ->
    @baseHandle.style.display = 'none'
    @


  unclear: ->
    @baseHandle.style.display = 'block'
    @


  remove: ->
    @antlers?.hide()
    @baseHandle?.remove()


  toStringWithZoom: ->
    @multiplyByMutable ui.canvas.zoom
    str = @toString()
    @multiplyByMutable (1 / ui.canvas.zoom)
    str

  flag: (flag) -> @_flags.ensure flag

  unflag: (flag) -> @_flags.remove flag

  flagged: (flag) -> @_flags.has flag

  annotate: (color, radius) ->
    ui.annotations.drawDot(@, color, radius)

###

  Polynomial

###

class Polynomial

  constructor: (@coefs) ->
    l = @coefs.length
    for own i, v of @coefs
      @["p#{l - i - 1}"] = v
    @coefs = @coefs.reverse()
    @


  tolerance: 1e-6


  accuracy: 6


  degrees: ->
    @coefs.length - 1


  interpolate: (xs, xy, n, offset, x) ->
    # I have no fucking idea what this does or how it does it.
    y = 0
    dy = 0
    ns = 0

    c = [n]
    d = [n]

    diff = Math.abs(x - xs[offset])
    for i in [0..n + 1]
      dift = Math.abs(x - xs[offset + i])

      if (dift < diff)
        ns = i
        diff = dift

      c[i] = d[i] = ys[offset + i]

    y = ys[offset + ns]
    ns -= 1

    for i in [1..m + 1]
      for i in [0.. n - m + 1]
        ho = xs[offset + i] - x
        hp = xs[offset + i + m] - x
        w = c[i + 1] - d[i]
        den = ho - hp

        if den is 0.0
          result =
            y: 0
            dy: 0
          break

        den = w / den
        d[i] = hp * den
        c[i] = ho * den

      dy = if (2 * (ns + 1) < (n - m)) then c[ns + 1] else d[ns -= 1]
      y += dy

    { y: y, dy: dy}


  eval: (x) ->
    result = 0
    for i in [@coefs.length - 1 .. 0]
      result = result * x + @coefs[i]

    result


  add: (that) ->
    newCoefs = []
    d1 = @degrees()
    d2 = that.degrees()
    dmax = Math.max(d1, d2)

    for i in [0..dmax]
      v1 = if (i <= d1) then @coefs[i] else 0
      v2 = if (i <= d2) then that.coefs[i] else 0

      newCoefs[i] = v1 + v2

    newCoefs = newCoefs.reverse()

    return new Polynomial(newCoefs)


  roots: ->
    switch (@coefs.length - 1)
      when 0
        return []
      when 1
        return @linearRoot()
      when 2
        return @quadraticRoots()
      when 3
        return @cubicRoots()
      when 4
        return @quarticRoots()
      else
        return []


  derivative: ->
    newCoefs = []

    for i in [1..@degrees()]
      newCoefs.push(i * @coefs[i])

    new Polynomial(newCoefs.reverse())


  bisection: (min, max) ->
    minValue = @eval(min)
    maxValue = @eval(max)

    if Math.abs(minValue) <= @tolerance
      return min
    else if Math.abs(maxValue) <= @tolerance
      return max
    else if (minValue * maxValue <= 0)
      tmp1 = Math.log(max - min)
      tmp2 = Math.LN10 * @accuracy
      iters = Math.ceil((tmp1 + tmp2) / Math.LN2)

      for i in [0..iters - 1]
        result = 0.5 * (min + max)
        value = @eval(result)

        if Math.abs(value) <= @tolerance
          break

        if (value * minValue < 0)
          max = result
          maxValue = value
        else
          min = result
          minValue = value

    result


  rootsInterval: (min, max) ->
    results = []

    if @degrees() is 1
      root = @bisection(min, max)
      if root?
        results.push root
    else
      deriv = @derivative()

      droots = deriv.rootsInterval(min, max)
      dlen = droots.length

      if dlen > 0
        root = @bisection(min, droots[0])
        results.push root if root?

        for i in [0..dlen - 2]
          r = droots[i]
          root = @bisection(r, droots[i + 1])
          results.push root if root?

        root = @bisection(droots[dlen - 1], max)
        results.push root if root?
      else
        root = @bisection(min, max)
        results.push root if root?

    results


  # Root functions
  # linear, quadratic, cubic

  linearRoot: ->
    result = []

    if @p1 isnt 0
      result.push -@p0 / @p1

    result


  quadraticRoots: ->
    results = []

    a = @p2
    b = @p1 / a
    c = @p0 / a
    d = b * b - 4 * c

    if d > 0
      e = Math.sqrt d
      results.push(0.5 * (-b + e))
      results.push(0.5 * (-b - e))
    else if d is 0
      results.push(0.5 * -b)

    results


  cubicRoots: ->
    results = []
    c3 = @p3
    c2 = @p2 / c3
    c1 = @p1 / c3
    c0 = @p0 / c3

    a = (3 * c1 - c2 * c2) / 3
    b = (2 * c2 * c2 * c2 - 9 * c1 * c2 + 27 * c0) / 27
    offset = c2 / 3
    discrim = b * b / 4 + a * a * a / 27
    halfB = b/2

    if (Math.abs(discrim)) <= 1e-6
      discrim = 0

    if discrim > 0
      e = Math.sqrt discrim

      tmp = -halfB + e

      root = if tmp >= 0 then Math.pow(tmp, 1/3) else -Math.pow(-tmp, 1/3)

      tmp = -halfB - e

      root += if tmp >= 0 then Math.pow(tmp, 1/3) else -Math.pow(-tmp, 1/3)

      results.push (root - offset)

    else if discrim < 0

      distance = Math.sqrt(-a/3)
      angle = Math.atan2(Math.sqrt(-discrim), -halfB) / 3
      cos = Math.cos angle
      sin = Math.sin angle
      sqrt3 = Math.sqrt(3)

      results.push(2*distance*cos - offset)
      results.push(-distance * (cos + sqrt3 * sin) - offset)
      results.push(-distance * (cos - sqrt3 * sin) - offset)
    else
      if halfB >= 0
        tmp = -Math.pow(halfB, 1/3)
      else
        tmp = Math.pow(-halfB, 1/3)

      results.push(2 * tmp - offset)

      results.push(-tmp - offset)

    return results

class Range
  constructor: (@min, @max) ->

  length: -> @max - @min

  contains: (n) ->
    n > @min and n < @max

  containsInclusive: (n, tolerance = 0) ->
    n >= @min - tolerance and n <= @max + tolerance

  intersects: (n) ->
    n == @min or n == @max

  fromList: (alon) ->
    @min = Math.min.apply(@, alon)
    @max = Math.max.apply(@, alon)
    @

  fromRangeList: (alor) ->
    mins = alor.map (r) -> r.min
    maxs = alor.map (r) -> r.max
    @min = Math.min.apply @, mins
    @max = Math.max.apply @, maxs
    @

  nudge: (amt) ->
    @min += amt
    @max += amt

  scale: (amt, origin) ->
    # Amt is an integer
    # Origin is also an integer
    @min += (@min - origin) * (amt - 1)
    @max += (@max - origin) * (amt - 1)

  toString: ->
    "[#{@min.places(4)},#{@max.places(4)}]"

  percentageOfValue: (v) ->
    (v - @min) / @length()


class Bounds

  constructor: (@x, @y, @width, @height) ->
    if @x instanceof Array
      # A list of bounds
      minX = Math.min.apply(@, @x.map (b) -> b.x)
      @y   = Math.min.apply(@, @x.map (b) -> b.y)
      @x2  = Math.max.apply(@, @x.map (b) -> b.x2)
      @y2  = Math.max.apply(@, @x.map (b) -> b.y2)
      @x   = minX
      @width  = @x2 - @x
      @height = @y2 - @y


    else if @x instanceof Posn and @y instanceof Posn
      # A pair of posns

      x = Math.min(@x.x, @y.x)
      y = Math.min(@x.y, @y.y)
      @x2 = Math.max(@x.x, @y.x)
      @y2 = Math.max(@x.y, @y.y)
      @x = x
      @y = y
      @width = @x2 - @x
      @height = @y2 - @y

    else
      @x2 = @x + @width
      @y2 = @y + @height

    @xr = new Range(@x, @x + @width)
    @yr = new Range(@y, @y + @height)

  tl: -> new Posn(@x, @y)
  tr: -> new Posn(@x2, @y)
  br: -> new Posn(@x2, @y2)
  bl: -> new Posn(@x, @y2)

  clone: -> new Bounds(@x, @y, @width, @height)

  toRect: ->
    new Rect(
      x: @x,
      y: @y,
      width: @width,
      height: @height
    )

  center: ->
    new Posn(@x + (@width / 2), @y + (@height / 2))

  points: -> [new Posn(@x, @y), new Posn(@x2, @y), new Posn(@x2, @y2), new Posn(@x, @y2)]

  contains: (posn, tolerance) ->
    @xr.containsInclusive(posn.x, tolerance) and @yr.containsInclusive(posn.y, tolerance)

  overlapsBounds: (other, recur = true) ->
    @toRect().overlaps(other.toRect())

  nudge: (x, y) ->
    @x += x
    @x2 += x
    @y += y
    @y2 += y
    @xr.nudge x
    @yr.nudge y

  scale: (x, y, origin) ->
    tl = new Posn(@x, @y)
    br = new Posn(@x2, @y2)
    tl.scale(x, y, origin)
    br.scale(x, y, origin)

    @x = tl.x
    @y = tl.y
    @x2 = br.x
    @y2 = br.y

    @width *= x
    @height *= y

    @xr.scale x, origin
    @yr.scale y, origin

    @

  squareSmaller: (anchor) ->
    if @width < @height
      @height = @width
    else
      @width = @height

  centerOn: (posn) ->
    offset = posn.subtract @center()
    @nudge(offset.x, offset.y)

  fitTo: (bounds) ->
    sw = @width / bounds.width
    sh = @height / bounds.height
    sm = Math.max(sw, sh)
    new Bounds(0, 0, @width / sm, @height / sm)


  adjustElemsTo: (bounds) ->
    # Returns a method that can run on Monsvg objects
    # that will nudge and scale them so they go from these bounds
    # to look proportionately the same in the given bounds.
    offset = @tl().subtract bounds.tl()
    sw = @width / bounds.width
    sh = @height / bounds.height
    # Return a function that will adjust a given element to the canvas
    return (elem) ->
      elem.scale(1/sw, 1/sh, bounds.tl())
      elem.nudge(-offset.x, offset.y)

  annotateCorners: ->
    ui.annotations.drawDot(@tl())
    ui.annotations.drawDot(@tr())
    ui.annotations.drawDot(@bl())
    ui.annotations.drawDot(@br())

###

  Antlers

     \
        \ O  -  (succx, succy)
          \\
            \
             \
              o
               \
                \
                \\
                \ O  -  (basex, basey)
                |
                |
               /
              /


  Control handles for any vector Point. Edits base's x3 and base's succ's p2
  Each CurvePoint gets one of these. It keeps track of coordinates locally so we can
  draw these pre-emptively. For example, if you take the Pen tool and just drag a curve point right away,
  those curves don't exist yet but they come into play as soon as you add another point
  (...which will have to be a CurvePoint even if it's a static click)

  This class handles the GUI and updating the base and its succ's x2 y2 x3 y3. :)

###




class Antlers

  constructor: (@base, @basep3, @succp2) ->
    # I/P: base, a CurvePoint
    #      basex3 - either a Posn or null
    #      succx2 - either a Posn or null

    # Decide whether or not to lock the angle
    # (ensure points are always on a straight line)

    if @basep3? and @succp2?
      diff = Math.abs(@basep3.angle360(@base) - @succp2.angle360(@base))
      @lockAngle = diff.within(@angleLockThreshold, 180)
    else
      @lockAngle = false

    @

  angleLockThreshold: 0.5

  commit: () ->
    # Export the data to the element
    if @basep3?
      @base.x3 = @basep3.x
      @base.y3 = @basep3.y
    if @succp2? and @succ()
      @succ().x2 = @succp2.x
      @succ().y2 = @succp2.y
    @

  importNewSuccp2: (@succp2) ->
    if @succp2?
      @basep3 = @succp2.reflect(@base)
    @commit().refresh()

  killSuccp2: ->
    @succp2 = new Posn(@base.x, @base.y)
    @commit().refresh()

  succ: ->
    @base.succ

  refresh: ->
    return if not @visible
    @hide().show()

  visible: false

  show: ->
    @hide()
    @visible = true
    # Actually draws it, instead of just revealing it.
    # We don't keep the elements for this unless they're actually being shown.
    # We refresh it whenever we want it.
    if @basep3?
      @basep = new AntlerPoint @basep3.x, @basep3.y, @base.owner, @, -1

    if @succp2?
      @succp = new AntlerPoint @succp2.x, @succp2.y, @base.owner, @, 1

    return (=> @hide())

  hide: ->
    @visible = false
    # Removes elements from DOM to avoid needlessly updating them.
    @basep?.remove()
    @succp?.remove()
    @base.owner.antlerPoints?.remove [@basep, @succp]
    @

  redraw: ->
    @hide()
    @show()
    @

  hideTemp: (p) ->
    (if p is 2 then @succp else @basep)?.hideTemp()

  nudge: (x, y) ->

    @basep3?.nudge x, y
    @succp2?.nudge x, y
    if @succ() instanceof CurvePoint
      @succ().x2 += x
      @succ().y2 -= y
    @commit()

  scale: (x, y, origin) ->
    # When the shape is closed, this gets handled by the last point's antlers.

    @basep3?.scale x, y, origin
    @succp2?.scale x, y, origin

  rotate: (a, origin) ->

    @basep3?.rotate a, origin
    @succp2?.rotate a, origin
    @

  other: (p) ->
    if p is @succp then @basep else @succp

  angleDiff: (a, b) ->
    x = a - b
    if x < 0
      x += 360
    x

  flatten: ->
    return if not @succp2? or not @basep3?

    # Whichever one's ahead keeps moving ahead


    angleSuccp2 = @succp2.angle360(@base)
    angleBasep3 = @basep3.angle360(@base)

    p2p3d = @angleDiff(angleSuccp2, angleBasep3)
    p3p2d = @angleDiff(angleBasep3, angleSuccp2)

    if p2p3d < p3p2d
      ahead = "p2"
    else
      ahead = "p3"

    if ahead == "p2"
      # Move p2 forward, p3 back
      if p2p3d < 180
       compensate = (180 - p2p3d) / 2
       @succp2 = @succp2.rotate(compensate, @base)
       @basep3 = @basep3.rotate(-compensate, @base)
    else
      # Move p2 forward, p3 back
      if p3p2d < 180
       compensate = (180 - p3p2d) / 2
       @succp2 = @succp2.rotate(-compensate, @base)
       @basep3 = @basep3.rotate(compensate, @base)


class AntlerPoint extends Point
  constructor: (@x, @y, @owner, @family, @role) ->
    # I/P: x: int
    #      y: int
    #      owner: Monsvg
    #      family: Antlers
    #      role: int, -1 or 1 (-1 = base p3, 1 = succ p2)
    super @x, @y, @owner
    @draw()
    @baseHandle.className += ' bz-ctrl'
    @line = ui.annotations.drawLine(@zoomedc(), @family.base.zoomedc())
    @owner.antlerPoints?.push @

  succ: -> @family.base.succ

  base: -> @family.base

  hideTemp: ->
    @line.rep.style.display = 'none'
    @baseHandle.style.display = 'none'
    return =>
      @line.rep.style.display = 'block'
      @baseHandle.style.display = 'block'

  remove: ->
    @line.remove()
    super


  nudge: (x, y) ->

    if not @family.lockAngle
      super x, y
      @persist()
    else
      oldangle = @angle360(@family.base)
      super x, y

      newangle = @angle360(@family.base)
      @family.other(@)?.rotate(newangle - oldangle, @family.base)
      @persist()

    if @role is -1 and @family.base.succ instanceof SmoothTo
      s = @family.base.succ
      s.replaceWith(s.toCurveTo())


  scale: (x, y, origin) ->
    super x, y, origin
    @persist()

  rotate: (a, origin) ->
    super a, origin
    @persist()

  persist: ->
    if @role is -1# or @family.lockedTogether
      @family.basep3.copy @

    if @role is 1# or @family.lockedTogether
      @family.succp2.copy @

    if @family.base is @owner.points.last
      # Special case for when they are moving the last point's
      # antlers. We need to make the same changes on the first point's
      # antlers IF THE SHAPE IS CLOSED.

      first = @owner.points.first

      if @family.base.equal first
        # Make sure the first point's antlers
        # have the same succp2 and basep3 as this does
        #
        # Copy this antler's succp2 and basep3 and give them to
        # the first point's antlers as well.
        first.antlers.succp2 = @family.succp2.clone()
        first.antlers.basep3 = @family.basep3.clone()
        first.antlers.commit()

    @line.absorbA @family.base.zoomedc()
    @line.absorbB @zoomedc()

    @line.commit()

    @family.commit()


###

  Path points

  MoveTo
    Mx,y
    Begin a path at x,y

  LineTo
    Lx,y
    Draw straight line from pvx,pvy to x,y

  CurveTo
    Cx1,y1 x2,y2 x,y
    Draw a line to x,y.
    x1,y1 is the control point put on the previous point
    x2,y2 is the control point put on this point (x,y)

  SmoothTo
    Sx2,y2 x,y
    Shorthand for curveto. x1,y1 becomes x2,y2 from previous CurveTo.

  HorizTo
    Hx
    Draw a horizontal line inheriting the y-value from precessor

  VertiTo
    Vy
    Draw a vertical line inheriting the x-value from precessor

###


class MoveTo extends Point
  constructor: (@x, @y, @owner, @prec, @rel) ->
    super @x, @y, @owner


  relative: ->
    if @at is 0
      @rel = false
      return @
    else
      return @ if @rel

      precAbs = @prec.absolute()
      x = precAbs.x
      y = precAbs.y

      m = new MoveTo(@x - x, @y - y, @owner)
      m.rel = true
      return m

  absolute: ->
    if @at is 0
      @rel = false
      return @
    else
      return @ if not @rel

      precAbs = @prec.absolute()
      x = precAbs.x
      y = precAbs.y

      m = new MoveTo(@x + x, @y + y, @owner)
      m.rel = false
      return m

    new Point(point, @owner) for point in points.match(/[MLCSHV][\-\de\.\,\-\s]+/gi)

  p2: ->
    if @antlers?.succp2?
      return new Posn(@antlers.succp2.x, @antlers.succp2.y)
    else
      return null

  toString: -> "#{if @rel then "m" else "M"}#{@x},#{@y}"

  toLineSegment: ->
    @prec.toLineSegment()

  # I know this can be abstracted somehow with bind and apply but I
  # don't have time to figure that out before launch - already wasted time trying
  clone: -> new MoveTo(@x, @y, @owner, @prec, @rel)


class LineTo extends Point
  constructor: (@x, @y, @owner, @prec, @rel) ->
    super @x, @y, @owner

  relative: ->
    return @ if @rel

    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    l = new LineTo(@x - x, @y - y, @owner)
    l.rel = true
    return l

  absolute: ->
    return @ if not @rel
    if @absoluteCached
      return @absoluteCached


    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    l = new LineTo(@x + x, @y + y, @owner)
    l.rel = false

    @absoluteCached = l

    return l

  toString: -> "#{if @rel then 'l' else 'L'}#{@x},#{@y}"

  clone: -> new LineTo(@x, @y, @owner, @prec, @rel)




class HorizTo extends Point
  constructor: (@x, @owner, @prec, @rel) ->
    @inheritFromPrec(@prec)
    super @x, @y, @owner

  inheritFromPrec: (@prec) ->
    @y = @prec.absolute().y

  toString: ->
    "#{if @rel then 'h' else 'H'}#{@x}"

  convertToLineTo: ->
    # Converts and replaces this with an equivalent LineTo
    # Returns the resulting LineTo so it can be operated on.
    lineTo = new LineTo(@x, @y)
    @replaceWith lineTo
    lineTo

  rotate: (a, origin) ->
    @convertToLineTo().rotate(a, origin)

  absolute: ->
    return @ if not @rel
    return @absoluteCached if @absoluteCached
    @absoluteCached = new HorizTo(@x + @prec.absolute().x, @owner, @prec, false)

  relative: ->
    return @ if @rel
    new HorizTo(@x - @prec.absolute().x, @owner, @prec, true)

  clone: -> new HorizTo(@x, @owner, @prec, @rel)



class VertiTo extends Point
  constructor: (@y, @owner, @prec, @rel) ->
    @inheritFromPrec(@prec)
    super @x, @y, @owner

  inheritFromPrec: (@prec) ->
    @x = @prec.absolute().x

  toString: -> "#{if @rel then 'v' else 'V'}#{@y}"

  convertToLineTo: ->
    # Converts and replaces this with an equivalent LineTo
    # Returns the resulting LineTo so it can be operated on.
    lineTo = new LineTo(@x, @y)
    @replaceWith lineTo
    lineTo

  rotate: (a, origin) ->
    @convertToLineTo().rotate(a, origin)

  absolute: ->
    return @ if not @rel
    return @absoluteCached if @absoluteCached
    @absoluteCached = new VertiTo(@y + @prec.absolute().y, @owner, @prec, false)

  relative: ->
    return @ if @rel
    new VertiTo(@y - @prec.absolute().y, @owner, @prec, true)

  clone: -> new VertiTo(@y, @owner, @prec, @rel)







###

  CurvePoint

  A Point that has handles. Builds the handles in its constructor.

###

class CurvePoint extends Point
  constructor: (@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel) ->
    ###

      This Class just extends into CurveTo and SmoothTo as a way of abstracting out the curve
      handling the control points. It has two control points in addition to the base point (handled by super)

      Each point has a predecessor and a successor (in terms of line segments).

      It has two control points:
        (@x2, @y2) is the first curve control point (p2), which becomes @p2h
        (@x3, @y3) is the second (p3), which becomes @p3h
      (Refer to ASCII art at top of cubic-bezier-line-segment.coffee for point name reference)

      Dragging these mofos will alter the correct control point(s), which will change the curve

      I/P:
        x2, y2: control point (p2)
        x3, y3: control point (p3)
        x, y:   next base point (like any other point)
        owner:  elem that owns this shape (supered into Point)
        prec:   point that comes before it
        rel:    bool - true if it's relative or false if it's absolute

    ###

    super @x, @y, @owner


  p2: ->
    new Posn(@x2, @y2)


  p3: ->
    new Posn(@x3, @y3)


  p: ->
    new Posn(@x, @y)


  absorb: (p, n) ->
    # I/P: p, Posn
    #      n, 2 or 3 (p2 or p3)
    # Given a Posn/Point and an int (2 or 3), sets @x2/@x3 and @y2/@y3 to p's coordinats.
    # Abstracted method for updating a specific bezier curve control point.

    @["x#{n}"] = p.x
    @["y#{n}"] = p.y


  show: ->
    return @ if not @owner # Orphan points should be ignored (usually used in testing)
    super


  cleanUp: ->
    return
    @x2 = cleanUpNumber @x2
    @y2 = cleanUpNumber @y2
    @x3 = cleanUpNumber @x3
    @y3 = cleanUpNumber @y3
    super


  scale: (x, y, origin) ->
    @absorb(@p2().scale(x, y, origin), 2)
    @absorb(@p3().scale(x, y, origin), 3)
    super x, y, origin


  rotate: (a, origin) ->
    @absorb(@p2().rotate(a, origin), 2)
    @absorb(@p3().rotate(a, origin), 3)
    super a, origin


  relative: ->
    return @ if @rel

    # Assuming it's absolute now we want to subtract the precessor...
    # The base case here is a MoveTo, which will always be absolute.
    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    # Now we make a new one of whatever this is.
    # @constructor will point to either CurveTo or SmoothTo, in this case.
    # Since those both take the same arguments, simply subtract the precessor's absolute coords
    # from this one's absolute coords and we're in business!
    args = [@x2 - x, @y2 - y, @x3 - x, @y3 - y, @x - x, @y - y, @owner, @prec]
    if @constructor is SmoothTo
      args = args.slice(2)
    args.unshift(null)

    c = new (Function.prototype.bind.apply(@constructor, args))
    c.rel = true
    return c

  absolute: ->
    # This works the same way as relative but opposite.
    return @ if not @rel

    precAbs = @prec.absolute()
    x = precAbs.x
    y = precAbs.y

    args = [@x2 + x, @y2 + y, @x3 + x, @y3 + y, @x + x, @y + y, @owner, @prec]
    if @constructor is SmoothTo
      args = args.slice(2)
    args.unshift(null)

    c = new (Function.prototype.bind.apply(@constructor, args))

    c.rel = false

    return c


class CurveTo extends CurvePoint
  constructor: (@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel) ->
    super @x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel

  toString: -> "#{if @rel then 'c' else 'C'}#{@x2},#{@y2} #{@x3},#{@y3} #{@x},#{@y}"

  reverse: ->
    new CurveTo(@x3, @y3, @x2, @y2, @x, @y, @owner, @prec, @rel).inheritPosition @

  clone: -> new CurveTo(@x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel)


class SmoothTo extends CurvePoint
  constructor: (@x3, @y3, @x, @y, @owner, @prec, @rel) ->

    @inheritFromPrec @prec

    super @x2, @y2, @x3, @y3, @x, @y, @owner, @prec, @rel

  inheritFromPrec: (@prec) ->
    # Since a SmoothTo's p2 is a reflection of its precessor's p3 over
    # its previous point, we need to query that info from its precessor.
    if @prec instanceof CurvePoint
      precAbs = @prec.absolute()
      p2 = new Posn(precAbs.x3, precAbs.y3).reflect precAbs
    else
      p2 = new Posn(@x, @y) # No p2 to inherit, so just nullify it

    @x2 = p2.x
    @y2 = p2.y


  toCurveTo: (p2 = null) ->
    if p2 is null
      if @prec instanceof CurvePoint
        p2 = @prec.p3().reflect(@prec.p())
      else
        p2 = new Posn(@x, @y)

    ct = new CurveTo(p2.x, p2.y, @x3, @y3, @x, @y, @owner, @prec, @rel)
    ct.at = @at
    ct

  replaceWithCurveTo: (p2 = null) ->
    @replaceWith(@toCurveTo(p2))

  toString: -> "#{if @rel then 's' else 'S'}#{@x3},#{@y3} #{@x},#{@y}"

  reverse: -> new CurveTo @x3, @y3, @x2, @y2, @x, @y, @owner, @prec, @rel

  clone: -> new SmoothTo(@x3, @y3, @x, @y, @owner, @prec, @rel)

###

  PointsList

  Stores points, keeps them in order, lets you do shit
  Basically a linked-list.

###


class PointsList
  constructor: (alop, @owner, @segments = []) ->
    # Build this thing out of PointsSegment objects.
    #
    # I/P:
    #   alop: a list of Points or a string
    #   @owner: Mongsvg element these points belong to

    # This is just one big for-loop with intermediate calls
    # to commitSegment every time we run into a MoveTo.
    #
    # Effectively we create many PointsSegments starting with MoveTos
    # and going until the next MoveTo (which is the start of the
    # next PointsSegment)

    # First, if we were given a string of SVG points let's
    # parse that into what we work with, an array of Points
    if typeof alop is "string"
      alop = lab.conversions.stringToAlop alop, @owner

    # Now set up some helper variables to keep track of things

    # The point segment we are working on right now
    # This gets shoved into @segments when commitSegment is called
    accumulatedSegment = []

    # The last point we made.
    # Used to keep track of prec and succ relationships.
    lastPoint = undefined

    commitSegment = =>
      # Helper method that gets called for every MoveTo we bump into.
      # Basically we stack points up starting with a MoveTo and
      # until the next MoveTo, then we call this and it takes
      # that stack and makes a PointsSegment with them.

      return if accumulatedSegment.length is 0

      # Make the PointsSegment
      sgmt = new PointsSegment accumulatedSegment, @

      # Keep track of which is our last segment
      @lastSegment = sgmt

      # Only set it as the first segment if that hasn't been set yet
      # (which would mean that it is indeed the first segment)
      if @firstSegment is null
        @firstSegment = sgmt

      # Commit the PointsSegment to this PointsList's @segments!
      @segments.push sgmt

      # Reset the accumulated points stack array
      accumulatedSegment = []

    # We can call PointsList with pre-constructed PointsSegments.
    # In this case, set up these two variables manually.
    if @segments.length isnt 0
      @firstSegment = @segments[0]
      @lastSegment = @segments[@segments.length - 1]

    return if alop.length is 0 # Initiate empty PointsList

    # Now we iterate thru the points and split them into PointsSegment objects
    for own ind, point of alop

      # Get integer of index number, save it as point.at attribute
      ind = parseInt ind, 10
      point.at = ind

      # Set the @first and @last aliases as we get to them
      @first = point if ind is 0
      @last = point if ind is alop.length - 1

      point.setPrec (if lastPoint? then lastPoint else alop[alop.length - 1])
      lastPoint?.setSucc point

      if point instanceof MoveTo
        # Close up the last segment, start a new one.
        commitSegment()

      accumulatedSegment.push point

      # Now we're done, so set this as the lastPoint for the next point ;^)
      lastPoint = point

    # Get the last one we never got to.
    commitSegment()
    lastPoint.setSucc @first

  first: null
  last: null

  firstSegment: null
  lastSegment: null

  closed: false

  moveSegmentToFront: (segment) ->
    return if not (@segments.has segment)
    @segments = @segments.cannibalizeUntil segment

  movePointToFront: (point) ->
    @moveSegmentToFront point.segment
    point.segment.movePointToFront point


  firstPointThatEquals: (point) ->
    @filter((p) -> p.equal(point))[0]


  closedOnSameSpot: ->
    @closed and (@last.equal @first)


  length: ->
    @segments.reduce (a, b) ->
      a + b.points.length
    , 0


  all: ->
    pts = []
    for s in @segments
      pts = pts.concat s.points
    pts


  renumber: ->
    @all().map (p, i) ->
      p.at = i
      p

  pushSegment: (sgmt) ->
    @lastSegment = sgmt
    @segments.push sgmt


  push: (point, after) ->
    # Add a new point!

    if @segments.length is 0
      @pushSegment new PointsSegment [], @

    point.owner = @owner

    if not after?
      point.at = @lastSegment.points.length
      @lastSegment.points.push point

      if @last?
        @last.setSucc point
        point.setPrec @last
      else
        point.setPrec point

      if @first?
        @first.setPrec point
        point.setSucc @first
      else
        point.setSucc point

      @last = point

      return @


  replace: (old, replacement) ->
    @segmentContaining(old).replace old, replacement


  reverse: ->
    # Reverse the order of the points, while maintaining the exact same shape.
    new PointsList([], @owner, @segments.map (s) -> s.reverse())


  at: (n) ->
    @segmentContaining(parseInt(n, 10)).at n

  close: ->
    @closed = true
    @

  relative: ->
    @segments = @segments.map (s) ->
      s.points = s.points.map (p) ->
        abs = p.relative()
        abs.inheritPosition p
        abs
      s
    @

  absolute: ->
    @segments = @segments.map (s) ->
      s.points = s.points.map (p) ->
        abs = p.absolute()
        abs.inheritPosition p
        abs
      s
    @

  drawBasePoints: ->
    @map (p) ->
      p.baseHandle?.remove()
      p.draw()
      p.makeAntlers()
    @

  removeBasePoints: ->
    @map (p) ->
      p.baseHandle?.remove()
    @


  hide: ->
    @map (p) -> p.hide()

  unhover: ->
    @map (p) -> p.unhover()

  join: (x) ->
    @all().join x

  segmentContaining: (a) ->
    if typeof a is "number"
      for s in @segments
        if s.startsAt <= a
          segm = s
        else break
      return segm
    else
      segments = @segments.filter (s) ->
        s.points.indexOf(a) > -1
      return segments[0] if segments.length is 1
    return []


  hasPointWithin: (tolerance, point) ->
    @filter((p) -> p.within(tolerance, point)).length > 0


  remove: (x) ->
    if typeof x is "number"
      x = @at x
    if x instanceof Array
      for p in x
        @remove p
    else if x instanceof Point
      @segmentContaining(x).remove x

  filter: (fun) ->
    @all().filter fun

  filterSegments: (fun) ->
    @segments.map (segment) ->
      new PointsSegment(segment.points.filter fun)

  fetch: (cl) ->
    # Given a class like MoveTo or CurveTo or Point or CurvePoint,
    # return all points of that class.
    @all().filter (p) -> p instanceof cl

  map: (fun) ->
    @segments.map (s) ->
      s.points.map fun

  forEach: (fun) ->
    @segments.forEach (s) ->
      s.points.forEach fun

  mapApply: (fun) ->
    @segments.map (s) ->
      s.points = s.points.map fun

  xRange: ->
    xs = @all().map (p) -> p.x
    new Range(Math.min.apply(@, xs), Math.max.apply(@, xs))

  yRange: ->
    ys = @all().map (p) -> p.y
    new Range(Math.min.apply(@, ys), Math.max.apply(@, ys))

  toString: ->
    @segments.join(' ') + (if @closed then "z" else "")

  insideOf: (other) ->
    @all().filter (p) ->
      p.insideOf other

  notInsideOf: (other) ->
    @all().filter (p) ->
      !p.insideOf other

  withoutMoveTos: ->
    new PointsList([], @owner, @filterSegments (p) ->
        not (p instanceof MoveTo)
    )

###

  PointsSegment

  A segment of points that starts with a MoveTo.
  A PointsList is composed of a list of these.

###


class PointsSegment
  constructor: (@points, @list) ->
    @startsAt = if @points.length isnt 0 then @points[0].at else 0

    if @list?
      @owner = @list.owner

    if @points[0] instanceof MoveTo
      @moveTo = @points[0]

    @points.forEach (p) =>
      p.segment = @

    @


  insert: (point, at) ->
    head = @points.slice 0, at
    tail = @points.slice at

    if point instanceof Array
      tail.forEach (p) ->
        p.at += point.length

      head = head.concat point

    else if point instanceof Point
      tail.forEach (p) ->
        p.at += 1

      head[head.length - 1].setSucc point
      tail[0].setPrec point

      head.push point



    else
      throw new Error "PointsList: don't know how to insert #{point}."



  toString: ->
    @points.join(' ')


  at: (n) ->
    @points[n - @startsAt]


  remove: (x) ->
    # Relink things
    x.prec.succ = x.succ
    x.succ.prec = x.prec
    if x is @list.last
      @list.last = x.prec
    if x is @list.first
      @list.first = x.succ
    @points = @points.remove x

    # Remove it from the canvas if it's there
    x.remove()


  movePointToFront: (point) ->
    return if not (@points.has point)

    @removeMoveTo()
    @points = @points.cannibalizeUntil(point)
    @


  moveMoveTo: (otherPoint) ->
    tail = @points.slice 1

    for i in [0 .. otherPoint.at - 1]
      segment = segment.cannibalize()

    @moveTo.copy otherPoint

    @points = [@moveTo].concat segment


  replace: (old, replacement) ->
    if replacement instanceof Point
      replacement.inheritPosition old
      @points = @points.replace old, replacement

    else if replacement instanceof Array
      replen = replacement.length
      at = old.at
      prec = old.prec
      succ = old.succ
      old.succ.prec = replacement[replen - 1]
      # Sus
      for np in replacement
        np.owner = @owner

        np.at = at
        np.prec = prec
        np.succ = succ
        prec.succ = np
        prec = np
        at += 1

      @points = @points.replace old, replacement

      for p in @points.slice at
        p.at += (replen - 1)

    replacement

  validateLinks: ->
    # Sortova debug tool <3
    console.log @points.map (p) -> "#{p.prec.at} #{p.at} #{p.succ.at}"
    prev = @points.length - 1
    for own i, p of @points
      i = parseInt i, 10
      if not (p.prec is @points[prev])
        console.log p, "prec wrong. Expecting", prev
        debugger
        return false
        break
      succ = if i is @points.length - 1 then 0 else i + 1
      if not (p.succ is @points[succ])
        console.log p, "succ wrong"
        return false
        break
      prev = i

    true


  # THIS IS FUCKED UP
  reverse: ->
    @removeMoveTo()

    positions = []
    stack = []

    for own index, point of @points
      stack.push point
      positions.push
        x: point.x
        y: point.y

    tailRev = stack.slice(1).reverse().map (p) ->
      return if p instanceof CurvePoint then p.reverse() else p

    positions = positions.reverse()

    stack = stack.slice(0, 1).concat tailRev

    stack = stack.map (p, i) ->
      c = positions[0]
      p.x = c.x
      p.y = c.y

      # Relink: swap succ and prec
      succ = p.succ
      p.succ = p.prec
      p.prec = succ

      p.at = i
      # Cut the head off as we go, this should be faster than just going positions[i] ^_^
      positions = positions.slice 1
      p
    new PointsSegment stack, @list


  removeMoveTo: ->
    @points = @points.filter (p) -> not (p instanceof MoveTo)


  ensureMoveTo: ->
    lastPoint = @points.last()
    firstPoint = @points.first()

    moveTo = new MoveTo(lastPoint.x, lastPoint.y, lastPoint.owner, lastPoint)
    moveTo.at = 0

    lastPoint.succ = firstPoint.prec = moveTo
    moveTo.succ = firstPoint
    @points.unshift(moveTo)

    @



###
  Internal representation of a straight line segment

  a
   \
    \
     \
      \
       \
        \
         \
          b

  I/P:
    a: First point
    b: Second point

###


class LineSegment

  # LineSegment
  #
  # Allows you to do calculations on simple straight line segments.
  #
  # I/P : a, b Posns

  constructor: (@a, @b, @source = @toLineTo()) ->
    @calculate()

  calculate: ->

    # Do some calculations at startup:
    #
    # Slope, number
    # Angle, number (degrees)
    # Length, number
    #
    # No I/P
    # O/P : self

    @slope = (@a.y - @b.y) / (@b.x - @a.x)
    @angle = Math.atan(@slope) / (Math.PI / 180)
    @length = Math.sqrt(Math.pow((@b.x - @a.x), 2) + Math.pow((@b.y - @a.y), 2))
    @

  beginning: -> @a

  end: -> @a

  toString: ->
    # Returns as string in "x y" format.
    "(Line segment: #{@a.toString()} #{@b.toString()})"

  constructorString: ->
    "new LineSegment(#{@a.constructorString()}, #{@b.constructorString()})"

  angle360: ->
    @b.angle360 @a

  toLineTo: ->
    new LineTo(@b.x, @b.y)

  toSVGPoint: -> @toLineTo()

  reverse: ->
    # Note: this makes it lose its source
    new LineSegment(@b, @a)

  bounds: (useCached = false) ->
    if @boundsCached? and useCached
      return @boundsCached

    minx = Math.min(@a.x, @b.x)
    maxx = Math.max(@a.x, @b.x)
    miny = Math.min(@a.y, @b.y)
    maxy = Math.max(@a.y, @b.y)

    width = @width()
    height = @height()

    # Cache the bounds and return them at the same time

    @boundsCached = new Bounds(minx, miny, width, height)

  boundsCached: undefined

  rotate: (angle, origin) -> new LineSegment(@a.rotate(angle, origin), @b.rotate(angle, origin))

  width: ->
    Math.abs(@a.x - @b.x)

  height: ->
    Math.abs(@a.y - @b.y)

  xRange: ->
    # Returns a Range of x values covered
    #
    # O/P : a Range
    new Range(Math.min(@a.x, @b.x), Math.max(@a.x, @b.x))


  yRange: ->
    # Returns a Range of y values covered
    #
    # O/P : a Range
    new Range(Math.min(@a.y, @b.y), Math.max(@a.y, @b.y))


  xDiff: ->
    # Difference between x values of a and b points
    #
    # O/P : number

    Math.max(@b.x, @a.x) - Math.min(@b.x, @a.x)


  xbaDiff: ->
    # Difference between second point x and first point x
    #
    # O/P: number

    @b.x - @a.x


  yDiff: ->
    # Difference between y values of a and b points
    #
    # O/P : number

    Math.max(@b.y, @a.y) - Math.min(@b.y, @a.y)


  ybaDiff: ->
    # Difference between secoind point y and first point y
    #
    # O/P: number

    @b.y - @a.y


  yAtX: (x, extrapolate = true) ->
    if not extrapolate and not @xRange().containsInclusive(x)
      return null
    @a.y + ((x - @a.x) * @slope)


  xAtY: (y, extrapolate = true) ->
    if not extrapolate and not @yRange().containsInclusive(y)
      return null
    @a.x + ((y - @a.y) / @slope)


  ends: ->
    [a, b]

  posnAtPercent: (p) ->
    # I/P: p, number between 0 and 1
    # O/P: Posn at that point on the LineSegment

    new Posn(@a.x + (@b.x - @a.x) * p, @a.y + (@b.y - @a.y) * p)


  findPercentageOfPoint: (p) ->
    # I/P: A single Posn
    # O/P: A floating point value

    distanceA = p.distanceFrom(@a)
    distanceA / (distanceA + p.distanceFrom(@b))


  splitAt: (p, forced = null) ->
    # I/P: p, a float between 0 and 1
    #
    # O/P: Array with two LineSegments

    # So we're allowed to pass either a floating point value
    # or a Posn. Or a list of Posns.
    #
    # If given Posns, we have to calculate the float for each and then recur.

    if typeof p is "number"
      split = if forced then forced else @posnAtPercent p
      return [new LineSegment(@a, split), new LineSegment(split, @b)]

    else if p instanceof Array
      segments = []
      distances = {}

      for posn in p
        distances[posn.distanceFrom(@a)] = posn

      distancesSorted = Object.keys(distances).map(parseFloat).sort(sortNumbers)
       # ARE YOU FUICKING SERIOUS JAVASCRIPT

      nextA = @a

      for key in distancesSorted
        posn = distances[key]
        segments.push new LineSegment(nextA, posn)
        nextA = posn

      segments.push new LineSegment(nextA, @b)

      return segments


    else if p instanceof Posn
      # Given a single Posn, find how far along it is on the line
      # and recur with that floating point value.
      return [new LineSegment(@a, p), new LineSegment(p, @b)]

  midPoint: ->
    @splitAt(0.5)[0].b

  nudge: (x, y) ->
    @a.nudge(x, y)
    @b.nudge(x, y)

  scale: (x, y, origin) ->
    @a.scale(x, y, origin)
    @b.scale(x, y, origin)

  equal: (ls) ->
    return false if ls instanceof CubicBezier
    ((@a.equal ls.a) && (@b.equal ls.b)) || ((@a.equal ls.b) && (@b.equal ls.a))

  intersects: (s) ->
    # Does it have an intersection with ...?
    inter = @intersection(s)
    inter instanceof Posn or inter instanceof Array

  intersection: (s) ->
    # What is its intersection with ...?
    if s instanceof LineSegment
      return @intersectionWithLineSegment(s)
    else if s instanceof Circle
      return @intersectionWithCircle(s)
    else if s instanceof CubicBezier
      return s.intersectionWithLineSegment @


  intersectionWithLineSegment: (s) ->
    ###
      Get intersection with another LineSegment

      I/P : LineSegment

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###

    ana_s = s.xbaDiff() * (@a.y - s.a.y) - s.ybaDiff() * (@a.x - s.a.x)
    ana_m = @xbaDiff() * (@a.y - s.a.y) - @ybaDiff() * (@a.x - s.a.x)
    crossDiff  = s.ybaDiff() * @xbaDiff() - s.xbaDiff() * @ybaDiff()

    if crossDiff isnt 0
      anas = ana_s / crossDiff
      anam = ana_m / crossDiff

      if 0 <= anas and anas <= 1 and 0 <= anam and anam <= 1
        return new Posn(@a.x + anas * (@b.x - @a.x), @a.y + anas * (@b.y - @a.y))
      else
        return null
    else
      if ana_s is 0 or ana_m is 0
        # Coinicident (identical)
        return Infinity
      else
        # Parallel
        return 0


  intersectionWithEllipse: (s) ->
    ###
     Get intersection with an ellipse

     I/P: Ellipse

     O/P: null if no intersections, or Array of Posn(s) if there are

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###


    rx = s.data.rx
    ry = s.data.ry
    cx = s.data.cx
    cy = s.data.cy

    origin = new Posn(@a.x, @a.y)
    dir    = new Posn(@b.x - @a.x, @b.y - @a.y)
    center = new Posn(cx, cy)
    diff   = origin.subtract center
    mDir   = new Posn(dir.x / (rx * rx), dir.y / (ry * ry))
    mDiff  = new Posn(diff.x / (rx * rx), diff.y / (ry * ry))

    results = []

    a = dir.dot mDir
    b = dir.dot mDiff
    c = diff.dot(mDiff) - 1.0
    d = b * b - a * c

    if d < 0
      # Line is outside ellipse
      return null
    else if d > 0
      root = Math.sqrt d
      t_a = (-b - root) / a
      t_b = (-b + root) / a

      if (t_a < 0 or 1 < t_a) and (t_b < 0 or 1 < t_b)
        if (t_a < 0 and t_b < 0) and (t_a > 1 and t_b > 1)
          # Line is outside ellipse
          return null
        else
          # Line is inside ellipse
          return null
      else
        if 0 <= t_a and t_a <= 1
          results.push @a.lerp @b, t_a
        if 0 <= t_b and t_b <= 1
          results.push @a.lerp @b, t_b
    else
        t = -b / a
        if 0 <= t and t <= 1
          results.push @a.lerp @b, t
        else
          return null

    results


  intersectionWithCircle: (s) ->
    ###
      Get intersection with a circle

      I/P : Circle

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    ###

    a = Math.pow(@xDiff(), 2) + Math.pow(@yDiff(), 2)
    b = 2 * ((@b.x - @a.x) * (@a.x - s.data.cx) + (@b.y - @a.y) * (@a.y - s.data.cy))
    cc = Math.pow(s.data.cx, 2) + Math.pow(s.data.cy, 2) + Math.pow(@a.x, 2) + Math.pow(@a.y, 2) -
         2 * (s.data.cx * @a.x + s.data.cy * @a.y) - Math.pow(s.data.r, 2)
    deter = b * b - 4 * a * cc

    if deter < 0
      return null # No intersection
    else if deter is 0
      return 0 # Tangent
    else
      e = Math.sqrt(deter)
      u1 = (-b + e) / (2 * a)
      u2 = (-b - e) / (2 * a)

      if (u1 < 0 or u1 > 1) and (u2 < 0 or u2 > 1)
        if (u1 < 0 and u2 < 0) or (u1 > 1 and u2 > 1)
          return null # No intersection
        else
          return true # It's inside
      else
        ints = []

        if 0 <= u1 and u1 <= 1
          ints.push @a.lerp(@b, u1)

        if 0 <= u2 and u2 <= 1
          ints.push @a.lerp(@b, u2)

        return ints


class Ray extends LineSegment

  constructor: (@a, @angle) ->
    # subclass of LineSegment
    # Just makes a LineSegment that's insanely long lol
    #
    # I/P:
    #   a: Posn
    #   angle: number from 0 to 360
    super @a, @a.clone().nudge(0, -1e5).rotate(@angle, @a)


###
  Internal representation of a cubic bezier line segment

  p1                                     p4
   o                                     o
    \\                                 //
     \\                               //
      \ \                           / /
       \   \                     /   /
        \     _               _     /
         \      __         __      /
          °       --_____--       °
           p2                    p3

  I/P:
    p1: First absolute point, the moveto
    p2: The first point's curve handle
    p3: The second point's curve handle
    p4: The second absolute point

    In context with syntax: M[p1]C[p2] [p3] [p4]

###

class CubicBezier
  constructor: (@p1, @p2, @p3, @p4, @source = @toCurveTo()) ->

  ###
  toString: ->
    "(Cubic bezier: #{@p1},#{@p2},#{@p3},#{@p4})"
  ###

  toString: ->
    "new CubicBezier(#{@p1}, #{@p2}, #{@p3}, #{@p4})"

  toCurveTo: ->
    new CurveTo(@p2.x, @p2.y, @p3.x, @p3.y, @p4.x, @p4.y)

  toSVGPoint: -> @toCurveTo()

  length: ->
    # Not that accurate lol
    @intoLineSegments(4).reduce((a, b) -> a + b.length)

  beginning: -> @p1

  end: -> @p4

  nudge: (x, y) ->
    @p1.nudge(x, y)
    @p2.nudge(x, y)
    @p3.nudge(x, y)
    @p4.nudge(x, y)
    @

  scale: (x, y, origin) ->
    @p1.scale(x, y, origin)
    @p2.scale(x, y, origin)
    @p3.scale(x, y, origin)
    @p4.scale(x, y, origin)
    @

  rotate: (angle, origin) ->
    @p1.rotate(angle, origin)
    @p2.rotate(angle, origin)
    @p3.rotate(angle, origin)
    @p4.rotate(angle, origin)
    @

  reverse: ->
    # Note: this makes it lose its source
    new CubicBezier @p4, @p3, @p2, @p1

  equal: (cbls) ->
    return false if cbls instanceof LineSegment
    (((@p1.equal cbls.p1) && (@p2.equal cbls.p2) &&
      (@p3.equal cbls.p3) && (@p4.equal cbls.p4)) ||
     ((@p1.equal cbls.p4) && (@p2.equal cbls.p3) &&
      (@p3.equal cbls.p2) && (@p4.equal cbls.p1)))

  intersects: (other) ->
    inter = @intersection(other)
    inter instanceof Posn or (inter instanceof Array and inter.length > 0)

  intersection: (other) ->
    switch other.constructor
      when LineSegment
        return @intersectionWithLineSegment(other)
      when CubicBezier
        return @intersectionWithCubicBezier(other)

  xRange: ->
    @bounds().xr

  yRange: ->
    @bounds().yr

  ends: ->
    [@p1, @p4]

  midPoint: ->
    @splitAt(0.5)[0].p4

  bounds: (useCached = false) ->
    if @boundsCached? and useCached
      return @boundsCached

    minx = miny = Infinity
    maxx = maxy = -Infinity

    top2x = @p2.x - @p1.x
    top2y = @p2.y - @p1.y
    top3x = @p3.x - @p2.x
    top3y = @p3.y - @p2.y
    top4x = @p4.x - @p3.x
    top4y = @p4.y - @p3.y

    for i in [0..40]
      d = i / 40
      px = @p1.x + d * top2x
      py = @p1.y + d * top2y
      qx = @p2.x + d * top3x
      qy = @p2.y + d * top3y
      rx = @p3.x + d * top4x
      ry = @p3.y + d * top4y

      toqx = qx - px
      toqy = qy - py
      torx = rx - qx
      tory = ry - qy

      sx = px + d * toqx
      sy = py + d * toqy
      tx = qx + d * torx
      ty = qy + d * tory

      totx = tx - sx
      toty = ty - sy

      x = sx + d * totx
      y = sy + d * toty

      minx = Math.min(minx, x)
      miny = Math.min(miny, y)
      maxx = Math.max(maxx, x)
      maxy = Math.max(maxy, y)

      width = maxx - minx
      height = maxy - miny

    # Cache the bounds and return them at the same time

    @boundsCached = new Bounds(minx, miny, width, height)


  boundsCached: undefined


  intoLineSegments: (n) ->
    # Given n, split the bezier into n consecutive LineSegments, returned in an Array
    #
    # I/P: n, number
    # O/P: [LineSegment, LineSegment, LineSegment...] array

    segments = []
    for m in [0..n]
      i = 1 / m
      x = Math.pow((1-i), 3) * @p1.x + 3 * Math.pow((1-i), 2) * i * @p2.x +
          3 * (1 - i) * Math.pow(i, 2) * @p3.x + Math.pow(i, 3) * @p4.x
      y = Math.pow((1-i), 3) * @p1.y + 3 * Math.pow((1-i), 2) * i * @p2.y +
          3 * (1 - i) * Math.pow(i, 2) * @p3.y + Math.pow(i, 3) * @p4.y
      if m % 2 == 0
        last = new Posn(x, y)
      else
        segments.push new LineSegment(last, new Posn(x, y))
    segments.splice 1


  splitAt: (t, force = null) ->
    # Given a float t between 0 and 1, return two CubicBeziers that result from splitting this one at that percentage in.
    #
    # I/P: t, number between 0 and 1
    # O/P: [CubicBezier, CubicBezier] array
    #
    # Uses de Casteljau's algorithm. Really damn good resources:
    #   http://processingjs.nihongoresources.com/bezierinfo/
    #   http://en.wikipedia.org/wiki/De_Casteljau's_algorithm
    #
    # Example, splitting in half:
    # t = 0.5
    # p1: (10,10),    p2: (20, 5),    p3: (40, 20), p4: (50, 10)
    # p5: (15, 7.5),  p6: (30, 12.5), p7: (45, 15)
    # p8: (22.5, 10), p9: (37.5, 13.75)
    # p10: (30, 11.875)
    #
    # The split will happen at exactly p10, so the resulting curves will end and start there, respectively.
    # The resulting curves will be
    # [new CubicBezier(p1, p5, p8, p10), new CubicBezier(p10, p9, p7, p4)]

    if typeof t is "number"

      p5 = new LineSegment(@p1, @p2).posnAtPercent t
      p6 = new LineSegment(@p2, @p3).posnAtPercent t
      p7 = new LineSegment(@p3, @p4).posnAtPercent t
      p8 = new LineSegment(p5, p6).posnAtPercent t
      p9 = new LineSegment(p6, p7).posnAtPercent t
      p10 = if force then force else new LineSegment(p8, p9).posnAtPercent t

      return [new CubicBezier(@p1, p5, p8, p10), new CubicBezier(p10, p9, p7, @p4)]

    else if t instanceof Posn
      # Given a single Posn, find its percentage and then split the line on it.
      return @splitAt(@findPercentageOfPoint(t), t)


    else if t instanceof Array
      # Given a list of Posns, we have a bit more work to do.
      # We need to sort the Posns by their percentage along on the original line.
      # Then we recur on the line, splitting it on each posn that occurs from 0.0 to 1.0.

      # We always recur on the second half of the resulting split with
      # the next Posn in line.

      # We're going to use the Posns' percentages as keys
      # with which we'll sort them and split the line on them
      # one after the other.
      sortedPosns = {}

      # This will be the final array of split segments.
      segments = []

      # Find percentage for each posn, save the posn under that percentage.
      for posn in t
        percent = @findPercentageOfPoint posn
        sortedPosns[percent] = posn

      # Sort the keys - the list of percentages at which posns are available.
      percentages = Object.keys(sortedPosns).map(parseFloat).sort(sortNumbers)



      # Start by splitting the entire bezier.
      tail = @

      # For each posn, going in order of percentages...
      for perc in percentages
        # Split the tail on that single posn
        pair = tail.splitAt sortedPosns[perc]

        # Keep the first half
        segments.push pair[0]
        # And "recur" on the second half by redefining tail to be it
        tail = pair[1]

      # Don't abandon that last tail! ;)
      segments.push tail

      # Shazam

      return segments


  findPercentageOfPoint: (posn, tolerance = 1e-3, accumulated = 0.0, nextstep = 0.5) ->
    # Recursively find the percentage (float from 0 - 1) of given posn on this bezier, within tolerance given.
    # This works so well. I am so stoked about it.
    # Basically, this splits the given bezier in half. If the midpoint is within the tolerance of the posn we're looking for,
    # return the accumulated float. If not, it will recur on either or both of its halves,
    # adding (0.5 * n / 2) to the accumulator for the one on the right and keeping it the same for the one on the left
    # where n is the depth of recursion.
    #
    # I/P: posn: the Posn we're looking for
    #      [tolerance]: find the value for within this much of the x and y of the given posn.
    #
    #      Ignore the accumulated and nextstep values, those should start as they're precoded.
    #
    # O/P: A float between 0 and 1.

    split = @splitAt(0.5)
    a = split[0]
    b = split[1]


    # Base case - we've found it! Return the amt accumulated.
    if a.p4.within(tolerance, posn) or nextstep < 1e-4
      return accumulated

    # Recursion
    ab = a.bounds()
    bb = b.bounds()

    # Both halves might contain the point, if we have a shape that overlaps itself for example.
    # For this reason we have to actually recur on both the left and right.
    # When staying with a, however, we don't add to the accumulator because we're not advancing to the second half of the line.
    # We're simply not making the jump, so we don't count it. But we might make the next smallest jump when we recur on a.

    if ab.xr.containsInclusive(posn.x, 0.2) and ab.yr.containsInclusive(posn.y, 0.2)
      ac = a.findPercentageOfPoint(posn, tolerance, accumulated, nextstep / 2)
    if bb.xr.containsInclusive(posn.x, 0.2) and bb.yr.containsInclusive(posn.y, 0.2)
      bc = b.findPercentageOfPoint(posn, tolerance, accumulated + nextstep, nextstep / 2)

    # This is where the recursion bottoms out. Null means it's not on the bezier line within the tolerance.
    #
    #############
    # IMPORTANT #
    #############
    # This is a compromise right now. Since the intersection algorithm is imperfect, we get as close as we can and
    # return accumulated if there are no options. NOT null, which it used to be.
    # All this means is that if a point is given that's a bit off the line the recursion will stop when it can't
    # get any closer to it. So it does what it can, basically.
    #
    # This means you can't just feed any point into this and expect it to ignore you given a bad point.
    # This also means there is some tolerance to a point being a little bit off, which can happen when calculating
    # several intersections on one curve.
    #
    # It's very accurate this way. Nothing to worry about. Just a note so I don't forget. <3

    if ac? then ac else if bc? then bc else accumulated




  ###

    Intersection methods

  ###


  intersectionWithLineSegment: (l) ->
    ###

      Given a LineSegment, lists intersection point(s).

      I/P: LineSegment
      O/P: Array of Posns

      I am a cute sick Kate Whiper Snapper
      i love monodebe and I learn all about the flexible scemless data base

      Disclaimer: I don't really understand this but it passes my tests.

    ###

    min = l.a.min(l.b)
    max = l.a.max(l.b)

    results = []

    a = @p1.multiplyBy -1
    b = @p2.multiplyBy 3
    c = @p3.multiplyBy -3
    d = a.add(b.add(c.add(@p4)))
    c3 = new Posn(d.x, d.y)

    a = @p1.multiplyBy 3
    b = @p2.multiplyBy -6
    c = @p3.multiplyBy 3
    d = a.add(b.add(c))
    c2 = new Posn(d.x, d.y)

    a = @p1.multiplyBy -3
    b = @p2.multiplyBy 3
    c = a.add b
    c1 = new Posn(c.x, c.y)

    c0 = new Posn(@p1.x, @p1.y)

    n = new Posn(l.a.y - l.b.y, l.b.x - l.a.x)

    cl = l.a.x * l.b.y - l.b.x * l.a.y

    roots = new Polynomial([n.dot(c3), n.dot(c2), n.dot(c1), n.dot(c0) + cl]).roots()

    for i,t of roots

      if 0 <= t and t <= 1

        p5 = @p1.lerp(@p2, t)
        p6 = @p2.lerp(@p3, t)
        p7 = @p3.lerp(@p4, t)
        p8 = p5.lerp(p6, t)
        p9 = p6.lerp(p7, t)
        p10 = p8.lerp(p9, t)

        if l.a.x is l.b.x
          if (min.y <= p10.y) and (p10.y <= max.y)
            results.push p10
        else if l.a.y is l.b.y
          if min.x <= p10.x and p10.x <= max.x
            results.push p10
        else if p10.gte(min) and p10.lte(max)
          results.push p10

    results


  intersectionWithCubicBezier: (other) ->
    # I don't know.
    #
    # I/P: Another CubicBezier
    # O/P: Array of Posns.
    #
    # Source: http://www.kevlindev.com/gui/math/intersection/index.htm#Anchor-intersectBezie-45477

    results = []

    a = @p1.multiplyBy(-1)
    b = @p2.multiplyBy(3)
    c = @p3.multiplyBy(-3)
    d = a.add(b.add(c.add(@p4)))
    c13 = new Posn(d.x, d.y)

    a = @p1.multiplyBy(3)
    b = @p2.multiplyBy(-6)
    c = @p3.multiplyBy(3)
    d = a.add(b.add(c))
    c12 = new Posn(d.x, d.y)

    a = @p1.multiplyBy(-3)
    b = @p2.multiplyBy(3)
    c = a.add(b)
    c11 = new Posn(c.x, c.y)

    c10 = new Posn(@p1.x, @p1.y)

    a = other.p1.multiplyBy(-1)
    b = other.p2.multiplyBy(3)
    c = other.p3.multiplyBy(-3)
    d = a.add(b.add(c.add(other.p4)))
    c23 = new Posn(d.x, d.y)

    a = other.p1.multiplyBy(3)
    b = other.p2.multiplyBy(-6)
    c = other.p3.multiplyBy(3)
    d = a.add(b.add(c))
    c22 = new Posn(d.x, d.y)

    a = other.p1.multiplyBy(-3)
    b = other.p2.multiplyBy(3)
    c = a.add(b)
    c21 = new Posn(c.x, c.y)

    c20 = new Posn(other.p1.x, other.p1.y)

    c10x2 = c10.x * c10.x
    c10x3 = c10.x * c10.x * c10.x
    c10y2 = c10.y * c10.y
    c10y3 = c10.y * c10.y * c10.y
    c11x2 = c11.x * c11.x
    c11x3 = c11.x * c11.x * c11.x
    c11y2 = c11.y * c11.y
    c11y3 = c11.y * c11.y * c11.y
    c12x2 = c12.x * c12.x
    c12x3 = c12.x * c12.x * c12.x
    c12y2 = c12.y * c12.y
    c12y3 = c12.y * c12.y * c12.y
    c13x2 = c13.x * c13.x
    c13x3 = c13.x * c13.x * c13.x
    c13y2 = c13.y * c13.y
    c13y3 = c13.y * c13.y * c13.y
    c20x2 = c20.x * c20.x
    c20x3 = c20.x * c20.x * c20.x
    c20y2 = c20.y * c20.y
    c20y3 = c20.y * c20.y * c20.y
    c21x2 = c21.x * c21.x
    c21x3 = c21.x * c21.x * c21.x
    c21y2 = c21.y * c21.y
    c22x2 = c22.x * c22.x
    c22x3 = c22.x * c22.x * c22.x
    c22y2 = c22.y * c22.y
    c23x2 = c23.x * c23.x
    c23x3 = c23.x * c23.x * c23.x
    c23y2 = c23.y * c23.y
    c23y3 = c23.y * c23.y * c23.y


    poly = new Polynomial([
      -c13x3*c23y3 + c13y3*c23x3 - 3*c13.x*c13y2*c23x2*c23.y +
      3*c13x2*c13.y*c23.x*c23y2,

      -6*c13.x*c22.x*c13y2*c23.x*c23.y + 6*c13x2*c13.y*c22.y*c23.x*c23.y + 3*c22.x*c13y3*c23x2 -
      3*c13x3*c22.y*c23y2 - 3*c13.x*c13y2*c22.y*c23x2 + 3*c13x2*c22.x*c13.y*c23y2,
      -6*c21.x*c13.x*c13y2*c23.x*c23.y - 6*c13.x*c22.x*c13y2*c22.y*c23.x + 6*c13x2*c22.x*c13.y*c22.y*c23.y +
      3*c21.x*c13y3*c23x2 + 3*c22x2*c13y3*c23.x + 3*c21.x*c13x2*c13.y*c23y2 - 3*c13.x*c21.y*c13y2*c23x2 -
      3*c13.x*c22x2*c13y2*c23.y + c13x2*c13.y*c23.x*(6*c21.y*c23.y + 3*c22y2) + c13x3*(-c21.y*c23y2 -
      2*c22y2*c23.y - c23.y*(2*c21.y*c23.y + c22y2)),

      c11.x*c12.y*c13.x*c13.y*c23.x*c23.y - c11.y*c12.x*c13.x*c13.y*c23.x*c23.y + 6*c21.x*c22.x*c13y3*c23.x +
      3*c11.x*c12.x*c13.x*c13.y*c23y2 + 6*c10.x*c13.x*c13y2*c23.x*c23.y - 3*c11.x*c12.x*c13y2*c23.x*c23.y -
      3*c11.y*c12.y*c13.x*c13.y*c23x2 - 6*c10.y*c13x2*c13.y*c23.x*c23.y - 6*c20.x*c13.x*c13y2*c23.x*c23.y +
      3*c11.y*c12.y*c13x2*c23.x*c23.y - 2*c12.x*c12y2*c13.x*c23.x*c23.y - 6*c21.x*c13.x*c22.x*c13y2*c23.y -
      6*c21.x*c13.x*c13y2*c22.y*c23.x - 6*c13.x*c21.y*c22.x*c13y2*c23.x + 6*c21.x*c13x2*c13.y*c22.y*c23.y +
      2*c12x2*c12.y*c13.y*c23.x*c23.y + c22x3*c13y3 - 3*c10.x*c13y3*c23x2 + 3*c10.y*c13x3*c23y2 +
      3*c20.x*c13y3*c23x2 + c12y3*c13.x*c23x2 - c12x3*c13.y*c23y2 - 3*c10.x*c13x2*c13.y*c23y2 +
      3*c10.y*c13.x*c13y2*c23x2 - 2*c11.x*c12.y*c13x2*c23y2 + c11.x*c12.y*c13y2*c23x2 - c11.y*c12.x*c13x2*c23y2 +
      2*c11.y*c12.x*c13y2*c23x2 + 3*c20.x*c13x2*c13.y*c23y2 - c12.x*c12y2*c13.y*c23x2 -
      3*c20.y*c13.x*c13y2*c23x2 + c12x2*c12.y*c13.x*c23y2 - 3*c13.x*c22x2*c13y2*c22.y +
      c13x2*c13.y*c23.x*(6*c20.y*c23.y + 6*c21.y*c22.y) + c13x2*c22.x*c13.y*(6*c21.y*c23.y + 3*c22y2) +
      c13x3*(-2*c21.y*c22.y*c23.y - c20.y*c23y2 - c22.y*(2*c21.y*c23.y + c22y2) - c23.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),

      6*c11.x*c12.x*c13.x*c13.y*c22.y*c23.y + c11.x*c12.y*c13.x*c22.x*c13.y*c23.y + c11.x*c12.y*c13.x*c13.y*c22.y*c23.x -
      c11.y*c12.x*c13.x*c22.x*c13.y*c23.y - c11.y*c12.x*c13.x*c13.y*c22.y*c23.x - 6*c11.y*c12.y*c13.x*c22.x*c13.y*c23.x -
      6*c10.x*c22.x*c13y3*c23.x + 6*c20.x*c22.x*c13y3*c23.x + 6*c10.y*c13x3*c22.y*c23.y + 2*c12y3*c13.x*c22.x*c23.x -
      2*c12x3*c13.y*c22.y*c23.y + 6*c10.x*c13.x*c22.x*c13y2*c23.y + 6*c10.x*c13.x*c13y2*c22.y*c23.x +
      6*c10.y*c13.x*c22.x*c13y2*c23.x - 3*c11.x*c12.x*c22.x*c13y2*c23.y - 3*c11.x*c12.x*c13y2*c22.y*c23.x +
      2*c11.x*c12.y*c22.x*c13y2*c23.x + 4*c11.y*c12.x*c22.x*c13y2*c23.x - 6*c10.x*c13x2*c13.y*c22.y*c23.y -
      6*c10.y*c13x2*c22.x*c13.y*c23.y - 6*c10.y*c13x2*c13.y*c22.y*c23.x - 4*c11.x*c12.y*c13x2*c22.y*c23.y -
      6*c20.x*c13.x*c22.x*c13y2*c23.y - 6*c20.x*c13.x*c13y2*c22.y*c23.x - 2*c11.y*c12.x*c13x2*c22.y*c23.y +
      3*c11.y*c12.y*c13x2*c22.x*c23.y + 3*c11.y*c12.y*c13x2*c22.y*c23.x - 2*c12.x*c12y2*c13.x*c22.x*c23.y -
      2*c12.x*c12y2*c13.x*c22.y*c23.x - 2*c12.x*c12y2*c22.x*c13.y*c23.x - 6*c20.y*c13.x*c22.x*c13y2*c23.x -
      6*c21.x*c13.x*c21.y*c13y2*c23.x - 6*c21.x*c13.x*c22.x*c13y2*c22.y + 6*c20.x*c13x2*c13.y*c22.y*c23.y +
      2*c12x2*c12.y*c13.x*c22.y*c23.y + 2*c12x2*c12.y*c22.x*c13.y*c23.y + 2*c12x2*c12.y*c13.y*c22.y*c23.x +
      3*c21.x*c22x2*c13y3 + 3*c21x2*c13y3*c23.x - 3*c13.x*c21.y*c22x2*c13y2 - 3*c21x2*c13.x*c13y2*c23.y +
      c13x2*c22.x*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c13x2*c13.y*c23.x*(6*c20.y*c22.y + 3*c21y2) +
      c21.x*c13x2*c13.y*(6*c21.y*c23.y + 3*c22y2) + c13x3*(-2*c20.y*c22.y*c23.y - c23.y*(2*c20.y*c22.y + c21y2) -
      c21.y*(2*c21.y*c23.y + c22y2) - c22.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),

      c11.x*c21.x*c12.y*c13.x*c13.y*c23.y + c11.x*c12.y*c13.x*c21.y*c13.y*c23.x + c11.x*c12.y*c13.x*c22.x*c13.y*c22.y -
      c11.y*c12.x*c21.x*c13.x*c13.y*c23.y - c11.y*c12.x*c13.x*c21.y*c13.y*c23.x - c11.y*c12.x*c13.x*c22.x*c13.y*c22.y -
      6*c11.y*c21.x*c12.y*c13.x*c13.y*c23.x - 6*c10.x*c21.x*c13y3*c23.x + 6*c20.x*c21.x*c13y3*c23.x +
      2*c21.x*c12y3*c13.x*c23.x + 6*c10.x*c21.x*c13.x*c13y2*c23.y + 6*c10.x*c13.x*c21.y*c13y2*c23.x +
      6*c10.x*c13.x*c22.x*c13y2*c22.y + 6*c10.y*c21.x*c13.x*c13y2*c23.x - 3*c11.x*c12.x*c21.x*c13y2*c23.y -
      3*c11.x*c12.x*c21.y*c13y2*c23.x - 3*c11.x*c12.x*c22.x*c13y2*c22.y + 2*c11.x*c21.x*c12.y*c13y2*c23.x +
      4*c11.y*c12.x*c21.x*c13y2*c23.x - 6*c10.y*c21.x*c13x2*c13.y*c23.y - 6*c10.y*c13x2*c21.y*c13.y*c23.x -
      6*c10.y*c13x2*c22.x*c13.y*c22.y - 6*c20.x*c21.x*c13.x*c13y2*c23.y - 6*c20.x*c13.x*c21.y*c13y2*c23.x -
      6*c20.x*c13.x*c22.x*c13y2*c22.y + 3*c11.y*c21.x*c12.y*c13x2*c23.y - 3*c11.y*c12.y*c13.x*c22x2*c13.y +
      3*c11.y*c12.y*c13x2*c21.y*c23.x + 3*c11.y*c12.y*c13x2*c22.x*c22.y - 2*c12.x*c21.x*c12y2*c13.x*c23.y -
      2*c12.x*c21.x*c12y2*c13.y*c23.x - 2*c12.x*c12y2*c13.x*c21.y*c23.x - 2*c12.x*c12y2*c13.x*c22.x*c22.y -
      6*c20.y*c21.x*c13.x*c13y2*c23.x - 6*c21.x*c13.x*c21.y*c22.x*c13y2 + 6*c20.y*c13x2*c21.y*c13.y*c23.x +
      2*c12x2*c21.x*c12.y*c13.y*c23.y + 2*c12x2*c12.y*c21.y*c13.y*c23.x + 2*c12x2*c12.y*c22.x*c13.y*c22.y -
      3*c10.x*c22x2*c13y3 + 3*c20.x*c22x2*c13y3 + 3*c21x2*c22.x*c13y3 + c12y3*c13.x*c22x2 +
      3*c10.y*c13.x*c22x2*c13y2 + c11.x*c12.y*c22x2*c13y2 + 2*c11.y*c12.x*c22x2*c13y2 -
      c12.x*c12y2*c22x2*c13.y - 3*c20.y*c13.x*c22x2*c13y2 - 3*c21x2*c13.x*c13y2*c22.y +
      c12x2*c12.y*c13.x*(2*c21.y*c23.y + c22y2) + c11.x*c12.x*c13.x*c13.y*(6*c21.y*c23.y + 3*c22y2) +
      c21.x*c13x2*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c12x3*c13.y*(-2*c21.y*c23.y - c22y2) +
      c10.y*c13x3*(6*c21.y*c23.y + 3*c22y2) + c11.y*c12.x*c13x2*(-2*c21.y*c23.y - c22y2) +
      c11.x*c12.y*c13x2*(-4*c21.y*c23.y - 2*c22y2) + c10.x*c13x2*c13.y*(-6*c21.y*c23.y - 3*c22y2) +
      c13x2*c22.x*c13.y*(6*c20.y*c22.y + 3*c21y2) + c20.x*c13x2*c13.y*(6*c21.y*c23.y + 3*c22y2) +
      c13x3*(-2*c20.y*c21.y*c23.y - c22.y*(2*c20.y*c22.y + c21y2) - c20.y*(2*c21.y*c23.y + c22y2) -
      c21.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),

      -c10.x*c11.x*c12.y*c13.x*c13.y*c23.y + c10.x*c11.y*c12.x*c13.x*c13.y*c23.y + 6*c10.x*c11.y*c12.y*c13.x*c13.y*c23.x -
      6*c10.y*c11.x*c12.x*c13.x*c13.y*c23.y - c10.y*c11.x*c12.y*c13.x*c13.y*c23.x + c10.y*c11.y*c12.x*c13.x*c13.y*c23.x +
      c11.x*c11.y*c12.x*c12.y*c13.x*c23.y - c11.x*c11.y*c12.x*c12.y*c13.y*c23.x + c11.x*c20.x*c12.y*c13.x*c13.y*c23.y +
      c11.x*c20.y*c12.y*c13.x*c13.y*c23.x + c11.x*c21.x*c12.y*c13.x*c13.y*c22.y + c11.x*c12.y*c13.x*c21.y*c22.x*c13.y -
      c20.x*c11.y*c12.x*c13.x*c13.y*c23.y - 6*c20.x*c11.y*c12.y*c13.x*c13.y*c23.x - c11.y*c12.x*c20.y*c13.x*c13.y*c23.x -
      c11.y*c12.x*c21.x*c13.x*c13.y*c22.y - c11.y*c12.x*c13.x*c21.y*c22.x*c13.y - 6*c11.y*c21.x*c12.y*c13.x*c22.x*c13.y -
      6*c10.x*c20.x*c13y3*c23.x - 6*c10.x*c21.x*c22.x*c13y3 - 2*c10.x*c12y3*c13.x*c23.x + 6*c20.x*c21.x*c22.x*c13y3 +
      2*c20.x*c12y3*c13.x*c23.x + 2*c21.x*c12y3*c13.x*c22.x + 2*c10.y*c12x3*c13.y*c23.y - 6*c10.x*c10.y*c13.x*c13y2*c23.x +
      3*c10.x*c11.x*c12.x*c13y2*c23.y - 2*c10.x*c11.x*c12.y*c13y2*c23.x - 4*c10.x*c11.y*c12.x*c13y2*c23.x +
      3*c10.y*c11.x*c12.x*c13y2*c23.x + 6*c10.x*c10.y*c13x2*c13.y*c23.y + 6*c10.x*c20.x*c13.x*c13y2*c23.y -
      3*c10.x*c11.y*c12.y*c13x2*c23.y + 2*c10.x*c12.x*c12y2*c13.x*c23.y + 2*c10.x*c12.x*c12y2*c13.y*c23.x +
      6*c10.x*c20.y*c13.x*c13y2*c23.x + 6*c10.x*c21.x*c13.x*c13y2*c22.y + 6*c10.x*c13.x*c21.y*c22.x*c13y2 +
      4*c10.y*c11.x*c12.y*c13x2*c23.y + 6*c10.y*c20.x*c13.x*c13y2*c23.x + 2*c10.y*c11.y*c12.x*c13x2*c23.y -
      3*c10.y*c11.y*c12.y*c13x2*c23.x + 2*c10.y*c12.x*c12y2*c13.x*c23.x + 6*c10.y*c21.x*c13.x*c22.x*c13y2 -
      3*c11.x*c20.x*c12.x*c13y2*c23.y + 2*c11.x*c20.x*c12.y*c13y2*c23.x + c11.x*c11.y*c12y2*c13.x*c23.x -
      3*c11.x*c12.x*c20.y*c13y2*c23.x - 3*c11.x*c12.x*c21.x*c13y2*c22.y - 3*c11.x*c12.x*c21.y*c22.x*c13y2 +
      2*c11.x*c21.x*c12.y*c22.x*c13y2 + 4*c20.x*c11.y*c12.x*c13y2*c23.x + 4*c11.y*c12.x*c21.x*c22.x*c13y2 -
      2*c10.x*c12x2*c12.y*c13.y*c23.y - 6*c10.y*c20.x*c13x2*c13.y*c23.y - 6*c10.y*c20.y*c13x2*c13.y*c23.x -
      6*c10.y*c21.x*c13x2*c13.y*c22.y - 2*c10.y*c12x2*c12.y*c13.x*c23.y - 2*c10.y*c12x2*c12.y*c13.y*c23.x -
      6*c10.y*c13x2*c21.y*c22.x*c13.y - c11.x*c11.y*c12x2*c13.y*c23.y - 2*c11.x*c11y2*c13.x*c13.y*c23.x +
      3*c20.x*c11.y*c12.y*c13x2*c23.y - 2*c20.x*c12.x*c12y2*c13.x*c23.y - 2*c20.x*c12.x*c12y2*c13.y*c23.x -
      6*c20.x*c20.y*c13.x*c13y2*c23.x - 6*c20.x*c21.x*c13.x*c13y2*c22.y - 6*c20.x*c13.x*c21.y*c22.x*c13y2 +
      3*c11.y*c20.y*c12.y*c13x2*c23.x + 3*c11.y*c21.x*c12.y*c13x2*c22.y + 3*c11.y*c12.y*c13x2*c21.y*c22.x -
      2*c12.x*c20.y*c12y2*c13.x*c23.x - 2*c12.x*c21.x*c12y2*c13.x*c22.y - 2*c12.x*c21.x*c12y2*c22.x*c13.y -
      2*c12.x*c12y2*c13.x*c21.y*c22.x - 6*c20.y*c21.x*c13.x*c22.x*c13y2 - c11y2*c12.x*c12.y*c13.x*c23.x +
      2*c20.x*c12x2*c12.y*c13.y*c23.y + 6*c20.y*c13x2*c21.y*c22.x*c13.y + 2*c11x2*c11.y*c13.x*c13.y*c23.y +
      c11x2*c12.x*c12.y*c13.y*c23.y + 2*c12x2*c20.y*c12.y*c13.y*c23.x + 2*c12x2*c21.x*c12.y*c13.y*c22.y +
      2*c12x2*c12.y*c21.y*c22.x*c13.y + c21x3*c13y3 + 3*c10x2*c13y3*c23.x - 3*c10y2*c13x3*c23.y +
      3*c20x2*c13y3*c23.x + c11y3*c13x2*c23.x - c11x3*c13y2*c23.y - c11.x*c11y2*c13x2*c23.y +
      c11x2*c11.y*c13y2*c23.x - 3*c10x2*c13.x*c13y2*c23.y + 3*c10y2*c13x2*c13.y*c23.x - c11x2*c12y2*c13.x*c23.y +
      c11y2*c12x2*c13.y*c23.x - 3*c21x2*c13.x*c21.y*c13y2 - 3*c20x2*c13.x*c13y2*c23.y + 3*c20y2*c13x2*c13.y*c23.x +
      c11.x*c12.x*c13.x*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) + c12x3*c13.y*(-2*c20.y*c23.y - 2*c21.y*c22.y) +
      c10.y*c13x3*(6*c20.y*c23.y + 6*c21.y*c22.y) + c11.y*c12.x*c13x2*(-2*c20.y*c23.y - 2*c21.y*c22.y) +
      c12x2*c12.y*c13.x*(2*c20.y*c23.y + 2*c21.y*c22.y) + c11.x*c12.y*c13x2*(-4*c20.y*c23.y - 4*c21.y*c22.y) +
      c10.x*c13x2*c13.y*(-6*c20.y*c23.y - 6*c21.y*c22.y) + c20.x*c13x2*c13.y*(6*c20.y*c23.y + 6*c21.y*c22.y) +
      c21.x*c13x2*c13.y*(6*c20.y*c22.y + 3*c21y2) + c13x3*(-2*c20.y*c21.y*c22.y - c20y2*c23.y -
      c21.y*(2*c20.y*c22.y + c21y2) - c20.y*(2*c20.y*c23.y + 2*c21.y*c22.y)),

      -c10.x*c11.x*c12.y*c13.x*c13.y*c22.y + c10.x*c11.y*c12.x*c13.x*c13.y*c22.y + 6*c10.x*c11.y*c12.y*c13.x*c22.x*c13.y -
      6*c10.y*c11.x*c12.x*c13.x*c13.y*c22.y - c10.y*c11.x*c12.y*c13.x*c22.x*c13.y + c10.y*c11.y*c12.x*c13.x*c22.x*c13.y +
      c11.x*c11.y*c12.x*c12.y*c13.x*c22.y - c11.x*c11.y*c12.x*c12.y*c22.x*c13.y + c11.x*c20.x*c12.y*c13.x*c13.y*c22.y +
      c11.x*c20.y*c12.y*c13.x*c22.x*c13.y + c11.x*c21.x*c12.y*c13.x*c21.y*c13.y - c20.x*c11.y*c12.x*c13.x*c13.y*c22.y -
      6*c20.x*c11.y*c12.y*c13.x*c22.x*c13.y - c11.y*c12.x*c20.y*c13.x*c22.x*c13.y - c11.y*c12.x*c21.x*c13.x*c21.y*c13.y -
      6*c10.x*c20.x*c22.x*c13y3 - 2*c10.x*c12y3*c13.x*c22.x + 2*c20.x*c12y3*c13.x*c22.x + 2*c10.y*c12x3*c13.y*c22.y -
      6*c10.x*c10.y*c13.x*c22.x*c13y2 + 3*c10.x*c11.x*c12.x*c13y2*c22.y - 2*c10.x*c11.x*c12.y*c22.x*c13y2 -
      4*c10.x*c11.y*c12.x*c22.x*c13y2 + 3*c10.y*c11.x*c12.x*c22.x*c13y2 + 6*c10.x*c10.y*c13x2*c13.y*c22.y +
      6*c10.x*c20.x*c13.x*c13y2*c22.y - 3*c10.x*c11.y*c12.y*c13x2*c22.y + 2*c10.x*c12.x*c12y2*c13.x*c22.y +
      2*c10.x*c12.x*c12y2*c22.x*c13.y + 6*c10.x*c20.y*c13.x*c22.x*c13y2 + 6*c10.x*c21.x*c13.x*c21.y*c13y2 +
      4*c10.y*c11.x*c12.y*c13x2*c22.y + 6*c10.y*c20.x*c13.x*c22.x*c13y2 + 2*c10.y*c11.y*c12.x*c13x2*c22.y -
      3*c10.y*c11.y*c12.y*c13x2*c22.x + 2*c10.y*c12.x*c12y2*c13.x*c22.x - 3*c11.x*c20.x*c12.x*c13y2*c22.y +
      2*c11.x*c20.x*c12.y*c22.x*c13y2 + c11.x*c11.y*c12y2*c13.x*c22.x - 3*c11.x*c12.x*c20.y*c22.x*c13y2 -
      3*c11.x*c12.x*c21.x*c21.y*c13y2 + 4*c20.x*c11.y*c12.x*c22.x*c13y2 - 2*c10.x*c12x2*c12.y*c13.y*c22.y -
      6*c10.y*c20.x*c13x2*c13.y*c22.y - 6*c10.y*c20.y*c13x2*c22.x*c13.y - 6*c10.y*c21.x*c13x2*c21.y*c13.y -
      2*c10.y*c12x2*c12.y*c13.x*c22.y - 2*c10.y*c12x2*c12.y*c22.x*c13.y - c11.x*c11.y*c12x2*c13.y*c22.y -
      2*c11.x*c11y2*c13.x*c22.x*c13.y + 3*c20.x*c11.y*c12.y*c13x2*c22.y - 2*c20.x*c12.x*c12y2*c13.x*c22.y -
      2*c20.x*c12.x*c12y2*c22.x*c13.y - 6*c20.x*c20.y*c13.x*c22.x*c13y2 - 6*c20.x*c21.x*c13.x*c21.y*c13y2 +
      3*c11.y*c20.y*c12.y*c13x2*c22.x + 3*c11.y*c21.x*c12.y*c13x2*c21.y - 2*c12.x*c20.y*c12y2*c13.x*c22.x -
      2*c12.x*c21.x*c12y2*c13.x*c21.y - c11y2*c12.x*c12.y*c13.x*c22.x + 2*c20.x*c12x2*c12.y*c13.y*c22.y -
      3*c11.y*c21x2*c12.y*c13.x*c13.y + 6*c20.y*c21.x*c13x2*c21.y*c13.y + 2*c11x2*c11.y*c13.x*c13.y*c22.y +
      c11x2*c12.x*c12.y*c13.y*c22.y + 2*c12x2*c20.y*c12.y*c22.x*c13.y + 2*c12x2*c21.x*c12.y*c21.y*c13.y -
      3*c10.x*c21x2*c13y3 + 3*c20.x*c21x2*c13y3 + 3*c10x2*c22.x*c13y3 - 3*c10y2*c13x3*c22.y + 3*c20x2*c22.x*c13y3 +
      c21x2*c12y3*c13.x + c11y3*c13x2*c22.x - c11x3*c13y2*c22.y + 3*c10.y*c21x2*c13.x*c13y2 -
      c11.x*c11y2*c13x2*c22.y + c11.x*c21x2*c12.y*c13y2 + 2*c11.y*c12.x*c21x2*c13y2 + c11x2*c11.y*c22.x*c13y2 -
      c12.x*c21x2*c12y2*c13.y - 3*c20.y*c21x2*c13.x*c13y2 - 3*c10x2*c13.x*c13y2*c22.y + 3*c10y2*c13x2*c22.x*c13.y -
      c11x2*c12y2*c13.x*c22.y + c11y2*c12x2*c22.x*c13.y - 3*c20x2*c13.x*c13y2*c22.y + 3*c20y2*c13x2*c22.x*c13.y +
      c12x2*c12.y*c13.x*(2*c20.y*c22.y + c21y2) + c11.x*c12.x*c13.x*c13.y*(6*c20.y*c22.y + 3*c21y2) +
      c12x3*c13.y*(-2*c20.y*c22.y - c21y2) + c10.y*c13x3*(6*c20.y*c22.y + 3*c21y2) +
      c11.y*c12.x*c13x2*(-2*c20.y*c22.y - c21y2) + c11.x*c12.y*c13x2*(-4*c20.y*c22.y - 2*c21y2) +
      c10.x*c13x2*c13.y*(-6*c20.y*c22.y - 3*c21y2) + c20.x*c13x2*c13.y*(6*c20.y*c22.y + 3*c21y2) +
      c13x3*(-2*c20.y*c21y2 - c20y2*c22.y - c20.y*(2*c20.y*c22.y + c21y2)),

      -c10.x*c11.x*c12.y*c13.x*c21.y*c13.y + c10.x*c11.y*c12.x*c13.x*c21.y*c13.y + 6*c10.x*c11.y*c21.x*c12.y*c13.x*c13.y -
      6*c10.y*c11.x*c12.x*c13.x*c21.y*c13.y - c10.y*c11.x*c21.x*c12.y*c13.x*c13.y + c10.y*c11.y*c12.x*c21.x*c13.x*c13.y -
      c11.x*c11.y*c12.x*c21.x*c12.y*c13.y + c11.x*c11.y*c12.x*c12.y*c13.x*c21.y + c11.x*c20.x*c12.y*c13.x*c21.y*c13.y +
      6*c11.x*c12.x*c20.y*c13.x*c21.y*c13.y + c11.x*c20.y*c21.x*c12.y*c13.x*c13.y - c20.x*c11.y*c12.x*c13.x*c21.y*c13.y -
      6*c20.x*c11.y*c21.x*c12.y*c13.x*c13.y - c11.y*c12.x*c20.y*c21.x*c13.x*c13.y - 6*c10.x*c20.x*c21.x*c13y3 -
      2*c10.x*c21.x*c12y3*c13.x + 6*c10.y*c20.y*c13x3*c21.y + 2*c20.x*c21.x*c12y3*c13.x + 2*c10.y*c12x3*c21.y*c13.y -
      2*c12x3*c20.y*c21.y*c13.y - 6*c10.x*c10.y*c21.x*c13.x*c13y2 + 3*c10.x*c11.x*c12.x*c21.y*c13y2 -
      2*c10.x*c11.x*c21.x*c12.y*c13y2 - 4*c10.x*c11.y*c12.x*c21.x*c13y2 + 3*c10.y*c11.x*c12.x*c21.x*c13y2 +
      6*c10.x*c10.y*c13x2*c21.y*c13.y + 6*c10.x*c20.x*c13.x*c21.y*c13y2 - 3*c10.x*c11.y*c12.y*c13x2*c21.y +
      2*c10.x*c12.x*c21.x*c12y2*c13.y + 2*c10.x*c12.x*c12y2*c13.x*c21.y + 6*c10.x*c20.y*c21.x*c13.x*c13y2 +
      4*c10.y*c11.x*c12.y*c13x2*c21.y + 6*c10.y*c20.x*c21.x*c13.x*c13y2 + 2*c10.y*c11.y*c12.x*c13x2*c21.y -
      3*c10.y*c11.y*c21.x*c12.y*c13x2 + 2*c10.y*c12.x*c21.x*c12y2*c13.x - 3*c11.x*c20.x*c12.x*c21.y*c13y2 +
      2*c11.x*c20.x*c21.x*c12.y*c13y2 + c11.x*c11.y*c21.x*c12y2*c13.x - 3*c11.x*c12.x*c20.y*c21.x*c13y2 +
      4*c20.x*c11.y*c12.x*c21.x*c13y2 - 6*c10.x*c20.y*c13x2*c21.y*c13.y - 2*c10.x*c12x2*c12.y*c21.y*c13.y -
      6*c10.y*c20.x*c13x2*c21.y*c13.y - 6*c10.y*c20.y*c21.x*c13x2*c13.y - 2*c10.y*c12x2*c21.x*c12.y*c13.y -
      2*c10.y*c12x2*c12.y*c13.x*c21.y - c11.x*c11.y*c12x2*c21.y*c13.y - 4*c11.x*c20.y*c12.y*c13x2*c21.y -
      2*c11.x*c11y2*c21.x*c13.x*c13.y + 3*c20.x*c11.y*c12.y*c13x2*c21.y - 2*c20.x*c12.x*c21.x*c12y2*c13.y -
      2*c20.x*c12.x*c12y2*c13.x*c21.y - 6*c20.x*c20.y*c21.x*c13.x*c13y2 - 2*c11.y*c12.x*c20.y*c13x2*c21.y +
      3*c11.y*c20.y*c21.x*c12.y*c13x2 - 2*c12.x*c20.y*c21.x*c12y2*c13.x - c11y2*c12.x*c21.x*c12.y*c13.x +
      6*c20.x*c20.y*c13x2*c21.y*c13.y + 2*c20.x*c12x2*c12.y*c21.y*c13.y + 2*c11x2*c11.y*c13.x*c21.y*c13.y +
      c11x2*c12.x*c12.y*c21.y*c13.y + 2*c12x2*c20.y*c21.x*c12.y*c13.y + 2*c12x2*c20.y*c12.y*c13.x*c21.y +
      3*c10x2*c21.x*c13y3 - 3*c10y2*c13x3*c21.y + 3*c20x2*c21.x*c13y3 + c11y3*c21.x*c13x2 - c11x3*c21.y*c13y2 -
      3*c20y2*c13x3*c21.y - c11.x*c11y2*c13x2*c21.y + c11x2*c11.y*c21.x*c13y2 - 3*c10x2*c13.x*c21.y*c13y2 +
      3*c10y2*c21.x*c13x2*c13.y - c11x2*c12y2*c13.x*c21.y + c11y2*c12x2*c21.x*c13.y - 3*c20x2*c13.x*c21.y*c13y2 +
      3*c20y2*c21.x*c13x2*c13.y,

      c10.x*c10.y*c11.x*c12.y*c13.x*c13.y - c10.x*c10.y*c11.y*c12.x*c13.x*c13.y + c10.x*c11.x*c11.y*c12.x*c12.y*c13.y -
      c10.y*c11.x*c11.y*c12.x*c12.y*c13.x - c10.x*c11.x*c20.y*c12.y*c13.x*c13.y + 6*c10.x*c20.x*c11.y*c12.y*c13.x*c13.y +
      c10.x*c11.y*c12.x*c20.y*c13.x*c13.y - c10.y*c11.x*c20.x*c12.y*c13.x*c13.y - 6*c10.y*c11.x*c12.x*c20.y*c13.x*c13.y +
      c10.y*c20.x*c11.y*c12.x*c13.x*c13.y - c11.x*c20.x*c11.y*c12.x*c12.y*c13.y + c11.x*c11.y*c12.x*c20.y*c12.y*c13.x +
      c11.x*c20.x*c20.y*c12.y*c13.x*c13.y - c20.x*c11.y*c12.x*c20.y*c13.x*c13.y - 2*c10.x*c20.x*c12y3*c13.x +
      2*c10.y*c12x3*c20.y*c13.y - 3*c10.x*c10.y*c11.x*c12.x*c13y2 - 6*c10.x*c10.y*c20.x*c13.x*c13y2 +
      3*c10.x*c10.y*c11.y*c12.y*c13x2 - 2*c10.x*c10.y*c12.x*c12y2*c13.x - 2*c10.x*c11.x*c20.x*c12.y*c13y2 -
      c10.x*c11.x*c11.y*c12y2*c13.x + 3*c10.x*c11.x*c12.x*c20.y*c13y2 - 4*c10.x*c20.x*c11.y*c12.x*c13y2 +
      3*c10.y*c11.x*c20.x*c12.x*c13y2 + 6*c10.x*c10.y*c20.y*c13x2*c13.y + 2*c10.x*c10.y*c12x2*c12.y*c13.y +
      2*c10.x*c11.x*c11y2*c13.x*c13.y + 2*c10.x*c20.x*c12.x*c12y2*c13.y + 6*c10.x*c20.x*c20.y*c13.x*c13y2 -
      3*c10.x*c11.y*c20.y*c12.y*c13x2 + 2*c10.x*c12.x*c20.y*c12y2*c13.x + c10.x*c11y2*c12.x*c12.y*c13.x +
      c10.y*c11.x*c11.y*c12x2*c13.y + 4*c10.y*c11.x*c20.y*c12.y*c13x2 - 3*c10.y*c20.x*c11.y*c12.y*c13x2 +
      2*c10.y*c20.x*c12.x*c12y2*c13.x + 2*c10.y*c11.y*c12.x*c20.y*c13x2 + c11.x*c20.x*c11.y*c12y2*c13.x -
      3*c11.x*c20.x*c12.x*c20.y*c13y2 - 2*c10.x*c12x2*c20.y*c12.y*c13.y - 6*c10.y*c20.x*c20.y*c13x2*c13.y -
      2*c10.y*c20.x*c12x2*c12.y*c13.y - 2*c10.y*c11x2*c11.y*c13.x*c13.y - c10.y*c11x2*c12.x*c12.y*c13.y -
      2*c10.y*c12x2*c20.y*c12.y*c13.x - 2*c11.x*c20.x*c11y2*c13.x*c13.y - c11.x*c11.y*c12x2*c20.y*c13.y +
      3*c20.x*c11.y*c20.y*c12.y*c13x2 - 2*c20.x*c12.x*c20.y*c12y2*c13.x - c20.x*c11y2*c12.x*c12.y*c13.x +
      3*c10y2*c11.x*c12.x*c13.x*c13.y + 3*c11.x*c12.x*c20y2*c13.x*c13.y + 2*c20.x*c12x2*c20.y*c12.y*c13.y -
      3*c10x2*c11.y*c12.y*c13.x*c13.y + 2*c11x2*c11.y*c20.y*c13.x*c13.y + c11x2*c12.x*c20.y*c12.y*c13.y -
      3*c20x2*c11.y*c12.y*c13.x*c13.y - c10x3*c13y3 + c10y3*c13x3 + c20x3*c13y3 - c20y3*c13x3 -
      3*c10.x*c20x2*c13y3 - c10.x*c11y3*c13x2 + 3*c10x2*c20.x*c13y3 + c10.y*c11x3*c13y2 +
      3*c10.y*c20y2*c13x3 + c20.x*c11y3*c13x2 + c10x2*c12y3*c13.x - 3*c10y2*c20.y*c13x3 - c10y2*c12x3*c13.y +
      c20x2*c12y3*c13.x - c11x3*c20.y*c13y2 - c12x3*c20y2*c13.y - c10.x*c11x2*c11.y*c13y2 +
      c10.y*c11.x*c11y2*c13x2 - 3*c10.x*c10y2*c13x2*c13.y - c10.x*c11y2*c12x2*c13.y + c10.y*c11x2*c12y2*c13.x -
      c11.x*c11y2*c20.y*c13x2 + 3*c10x2*c10.y*c13.x*c13y2 + c10x2*c11.x*c12.y*c13y2 +
      2*c10x2*c11.y*c12.x*c13y2 - 2*c10y2*c11.x*c12.y*c13x2 - c10y2*c11.y*c12.x*c13x2 + c11x2*c20.x*c11.y*c13y2 -
      3*c10.x*c20y2*c13x2*c13.y + 3*c10.y*c20x2*c13.x*c13y2 + c11.x*c20x2*c12.y*c13y2 - 2*c11.x*c20y2*c12.y*c13x2 +
      c20.x*c11y2*c12x2*c13.y - c11.y*c12.x*c20y2*c13x2 - c10x2*c12.x*c12y2*c13.y - 3*c10x2*c20.y*c13.x*c13y2 +
      3*c10y2*c20.x*c13x2*c13.y + c10y2*c12x2*c12.y*c13.x - c11x2*c20.y*c12y2*c13.x + 2*c20x2*c11.y*c12.x*c13y2 +
      3*c20.x*c20y2*c13x2*c13.y - c20x2*c12.x*c12y2*c13.y - 3*c20x2*c20.y*c13.x*c13y2 + c12x2*c20y2*c12.y*c13.x
    ])

    roots = poly.rootsInterval(0, 1)

    for own i, s of roots
      xRoots = new Polynomial([
        c13.x
        c12.x
        c11.x
        c10.x - c20.x - s * c21.x - s * s * c22.x - s * s * s * c23.x
      ]).roots()
      yRoots = new Polynomial([
        c13.y
        c12.y
        c11.y
        c10.y - c20.y - s * c21.y - s * s * c22.y - s * s * s * c23.y
      ]).roots()


      if xRoots.length > 0 and yRoots.length > 0
        # IMPORTANT
        # Tweaking this to be smaller can make it miss intersections.
        tolerance = 1e-2

        for own j, xRoot of xRoots
          if 0 <= xRoot and xRoot <= 1
            for own k, yRoot of yRoots
              if Math.abs(xRoot - yRoot) < tolerance
                results.push(
                  c23.multiplyBy(s * s * s).add(c22.multiplyBy(s * s).add(c21.multiplyBy(s).add(c20))))
    results



###

    Mondrian SVG library

    Artur Sapek 2012 - 2013

###


class Monsvg

  # MonSvg
  #
  # Over-arching class for all vector objects
  #
  # I/P : data Object of SVG element's attributes
  #
  # O/P : self
  #
  # Subclasses:
  #   Line
  #   Rect
  #   Circle
  #   Polygon
  #   Path


  constructor: (@data = {}) ->

    # Create SVG element representation
    # Set up metadata
    #
    # No I/P
    #
    # O/P : self

    @rep = @toSVG()
    @$rep = $(@rep)

    @metadata =
      angle: 0
      locked: false

    unless @data.dontTrack
      @metadata.uuid = uuid()

    @rep.setAttribute 'uuid', @metadata.uuid

    @validateColors()

    if @type isnt "text"
      @data = $.extend
        fill:   new Color("none")
        stroke: new Color("none")
      , @data

    # This is used to track landmark changes to @data
    # for the archive. Consider a user selecting a few elements
    # and dragging around on the color picker until they like what
    # they see. There's no way in hell we're gonna store every
    # single color they hovered over while happily dragging around.
    #
    # So we keep two copies of @data. The second is called @dataArchived.
    # Here we set it for the first time.

    @updateDataArchived()

    # Apply
    if @data["mondrian:angle"]?
      @metadata.angle = parseFloat(@data["mondrian:angle"], 10)


    ###
    if @data.transform?
      attrs = @data.transform.split(" ")
      for attr in attrs
        key = attr.match(/[a-z]+/gi)?[0]
        val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")
      @transform[key] = val.replace(/[\(\)]/gi, "")
      #console.log "saved #{attr} as #{key} #{val}"
  ###


  commit: ->
    # Commit any changes to its representation in the DOM
    #
    # No I/P
    # O/P: self

    ###
    newTransform = []

    for own key, val of @transform
      if key is "translate"
        newTransform.push "#{key}(#{val.x},#{val.y})"
      else
        newTransform.push "#{key}(#{val})"

    @data.transform = newTransform.join(" ")
    ###

    for key, val of @data
      if key is ""
        delete @data[""]
      else
        if "#{val}".mentions "NaN"
          throw new Error "NaN! Ack. Attribute = #{key}, Value = #{val}"
        @rep.setAttribute(key, val)

    if @metadata.angle is 0
      @rep.removeAttribute('mondrian:angle')
    else
      if @metadata.angle < 0
        @metadata.angle += 360
      @rep.setAttribute('mondrian:angle', @metadata.angle)

    @

  updateDataArchived: (attr) ->
    # If no attr is provided simply copy the new values in @data to @dataArchived
    # If there is, only copy over that one attribute.
    if attr?
      @dataArchived[attr] = @data[attr]
    else
      @dataArchived = cloneObject @data


  toSVG: ->
    # Return the SVG DOM element that this Monsvg object represents
    # We need to use the svg namespace for the element to behave properly
    self = document.createElementNS('http://www.w3.org/2000/svg', @type)
    for key, val of @data
      self.setAttribute(key, val) unless key is ""
    self


  validateColors: ->
    # Convert color strings to Color objects
    if @data.fill? and not (@data.fill instanceof Color)
      @data.fill = new Color @data.fill
    if @data.stroke? and not (@data.stroke instanceof Color)
      @data.stroke = new Color @data.stroke
    if not @data["stroke-width"]?
      @data["stroke-width"] = 1



  points: []


  center: ->
    # Returns the center of a cluster of posns
    #
    # O/P: Posn

    xr = @xRange()
    yr = @yRange()
    new Posn(xr.min + (xr.max - xr.min) / 2, yr.min + (yr.max - yr.min) / 2)

  queryPoint: (rep) ->
    @points.filter((a) -> a.baseHandle is rep)[0]

  queryAntlerPoint: (rep) ->
    @antlerPoints.filter((a) -> a.baseHandle is rep)[0]

  show: -> @rep.style.display = "block"

  hide: -> @rep.style.display = "none"

  showPoints: ->
    @points.map (point) -> point.show()
    @

  hidePoints: ->
    @points.map (point) -> point.hide()
    @

  unhoverPoints: ->
    @points.map (point) -> point.unhover()
    @

  removePoints: ->
    @points.map (point) -> point.clear()
    @

  unremovePoints: ->
    @points.map (point) -> point.unclear()
    @


  destroyPoints: ->
    @points.map (p) -> p.remove()


  removeHoverTargets: ->
    existent = qa("svg#hover-targets [owner='#{@metadata.uuid}']")
    for ht in existent
      ht.remove()


  redrawHoverTargets: ->
    @removeHoverTargets()
    @points.map (p) => new HoverTarget(p.prec, p)
    @



  topLeftBound: ->
    new Posn(@xRange().min, @yRange().min)

  topRightBound: ->
    new Posn(@xRange().max, @yRange().min)

  bottomRightBound: ->
    new Posn(@xRange().max, @yRange().max)

  bottomLeftBound: ->
    new Posn(@xRange().min, @yRange().max)

  attr: (data) ->
    for key, val of data
      if typeof val == 'function'
        @data[key] = val(@data[key])
      else
        @data[key] = val


  appendTo: (selector, track = true) ->
    if typeof selector is "string"
      target = q(selector)
    else
      target = selector
    target.appendChild(@rep)
    if track
      if not ui.elements.has @
        ui.elements.push @
    @

  clone: ->
    #@commit()
    cloneData = cloneObject @data
    cloneTransform = cloneObject @transform
    delete cloneData.id
    clone = new @constructor(cloneData)
    clone.transform = cloneTransform
    clone

  delete: ->
    @rep.remove()
    ui.elements = ui.elements.remove @
    async =>
      @destroyPoints()
      @removeHoverTargets()
      if @group
        @group.delete()

  zIndex: ->
    zi = 0
    dom.$main.children().each (ind, elem) =>
      if elem.getAttribute("uuid") == @metadata.uuid
        zi = ind
        return false
    zi


  moveForward: (n = 1) ->
    for x in [1..n]
      next = @$rep.next()
      break if next.length is 0
      next.after(@$rep)
    @


  moveBack: (n = 1) ->
    for x in [1..n]
      prev = @$rep.prev()
      break if prev.length is 0
      prev.before(@$rep)
    @


  bringToFront: ->
    dom.$main.append @$rep


  sendToBack: ->
    dom.$main.prepend @$rep


  transform: {}


  swapFillAndStroke: ->
    swap = @data.stroke
    @attr
      'stroke': @data.fill
      'fill': swap
    @commit()


  eyedropper: (sample) ->
    @data.fill = sample.data.fill
    @data.stroke = sample.data.stroke
    @data['stroke-width'] = sample.data['stroke-width']
    @commit()


  bounds: ->
    cached = @boundsCached
    if cached isnt null and @caching
      return cached
    else
      xr = @xRange()
      yr = @yRange()
      @boundsCached = new Bounds(
        xr.min,
        yr.min,
        xr.length(),
        yr.length())


  boundsCached: null


  hideUI: ->
    ui.removePointHandles()


  refreshUI: ->
    @points.map (p) -> p.updateHandle()
    @redrawHoverTargets()

  overlaps: (other) ->

    # Checks for overlap with another shape.
    # Redirects to appropriate method.

    # I/P: Polygon/Circle/Rect
    # O/P: true or false

    @['overlaps' + other.type.capitalize()](other)


  lineSegmentsIntersect: (other) ->
    # Returns bool, whether or not this shape and that shape intersect or overlap
    # Short-circuits as soon as it finds true.
    #
    # I/P: Another shape that has lineSegments()
    # O/P: Boolean

    ms = @lineSegments() # My lineSegments
    os = other.lineSegments() # Other's lineSegments

    for mline in ms

      # The true parameter on bounds() tells mline to use its cached bounds.
      # It saves a lot of time and is okay to do in a situation like this where we're just going
      # through a for-loop and not changing the lines at all.
      #
      # Admittedly, it really only saves time below when it calls it for oline since
      # each mline is only being looked at once, but why not cache as much as possible? :)

      if mline instanceof CubicBezier
        mbounds = mline.bounds(true)

      a = if mline instanceof LineSegment then mline.a else mline.p1
      b = if mline instanceof LineSegment then mline.b else mline.p2

      if (other.contains a) or (other.contains b)
        return true

      for oline in os

        if mline instanceof CubicBezier or oline instanceof CubicBezier
          obounds = oline.bounds(true)
          continueChecking = mbounds.overlapsBounds(obounds)
        else
          continueChecking = true

        if continueChecking
          if mline.intersects(oline)
            return true
    return false


  lineSegmentIntersections: (other) ->
    # Returns an Array of tuple-Arrays of [intersection, point]
    intersections = []

    ms = @lineSegments() # My lineSegments
    os = other.lineSegments() # Other's lineSegments

    for mline in ms
      mbounds = mline.bounds(true) # Accept cached bounds since these aren't changing.

      for oline in os
        obounds = oline.bounds(true)

        # Only run the intersection algorithms for lines whose BOUNDS overlap.
        # This check makes lineSegmentIntersections an order of magnitude faster - most pairs never pass this point.

        #if mbounds.overlapsBounds(obounds)

        inter = mline.intersection oline

        if inter instanceof Posn
          # mline.source is the original point that makes up that line segment.
          intersections.push
            intersection: [inter],
            aline: mline
            bline: oline
            a: mline.source
            b: oline.source
        else if (inter instanceof Array and inter.length > 0)
          intersections.push
            intersection: inter
            aline: mline
            bline: oline
            a: mline.source
            b: oline.source

    intersections


  remove: ->
    @rep.remove()
    if @points isnt []
      @points.map (p) ->
        p.baseHandle?.remove()


  convertTo: (type) ->
    result = @["convertTo#{type}"]()
    result.eyedropper @
    result

  toString: ->
    "(#{@type} Monsvg object)"

  repToString: ->
    new XMLSerializer().serializeToString(@rep)


  carryOutTransformations: (transform = @data.transform, center = new Posn(0, 0)) ->

    ###
      We do things this way because fuck the transform attribute.

      Basically, when we commit shapes for the first time from some other file,
      if they have a transform attribute we effectively just alter the data
      that makes those shapes up so that they still look the same, but they no longer
      have a transform attr.
    ###

    attrs = transform.replace(", ", ",").split(" ").reverse()

    for attr in attrs
      key = attr.match(/[a-z]+/gi)?[0]
      val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")

      switch key
        when "scale"
          # A scale is a scale, but we also scale the stroke-width
          factor = parseFloat val
          @scale(factor, factor, center)
          @data["stroke-width"] *= factor

        when "translate"
          # A translate is simply a nudge
          val = val.split ","
          x = parseFloat val[0]
          y = if val[1]? then parseFloat(val[1]) else 0
          @nudge(x, -y)

        when "rotate"
          # Duh
          @rotate(parseFloat(val), center)
          @metadata.angle = 0




  applyTransform: (transform) ->

    console.log "apply transform"

    for attr in transform.split(" ")
      key = attr.match(/[a-z]+/gi)?[0]
      val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")

      switch key
        when "scale"
          val = parseFloat val
          if @transform.scale?
            @transform.scale *= val
          else
            @transform.scale = val

        when "translate"
          val = val.split ","
          x = parseFloat val[0]
          y = parseFloat val[1]
          x = parseFloat x
          y = parseFloat y
          if @transform.translate?
            @transform.translate.x += x
            @transform.translate.y += y
          else
            @transform.translate = { x: x, y: y }

        when "rotate"
          val = parseFloat val
          if @transform.rotate?
            @transform.rotate += val
            @transform.rotate %= 360
          else
            @transform.rotate = val

    @commit()


  setFill: (val) ->
    @data.fill = new Color val

  setStroke: (val) ->
    @data.stroke = new Color val

  setStrokeWidth: (val) ->
    @data['stroke-width'] = val


  setupToCanvas: (context) ->
    context.beginPath()
    context.fillStyle = "#{@data.fill}"
    if (@data['stroke-width']? > 0) and (@data.stroke?.hex != "none")
      context.strokeStyle = "#{@data.stroke}"
      context.lineWidth = parseFloat @data['stroke-width']
    else
      context.strokeStyle = "none"
      context.lineWidth = "0"
    context


  finishToCanvas: (context) ->
    context.closePath() if @points?.closed
    context.fill()# if @data.fill?
    context.stroke() if (@data['stroke-width'] > 0) and (@data.stroke?.hex != "none")
    context

  clearCachedObjects: ->

  lineSegments: ->


###

  HoverTarget

###


class HoverTarget extends Monsvg
  type: 'path'

  constructor: (@a, @b, @width) ->
    # I/P: a: First point
    #      b: Second point
    #      width: stroke-width to be added to

    # Default width is always 1
    if not @width?
      @width = 1

    @owner = @b.owner

    # Convert SmoothTo's to independent CurveTo's
    b = if @b instanceof SmoothTo then @b.toCurveTo() else @b


    # Standalone path. MoveTo precessor point, and make the current one.
    # This way it exactly represents a single line-segment between two points on the path.
    @d = "M#{@a.x * ui.canvas.zoom},#{@a.y * ui.canvas.zoom} #{b.toStringWithZoom()}"

    # Build the data object, just a bunch of defaults.
    @data =
      fill: "none"
      stroke: "rgba(75, 175, 255, 0.0)"
      "stroke-width": 4 / ui.canvas.zoom
      d: @d

    # Store under second point.
    @b.hoverTarget = @

    super @data

    # This class should be as easy to use as possible, so just append it right away.
    # False for don't track.
    @appendTo '#hover-targets', false

    # Keeping track of a few things for the cursor-tracking events.

    @rep.setAttribute 'a', @a.at
    @rep.setAttribute 'b', @b.at
    @rep.setAttribute 'owner', @owner.metadata.uuid


  highlight: ->
    ui.unhighlightHoverTargets()
    @a.hover()
    @b.hover()
    @attr
      "stroke-width": 5
      stroke: "#4981e0"
    ui.hoverTargetsHighlighted.push @
    @commit()


  unhighlight: ->
    @attr
      "stroke-width": 5
      stroke: "rgba(75, 175, 255, 0.0)"
    @commit()


  active: ->
    @a.baseHandle.setAttribute 'active', ''
    @b.baseHandle.setAttribute 'active', ''


  nudge: (x, y) ->
    @a.nudge(x, y)
    @b.nudge(x, y)

    @owner.commit()
    @unhighlight()
    @constructor(@a, @b, @width)




###

  Line

###


class Line extends Monsvg
  type: 'line'


  a: ->
    new Posn(@data.x1, @data.y1)


  b: ->
    new Posn(@data.x2, @data.y2)


  absorbA: (a) ->
    @data.x1 = a.x
    @data.y1 = a.y


  absorbB: (b) ->
    @data.x2 = b.x
    @data.y2 = b.y


  asLineSegment: ->
    new LineSegment(@a(), @b())


  fromLineSegment: (ls) ->

    # Inherit points from a LineSegment
    #
    # I/P : LineSegment
    #
    # O/P : self

    @absorbA(ls.a)
    @absorbB(ls.b)


  xRange: -> @asLineSegment().xRange()


  yRange: -> @asLineSegment().yRange()


  nudge: (x, y) ->
    @data.x1 += x
    @data.x2 += x
    @data.y1 -= y
    @data.y2 -= y
    @commit()


  scale: (x, y, origin) ->
    @absorbA @a().scale(x, y, origin)
    @absorbB @b().scale(x, y, origin)
    @commit()


  overlapsRect: (rect) ->
    ls = @asLineSegment()

    return true if @a().insideOf rect
    return true if @b().insideOf rect

    for l in rect.lineSegments()
      return true if l.intersects ls
    false




class Rect extends Monsvg
  type: 'rect'

  constructor: (@data) ->
    super @data
    @data.x = 0 if not @data.x?
    @data.y = 0 if not @data.y?

    @data.x = parseFloat @data.x
    @data.y = parseFloat @data.y
    @data.width = parseFloat @data.width
    @data.height = parseFloat @data.height


  commit: ->
    @_validateDimensions()
    super


  points: ->
    [new Point(@data.x, @data.y),
     new Point(@data.x + @data.width, @data.y),
     new Point(@data.x + @data.width, @data.y + @data.height),
     new Point(@data.x, @data.y + @data.height)]


  ###

    Geometric data

      points()
      lineSegments()
      center()
      xRange()
      yRange()

  ###

  lineSegments: ->
    p = @points()
    [new LineSegment(p[0], p[1], p[1])
     new LineSegment(p[1], p[2], p[2])
     new LineSegment(p[2], p[3], p[3])
     new LineSegment(p[3], p[0], p[0])]

  center: ->
    new Posn(@data.x + (@data.width / 2), @data.y + (@data.height / 2))

  xRange: ->
    new Range(@data.x, @data.x + @data.width)

  yRange: ->
    new Range(@data.y, @data.y + @data.height)

  clearCachedObjects: ->

  ###

    Relationship analysis

      contains()
      overlaps()
      intersections()
      containments()
      containmentsBothWays()

  ###

  contains: (posn) ->
    @xRange().contains(posn.x) and @yRange().contains(posn.y)


  overlaps: (other) ->

    ###
      Fuck you whore
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    ###

    @['overlaps' + other.type.capitalize()](other)

  overlapsPolygon: (polygon) ->
    if @contains polygon.center() or polygon.contains(@center())
      return true
    return @lineSegmentsIntersect(polygon)


  overlapsCircle: (circle) ->

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)


  intersections: (obj) ->
    intersections = []
    for s1 in @lineSegments()
      for s2 in obj.lineSegments()
        inter = s1.intersection(s2)
        if inter instanceof Posn
          intersections.push(inter)
    return intersections

  containments: (obj) ->
    containments = []
    points = obj.points
    xr = @xRange()
    yr = @yRange()

    for point in points
      if xr.contains(point.x) and yr.contains(point.y)
        containments.push(point)
    return containments


  containmentsBothWays: (obj) ->
    @containments(obj).concat(obj.containments(@))


  scale: (factorX, factorY, origin=@center()) ->
    @attr
      x:      (x) => (x - origin.x) * factorX + origin.x
      y:      (y) => (y - origin.y) * factorY + origin.y
      width:  (w) -> w * factorX
      height: (h) -> h * factorY
    @commit()


  nudge: (x, y) ->
    @data.x += x
    @data.y -= y
    @commit()


  # Operates on perfect rectangle
  #
  # O/P: self as polygon, replaces instance with polygon instance


  convertToPath: ->
    # Get this rect's points
    pts = @points()

    # Build a new rectangular path from it
    path = new Path
      d: "M#{pts[0]} L#{pts[1]} L#{pts[2]} L#{pts[3]} L#{pts[0]}"

    # Copy the colors over
    path.eyedropper @

    path.updateDataArchived()

    path


  drawToCanvas: (context) ->
    context = @setupToCanvas(context)
    context.rect(@data.x, @data.y, @data.width, @data.height)
    context = @finishToCanvas(context)


  _validateDimensions: ->
    if @data.height < 0
      @data.height *= -1
    if @data.width < 0
      @data.width *= -1




class Circle extends Monsvg
  type: 'circle'

  scale: (factor, origin) ->
    @attr('r': (r) -> r * factor)
    @commit()

  scaleXY: (x, y, origin) ->
    # Conver to ellipse, then scale.

  points: []

  center: ->
    new Posn(@data.cx, @data.cy)

  xRange: ->
    new Range(@data.cx - @data.r, @data.cx + @data.r)

  yRange: ->
    new Range(@data.cy - @data.r, @data.cy + @data.r)

  overlaps: (other) ->

    ###
      Checks for overlap with another shape.
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    ###

    @['overlaps' + other.type.capitalize()](other)



  overlapsPolygon: (polygon) ->
    return true if polygon.contains @center()
    for line in polygon.lineSegments()
      if line.intersects(@)
        return true
    return false


  overlapsCircle: (circle) ->
    # TODO

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)

  nudge: (x, y) ->
    @attr
      cx: (cx) -> cx += x
      cy: (cy) -> cy -= y
    @commit()


###

  Ellipse

###


class Ellipse extends Monsvg
  type: 'ellipse'


  constructor: (@data) ->
    super @data

    @data.cx = parseFloat @data.cx
    @data.cy = parseFloat @data.cy
    @data.rx = parseFloat @data.rx
    @data.ry = parseFloat @data.ry


  xRange: ->
    new Range(@data.cx - @data.rx, @data.cx + @data.rx)


  yRange: ->
    new Range(@data.cy - @data.ry, @data.cy + @data.ry)


  c: ->
    new Posn(@data.cx, @data.cy)


  top: ->
    new Posn(@data.cx, @data.cy - @data.ry)


  right: ->
    new Posn(@data.cx + @data.rx, @data.cy)


  bottom: ->
    new Posn(@data.cx, @data.cy + @data.ry)


  left: ->
    new Posn(@data.cx - @data.rx, @data.cy)


  overlapsRect: (r) ->
    for l in r.lineSegments()
      if (l.intersectionWithEllipse @) instanceof Array
        return true


  nudge: (x, y) ->
    @data.cx += x
    @data.cy -= y
    @commit()


  scale: (x, y, origin) ->
    c = @c().scale(x, y, origin)
    @data.cx = c.x
    @data.cy = c.y
    @data.rx *= x
    @data.ry *= y
    @commit()


  convertToPath: ->
    p = new Path(
      d: "M#{@data.cx},#{@data.cy - @data.ry}")

    p.eyedropper @

    top = @top()
    right = @right()
    bottom = @bottom()
    left = @left()

    rx = @data.rx
    ry = @data.ry

    ky = Math.KAPPA * ry
    kx = Math.KAPPA * rx

    p.points.push new CurveTo(top.x + kx, top.y, right.x, right.y - ky, right.x, right.y)
    p.points.push new CurveTo(right.x, right.y + ky, bottom.x + kx, bottom.y, bottom.x, bottom.y)
    p.points.push new CurveTo(bottom.x - kx, bottom.y, left.x, left.y + ky, left.x, left.y)
    p.points.push new CurveTo(left.x, left.y - ky, top.x - kx, top.y, top.x, top.y)
    p.points.close()
    p.points.drawBasePoints()

    p.updateDataArchived()

    p


# Polygon class
#
#
#
#

class Polygon extends Monsvg
  type: 'polygon'

  constructor: (@data) ->
    @points = new PointsList(@parsePoints(@data.points))
    super @data

  appendTo: (selector, track = true) ->
    super selector, track
    @points.drawBasePoints().hide()
    @redrawHoverTargets() if track
    @


  commit: ->
    @data.points = @points.toString()
    super

  lineSegments: ->
    points = @points.points
    segments = []
    # Recur over points, loop back to first posn at the end.
    points.map (curr, ind) ->
      # Get the next point. If there is no next point, use the first point (loop back around)
      next = points[if ind == (points.length - 1) then 0 else ind + 1]
      # Make the LineSegment and bail
      segments.push(new LineSegment(curr, next))

    segments


  xs: ->
    @points.all().map((posn) -> posn.x)


  ys: ->
    @points.all().map((posn) -> posn.y)


  xRange: ->
    new Range().fromList(@xs())


  yRange: ->
    new Range().fromList(@ys())


  topLeftBound: ->
    new Posn(@xRange().min, @yRange().min)


  topRightBound: ->
    new Posn(@xRange().max, @yRange().min)


  bottomRightBound: ->
    new Posn(@xRange().max, @yRange().max)


  bottomLeftBound: ->
    new Posn(@xRange().min, @yRange().max)

  bounds: ->
    xr = @xRange()
    yr = @yRange()
    new Bounds(xr.min, yr.min, xr.length(), yr.length())

  center: ->
    @bounds().center()


  parsePoints: ->
    if @data.points is ''
      return []

    points = []

    @data.points = @data.points.match(/[\d\,\. ]/gi).join('')

    @data.points.split(' ').map((coords) =>
      coords = coords.split(',')
      if coords.length == 2
        x = parseFloat(coords[0])
        y = parseFloat(coords[1])
        p = new Point(x, y, @)
        points.push p
      )

    points

  clearCachedObjects: ->

  ###
    Transformations
      rotate
      nudge
  ###

  rotate: (angle, center = @center()) ->
    @points.map (p) => p.rotate(angle, center)
    @metadata.angle += angle
    @metadata.angle %= 360

  scale: (x, y, origin = @center()) ->
    #console.log "scale polygon", x, y, origin.toString(), "#{@points}"
    @points.map (p) -> p.scale x, y, origin
    @commit()
    #console.log "scaled. #{@points}"

  nudge: (x, y) ->
    @points.map (p) -> p.nudge x, y
    @commit()

  contains: (posn) ->
    return posn.insideOf(@lineSegments())

  overlaps: (other) ->

    # Checks for overlap with another shape.
    # Redirects to appropriate method.

    # I/P: Polygon/Circle/Rect
    # O/P: true or false

    @['overlaps' + other.type.capitalize()](other)


  overlapsPolygon: (polygon) ->
    if @contains polygon.center() or polygon.contains(@center())
      return true
    for line in @lineSegments()
      if polygon.contains line.a or polygon.contains line.b
        return true
      for polyLine in polygon.lineSegments()
        if polyLine.intersects(line)
          return true
    return false


  overlapsCircle: (circle) ->

  overlapsRect: (rectangle) ->
    @overlapsPolygon(rectangle)

  convertToPath: ->
    path = new Path(
      d: "M#{@points.at(0).x},#{@points.at(0).y}"
    )
    path.eyedropper @

    old = path.points.at(0)
    for p in @points.all().slice(1)
      lt = new LineTo(p.x, p.y, path, old, false)
      path.points.push lt
      old = lt

    path.points.close()
    path


# Exactly like a polygon, but not closed

class Polyline extends Polygon

  convertToPath: ->
    path = new Path(
      d: "M#{@points.at(0).x},#{@points.at(0).y}"
    )
    path.eyedropper @

    old = path.points.at(0)
    for p in @points.all().slice(1)
      lt = new LineTo(p.x, p.y, path, old, false)
      path.points.push lt
      old = lt

    path


###

  Path

  Highest order of vector data. Lowest level of expression.

###

class Path extends Monsvg
  type: 'path'


  constructor: (@data) ->
    super @data

    if @data?.d?
      @importNewPoints(@data.d)


    @antlerPoints = new PointsList([], @)

    # Kind of a hack
    if @data?.d?.match(/z$/gi) isnt null
      @points.closed = true


  # Are we caching expensive metadata like bounds?
  caching: true


  commit: ->
    @data.d = @points.toString()
    super


  hover: ->
    if not ui.selection.elements.all.has @
      @showPoints()

    ui.unhighlightHoverTargets()

  unhover: ->
    @hidePoints()

  # A Path can have a "virgin" attribute that it will be exported as if no points
  # have been changed individually since it was assigned.
  # You would assign another SVG element as its virgin attr and that will get scaled,
  # nudged alongside the Path itself.
  # Any time a point is moved by itself and the "shape" is changed, the virgin attribute
  # is reset to false.
  virgin: undefined


  virginMode: ->
    @virgin.eyedropper @
    @$rep.replaceWith(@virgin.$rep)


  editMode: ->
    @virgin.$rep.replaceWith @$rep


  woohoo: ->
    @virgin = undefined


  importNewPoints: (points) ->
    if points instanceof PointsList
      @points = points
    else
      @points = new PointsList(points, @)

    @points = @points.absolute()

    @clearCachedObjects()

    @


  cleanUpPoints: ->
    for p in @points.all()
      p.cleanUp()
    @commit()


  appendTo: (selector, track = true) ->
    super selector, track
    @points.drawBasePoints().hide()
    @redrawHoverTargets() if track
    @


  xRange: () ->
    cached = @xRangeCached
    if cached isnt null
      return cached
    else
      @xRangeCached = new Range().fromRangeList(@lineSegments().map (x) -> x.xRange())


  xRangeCached: null


  yRange: () ->
    cached = @yRangeCached
    if cached isnt null
      return cached
    else
      @yRangeCached = new Range().fromRangeList(@lineSegments().map (x) -> x.yRange())


  yRangeCached: null


  nudgeCachedObjects: (x, y) ->
    @boundsCached?.nudge x, y
    @xRangeCached?.nudge x
    @yRangeCached?.nudge y
    @lineSegmentsCached?.map (ls) ->
      ls.nudge(x, y)


  scaleCachedObjects: (x, y, origin) ->
    @boundsCached?.scale x, y, origin
    @xRangeCached?.scale x, origin.x
    @yRangeCached?.scale y, origin.y
    @lineSegmentsCached = null
    ###
    @lineSegmentsCached.map (ls) ->
      ls.scale(x, y, origin)
    ###


  clearCachedObjects: ->
    @lineSegmentsCached = null
    @boundsCached = null
    @xRangeCached = null
    @yRangeCached = null
    @


  lineSegments: ->
    # No I/P
    #
    # O/P: A list of LineSegments and/or CubicBeziers representing this path
    cached = @lineSegmentsCached
    if cached isnt null
      return cached
    else
      segments = []
      @points.all().map (curr, ind) =>
        segments.push(lab.conversions.pathSegment curr, curr.succ)
      @lineSegmentsCached = segments

  lineSegmentsCached: null

  scale: (x, y, origin = @center()) ->
    # Keep track of cached bounds and line segments
    @scaleCachedObjects(x, y, origin)

    # We might need to rotate and unrotate this thing
    # to keep its angle true. This way we can scale at angles
    # after we rotate shapes.
    angle = @metadata.angle

    # Don't do unecessary work: only do rotation if shape has an angle other than 0
    unless angle is 0
      # Rotate the shape to normal (0 degrees) before doing the scaling.
      @rotate(360 - angle, origin)

    # After we've unrotated it, scale it
    @points.map((a) => a.scale(x, y, origin))

    unless angle is 0
      # ...and rotate it back to where it should be.
      @rotate(angle, origin)

    # Boom
    @commit()

    # Carry out on virgin rep
    @virgin?.scale(x, y, origin)


  nudge: (x, y) ->
    # Nudge dis bitch
    @points.map (p) -> p.nudge x, y, false

    # Nudge the cached bounds and line segments if they're there
    # to keep track of those.
    @nudgeCachedObjects(x, y)

    # Commit the changes to the canvas
    @commit()

    # Also nudge the virgin shape if there is one
    @virgin?.nudge(x, y)


  rotate: (a, origin = @center()) ->
    # Add to the transform angle we're keeping track of.
    @metadata.angle += a

    # Normalize it to be 0 <= n <= 360
    @metadata.angle %= 360

    # At this point the bounds are no longer valid, so ditch it.
    @clearCachedObjects()

    # Rotate all the points!
    @points.map (p) -> p.rotate a, origin

    # Commit it
    @commit()

    # Rotated rect becomes path
    @woohoo()


  fitToBounds: (bounds) ->
    @clearCachedObjects()
    mb = @bounds()
    # Make up for the difference

    myWidth = mb.width
    myHeight = mb.height

    sx = bounds.width / mb.width
    sy = bounds.height / mb.height

    sx = 1 if (isNaN sx) or (sx == Infinity) or (sx == -Infinity) or (sx == 0)
    sy = 1 if (isNaN sy) or (sy == Infinity) or (sy == -Infinity) or (sy == 0)

    sx = Math.max(1e-5, sx)
    sy = Math.max(1e-5, sy)

    @scale(sx, sy, new Posn(mb.x, mb.y))
    @nudge(bounds.x - mb.x, mb.y - bounds.y)

    debugger if @points.toString().indexOf("NaN") > -1


  overlapsRect: (rect) ->
    if @bounds().overlapsBounds(rect.bounds())
      # First, check if any of our points are inside of this rectangle.
      # This is a much cheaper operation than line segment intersections.
      # We resort to that if no points are found inside of the rect.
      for point in @points.all()
        if point.insideOf rect
          return true
      return @lineSegmentsIntersect(rect)
    else
      return false


  drawToCanvas: (context) ->
    context = @setupToCanvas(context)
    for point in @points.all()
      switch point.constructor
        when MoveTo
          context.moveTo(point.x, point.y)
        when LineTo, HorizTo, VertiTo
          context.lineTo(point.x, point.y)
        when CurveTo, SmoothTo
          context.bezierCurveTo(point.x2, point.y2, point.x3, point.y3, point.x, point.y)
    @finishToCanvas(context)

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

###

  TextEditable

  A content-editable <p> that lives in the #typography div
  Used to edit the contents of a Text object, each of which
  are tied to one of these.

###

class TextEditable

  constructor: (@owner) ->


  refresh: ->
    @$rep.text(@owner.content)
    if @owner.data['font-size']?
      @$rep.css 'font-size': float(@owner.data['font-size']) * ui.canvas.zoom + 'px'

    if @owner.data['font-family']?
      @$rep.css 'font-family': @owner.data['font-family']

    tr = @owner.transformations.get('translate')

    if @owner.rep.textContent is ''
      # $.fn.offset returns 0, 0 if the contents are empty
      resetToBlank = true
      @owner.rep.textContent = '[FILLER]'
      @$rep.text '[FILLER]'

    ownerOffset = @owner.$rep.offset()

    left = (ownerOffset.left - ui.canvas.normal.x)
    top  = (ownerOffset.top -  ui.canvas.normal.y)

    @$rep.css
      left: left.px()
      top:  top.px()
      color: @owner.data.fill

    ###
    @rep.style.textShadow = @owner.data.strokeWidth.px()
    @rep.style.webkitTextStrokeWidth = @owner.data.strokeWidth.px()
    ###

    @$rep.css

    @owner.transformations.applyAsCSS(@rep)

    # Hack
    myOffset = @$rep.offset()

    if resetToBlank
      @$rep.text ''
      @owner.rep.textContent = ''

    @$rep.css
      left: (left + ownerOffset.left - myOffset.left).px()
      top: (top + ownerOffset.top - myOffset.top).px()


  show: ->
    # We rebuild the rep every single time we want it
    # because it's inexpensive and it more reliably
    # avoids weird focus/blur issues.
    @$rep = $("""
      <div class="text" contenteditable="true"
         quarantine spellcheck="false">#{@owner.content}</div>
    """)
    @rep = @$rep[0]

    $('#typography').append @$rep

    @$rep.one 'blur', =>
      @commit()
      @owner.displayMode()

    @rep.style.display = "block"

    @refresh()

  hide: ->
    return if not @rep?
    @rep.remove()
    @rep = undefined

  focus: ->
    @$rep.focus()

  commit: ->
    oldOr = @owner.originRotated()
    @owner.setContent @$rep.text().replace(/$\s+/g, '')
    newOr = @owner.originRotated()
    @owner.nudge(oldOr.x - newOr.x, oldOr.y - newOr.y)






###



###

class Tspan extends Monsvg
  type: 'tspan'


  constructor: (@data) ->

###

  Pathfinder

  Union, subtract, intersect.

  In-progress; this is still unstable, buggy. Not available through UI yet.
  To invoke "Union", select elements and hit "U" on the keyboard.


  ###########
  #         #
  #    ###########
  #    #    #    #
  ###########    #
       #         #
       ###########


DEBUGGING = true


pathfinder =

  # Public API

  merge: (elems) ->
    @_reset()

    # First thing we want to do is clone everything, so we can
    # fuck around with the points behind the scenes.
    elemClones = elems.map (elem) -> elem.clone()

    while elemClones.length > 1
      [first, second] = [elemClones[0], elemClones[1]]
      merged = @_mergePair first, second
      # Replace the old couple of elems with the newly merged elem
      elemClones = [merged].concat(elemClones.slice(2))

    finalResult = elemClones[0]
    #elems.forEach (e) -> e.remove()
    finalResult.appendTo '#main'
    finalResult.eyedropper elems[0]


    ui.selection.elements.select finalResult


  # Private helpers

  _segments: []

  _segmentAccumulation: []

  _intersections: []

  _keep: (point) ->
    @_segmentAccumulation.push point
    #ui.annotations.clear() if DEBUGGING
    ui.annotations.drawDot point, ui.colors.black.hex, 4 if DEBUGGING
    point.flag 'kept'

  _commitCurrentSegment: ->
    return if @_segmentAccumulation.length == 0
    @_segments.push new PointsSegment(@_segmentAccumulation).ensureMoveTo()
    @_segmentAccumulation = []

  _getIntersection: (point) ->
    fil = @_intersections.filter (int) ->
      int.intersection.has (p) -> p.equal point
    if fil.length > 0
      return fil[0]

  _packageSegmentsIntoPathElement: ->
    pointsList = new PointsList([], [], @_segments)
    pathElement = new Path
      # This isn't good because we're re-parsing objects we already have
      # but importNewPoints is jank. TODO fix
      d: pointsList.toString()
      fill: new Color(0,0,0,0.4).toRGBString()
      stroke: ui.colors.black.hex

    pathElement


  _reset: ->
    @_segments = @_segmentAccumulation = @_intersections = []


  _splitAtIntersections: (elem, intersections) ->
    # Given an elem and a pre-calculated list of intersections
    # with another elem, split this elem's line segments
    # at every point at which they have an intersection

    return elem if intersections.length is 0

    workingPoints = elem.points.all()

    for ls in elem.lineSegments()

      # Intersections with this line segment
      inter = intersections.filter (int) ->
        (int.aline.equal ls) || (int.bline.equal ls)

      if inter.length > 0
        # NOTE: There may be more than one intersection since
        # a line segment may intersect with more than one other ls

        originalPoint = ls.source

        # If the next point was a SmoothTo, its p2 depends on this point's p3.
        # So let's just convert it into an independent CurveTo to maintain
        # its curve.
        if originalPoint.succ instanceof SmoothTo
          originalPoint.succ.replaceWithCurveTo()

        posns = inter.reduce (x, y) ->
          # Since intersection objects have an array
          # of one or more intersection points,
          # we need to just get all these arrays and
          # flatten them into a single array.
          x.concat y.intersection
        , []

        # TODO this is inefficient
        posns = posns.filter((p) ->
          valid = (workingPoints.filter((x) -> x.within(0.1, p)).length == 0)
          workingPoints.push p if valid
          valid
        )

        # Convert the line segment into a list of line segments
        # created by splitting it at each of the posns
        lsSplit = ls.splitAt posns

        # Go backwards to get the original points that would
        # make up these line segments; these are what we'll be replacing
        # the point that made the original line segment with.
        newListOfPoints = lsSplit.map (lx) -> lx.source

        # We know we want to keep all intersection points,
        # which in this case is all but the last (original) point.
        newListOfPoints.slice(0, newListOfPoints.length - 1)
        .forEach (p) -> p.flag 'desired'

        # Replace the original point with the new points
        elem.points.replace originalPoint, newListOfPoints
    elem


  _desiredPointsRemaining: (points) ->
    points.filter (p) -> (p.flagged('desired')) && (!(p.flagged('kept')))

  _findAndSplitIntersections: (a, b) ->
    @_intersections = lab.analysis.intersections a, b
    a = @_splitAtIntersections a, @_intersections
    b = @_splitAtIntersections b, @_intersections
    [a, b]

  _removeOverlappingAdjecentPoints: (elem) ->
    elem.points.forEach (p) ->
      if p.within(1e-5, p.succ)
        elem.points.remove(p)


  _flagDesiredPoints: (a, b) ->
    a.points.all().forEach (point) ->
      if not point.insideOf b
        point.flag 'desired'
    b.points.all().forEach (point) ->
      if not point.insideOf a
        point.flag 'desired'
    [a, b]

  _mergePair: (first, second) ->
    @_intersections = lab.analysis.intersections(first, second)

    # Manipulate both shapes such that they have new points
    # where they intersect with each other.
    [first, second] = @_findAndSplitIntersections first, second

    # Go through all the points and flag those that we don't wish to keep.
    [first, second] = @_flagDesiredPoints first, second

    # Purge the points list of MoveTos, since we're almost certainly
    # going to have a different amount/arrangement of point segments
    pointsWalking =   first.points.withoutMoveTos()
    pointsAlternate = second.points.withoutMoveTos()

    # Recursively walk through the two stacks of
    # points until we've satisfied the requirement that all
    # desired points make it into the new stack.
    @_walk pointsWalking, pointsAlternate

    result = @_packageSegmentsIntoPathElement()

    @_reset()

    result


  _walk: (pointsWalking, pointsAlternate) ->
    # _walk does most of the work.
    # It gets two bare lists of ordered points: one that we're
    # traversing and keeping points from, and one that we
    # are prepared to switch to given an intersection.
    # This is a recursive function.

    # The shape whose points we're currently traversing
    current = pointsWalking.owner

    for segment in pointsWalking.segments
      # We iterate in mini-loops within the pointSegments
      points = segment.points

      if points[0].flagged 'kept'
        # Base case; we've flipped back over to this point from an intersection,
        # so we've gone full-circle on this perimeter.
        # Close up this pointSegment (...z M....)
        # Then check if we still have more points not included,
        # with which we'll start a new pointSegment.
        @_commitCurrentSegment()

        # Returns FLATTENED ARRAY, not usable in recursion
        pointsRemainingWalking = @_desiredPointsRemaining pointsWalking
        pointsRemainingAlternate = @_desiredPointsRemaining pointsAlternate

        if (pointsRemainingWalking.length == 0) || (pointsRemainingAlternate.length == 0)
          # We're done with these sets of points
          return

        if pointsRemainingWalking.length > 0
          pointsWalking.movePointToFront(pointsRemainingWalking[0])
          return @_walk(pointsWalking, pointsAlternate)

        else if pointsRemainingAlternate.length > 0
          pointsAlternate.movePointToFront(pointsRemainingAlternate[0])
          return @_walk(pointsAlternate, pointsWalking)

      # Start iterating through the points and adding them to the
      # accumulated segment in the order they are chained together.
      for point in points

        ui.annotations.drawDot point, ui.colors.green.hex, 8 if DEBUGGING

        # Is it an intersection point that we added? If so,
        # we're toggling over to the other shape.
        intersection = @_getIntersection(point)
        if intersection

          # Find the same point on alternate element.
          otherSamePoint = pointsAlternate.filter((p) ->
            # NOTE Potential bug when exactly matching points exist
            p.equal point
          )[0]

          # We only need one of these, and there's two, so always
          # flag the other one as kept without actually keeping it
          otherSamePoint.flag 'kept'

          # Now we need to decide which direction we're going in. There are two options.

          # Moving forward
          optionA = lab.conversions.pathSegment(otherSamePoint, otherSamePoint.succ)
          # Moving backward
          optionB = lab.conversions.pathSegment(otherSamePoint.prec, otherSamePoint)

          # Now we're faced with two directions we can go in.
          # One of them will go into the current shape, and the other
          # will go the opposite way. We want to go the opposite way.
          #
          # We find out which line doesn't go into the current shape
          # by finding the one whose midpoint is not inside of it.

          if otherSamePoint.within(1e-2, otherSamePoint.succ)
            succTooClose = true

          if otherSamePoint.within(1e-2, otherSamePoint.prec)
            precTooClose = true

          if !(optionA.midPoint().insideOf(current))
            # ...then we want to move forward
            desiredPoint = otherSamePoint.succ

          else if !(optionB.midPoint().insideOf(current))
            # ...then we want to move backward, so we'll have to reverse the points.
            pointsAlternate = pointsAlternate.reverse()
            # TODO ABSTRACT
            otherSamePoint = pointsAlternate.filter((p) ->
              p.equal point
            )[0]
            # Since we're going backwards, actually take the successor here
            desiredPoint = otherSamePoint.succ

          else
            print "PANIC"

          desiredSegment = desiredPoint.segment

          # Ok now we know what point we want to go back over to
          # Get that point's segment in front
          pointsAlternate.moveSegmentToFront desiredSegment

          # ...and get the point in front
          desiredSegment.movePointToFront desiredPoint

          # Now we're ready to _walk again
          # Keep this intersection point
          @_keep point

          # Stop iterating over these points.
          # Recur on other element's points.
          return @_walk(pointsAlternate, pointsWalking)

        else

          # If it's not an intersection, just keep it and keep moving
          if point.flagged 'kept'
            break

          else
            @_keep point

      @_commitCurrentSegment()

      # If we've gotten to the end of a segment,
      # let's make sure we shouldn't loop back
      # around to the beginning of it before moving on.
      desiredPointsRemaining = @_desiredPointsRemaining(segment.points)

      if desiredPointsRemaining.length == 0
        if pointsWalking.segments.without(segment).length == 0
          # If there are no other segments, toggle
          @_walk(pointsAlternate, pointsWalking)
        else
          # If there are, go on to the next segment
          pointsWalking.segments = pointsWalking.segments.cannibalize()
          @_walk(pointsWalking, pointsAlternate)
      else
        segment.movePointToFront(desiredPointsRemaining[0])
        # Keep going with that segment in place as the first one
        @_walk(pointsWalking, pointsAlternate)

    @_commitCurrentSegment()

    # If we've iterated over all of pointsWalking's segments
    # we should check that pointsAlternate doesn't still have stuff for us,
    # so let's just flip and recur.
    @_walk(pointsAlternate, pointsWalking)



###

  File

  An SVG file representation in Mondy.
  Extends into various subclasses that are designed to
  work with different file Services.

###


class File
  constructor: (@key, @name, @path, @thumbnail, @contents) ->
    # I/P
    #   name:      Display file name
    #   path:      Display path
    #   key:       Key used to retrieve the file from its service.
    #              Different for different kinds of files (different services)
    #   thumbnail: SRC attribute for the thumbnail image representing this file.
    #   contents:  You have the option of passing in the file contents immediately.
    #              For services where the file sits on S3, or another server like Dropbox,
    #              you usually won't want to do this right away. So the file will call
    #              a GET request on its service if it's opened by the user.
    # O/P:
    #   self
    #
    # Note:
    #   200 success callbacks are more succinctly referred to as "ok"

    @


  fromService: (service) ->
    # Give it a service, and it will give you the constructor
    # for that service's file.
    switch service
      when services.local
        return (key) -> new LocalFile(key)
      when services.permalink
        return (key) -> new PermalinkFile(key)
      when services.dropbox
        return (name, path, modified) -> new DropboxFile(name, path, modified)


  use: (overwrite = no) ->
    ui.file = @
    ui.menu.refresh()

    # Get out of a permalink URL if we're on one
    if "#{window.location.pathname}#{window.location.search}" != @expectedURL()
      history.replaceState "", "", @expectedURL()
    ui.menu.items.filename.refresh()

    # Ensure it's loaded if we're gonna be using it
    if @contents?
      if overwrite
        # Load the file in
        io.parseAndAppend @contents

        if @archive?
          # Load the archive for this file
          archive.loadFromString @archive
          ui.utilities.history.deleteThumbsCached().build()
          delete @archive
        else
          # If we haven't gotten any saved archive data,
          # set up the archive for a new file.
          console.log "No saved archive found that matches the file, starting with a fresh one."
          archive.setup()

    else
      @load =>
        @use()

    @


  get: (ok, error) ->
    # Get this file at its most up-to-date state from its service
    # and run a callback on it.
    # Does not overwrite this File instance's contents.
    @service.get(@key, ok, error)
    @


  put: (ok, error) ->
    # Persist this file to its service
    @service.put(@key, @contents, ok, error)
    @


  set: (@contents = io.makeFile()) ->
    # Simply set this File's contents attribute.
    # Defaults to the current drawing.
    @


  save: (ok) ->
    # Save the current drawing to this file,
    # and persist it to its service.
    @set()
    @put(ok)
    @


  hasChanges: ->
    @contents != io.makeFile()


  toString: ->
    data =
      key: @key
      name: @name
      path: @path
      service: @service.name
    data.toString()


  expectedURL: ->
    switch @constructor
      when PermalinkFile
        "/?p=#{@key}"
      else
        "/"

  readonly: false

window.LocalFile = LocalFile
window.File      = File
class LocalFile extends File
  constructor: (@key) ->
    @service = services.local

    # A LocalFile's key is its name
    @name = @key

    # A LocalFile has no path
    @path = ""

    @displayLocation = "local storage"

    # Go ahead and get it right away
    @load()

    super @key, @name, @path, @thumbnail, @contents

    @

  load: (ok = ->) ->
    # Get the file contents
    @get (data) =>
      # Set the file contents
      @contents = data.contents
      @archive = data.archive

      # Use it as the current file!
      @use(true) if @ == ui.file
      ok(data)
    @


window.LocalFile = LocalFile
class PermalinkFile extends File
  constructor: (@key) ->
    @service = services.permalink
    @path = ""

    @displayLocation = "permalink "

    super @key, @name, @path, @thumbnail

  load: ->
    @get (data) =>
      @contents = data.contents
      @name = data.file_name
      @use() if @ == ui.file
    @

  use: (overwrite) ->
    super overwrite
    history.replaceState "", "", "/?p=#{@key}" if @contents?


class DropboxFile extends File
  constructor: (@key) ->
    @service = services.dropbox

    #@key = "#{@path}#{@name}"

    @name = @key.match(/[^\/]+$/)[0]
    @path = @key.substring(0, @key.length - @name.length)

    @displayLocation = @key

    super @key, @name, @path, @thumbnail


  load: (ok = ->) ->
    @get ((data) =>
      @contents = data.contents

      archive.get()

      @use(true) if @ == ui.file
      ok(data)
    ), ((error) =>
      @contents = io.makeFile()
      @use(true) if @ == ui.file
    )
    @

  put: (ok) ->
    archive.put()
    super ok

###

  Preload new visitors' files with a sample file

###

demoFiles =
  albq: """
        <svg id="main" width="800" height="470.59" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:mondrian="http://mondrian.io/xml" viewbox="0 0 800 470.59" enable-background="new 0 0 800 470.59" style="width: 800px; height: 470.59px; -webkit-transform: scale(1);">
          <rect opacity="1" fill="rgb(199, 15, 46)" fill-opacity="1" stroke="none" stroke-width="1" stroke-linecap="round" stroke-linejoin="miter" stroke-miterlimit="4" stroke-dasharray="none" stroke-opacity="1" id="rect3491" width="800" height="470.58984" x="0" y="0.00015633789" >
          </rect>
          <path id="path3290" fill="rgb(245, 220, 15)" fill-rule="evenodd" stroke="none" stroke-width="1px" stroke-linecap="butt" stroke-linejoin="miter" stroke-opacity="1" fill-opacity="1" d="M394.625,383.43375 C381.16854,383.95982 376.92586,396.10106 374.875,403.46875 C372.73136,411.16976 373.54029,423.67459 382,423.7775 C385.09344,423.81513 388.0005,422.0739 390.09375,420.21875 L384.875,442.21875 L393.5,442.21875 L404.4375,395.78125 C404.95468,393.59667 404.72172,391.07616 403.75,388.875 C401.94548,384.78738 398.68662,383.27496 394.625,383.43375 M393.34375,389.78125 C395.26133,389.83533 397.13959,390.74597 396.53125,393.3125 L391.25,415.59375 C379.11731,421.56397 381.42886,411.35222 383.375,402.96875 C384.35154,398.76206 386.57754,392.68705 390.3125,390.4375 C391.02749,390.00687 392.1932,389.7488 393.34375,389.78125 M421.3125,384.09 L412.75,384.09 L407.9375,404.7775 C405.17878,416.63643 409.35555,423.26919 414.875,423.7775 C418.15997,424.08003 421.54456,422.35493 423.87944,419.06596 L422.75,423.09 L431.25,423.09 L440.5625,384.09 L432,384.09 L425.44194,411.70796 C423.41424,416.12473 419.5936,418.94076 416.3125,416.465 C413.65852,414.46243 415.31018,409.25358 416.4375,404.5275 L421.3125,384.09 M516.95447,383.43375 C503.49801,383.95982 499.25533,396.10106 497.20447,403.46875 C495.06083,411.16976 495.86976,423.67459 504.32947,423.7775 C507.42291,423.81513 510.32997,422.0739 512.42322,420.21875 L507.20447,442.21875 L515.82947,442.21875 L526.76697,395.78125 C527.28415,393.59667 527.05119,391.07616 526.07947,388.875 C524.27495,384.78738 521.01609,383.27496 516.95447,383.43375 M515.67322,389.78125 C517.5908,389.83533 519.46906,390.74597 518.86072,393.3125 L513.57947,415.59375 C501.44678,421.56397 503.75833,411.35222 505.70447,402.96875 C506.68101,398.76206 508.90701,392.68705 512.64197,390.4375 C513.35696,390.00687 514.52267,389.7488 515.67322,389.78125 M545.76329,384.09 L537.20079,384.09 L532.38829,404.7775 C529.62957,416.63643 533.80634,423.26919 539.32579,423.7775 C542.61076,424.08003 545.99535,422.35493 548.33023,419.06596 L547.20079,423.09 L555.70079,423.09 L565.01329,384.09 L556.45079,384.09 L549.89273,411.70796 C547.86503,416.12473 544.04439,418.94076 540.76329,416.465 C538.10931,414.46243 539.76097,409.25358 540.88829,404.5275 L545.76329,384.09 M463.125,383.40625 C455.93939,383.74932 452.75701,386.31345 449.25,390.09375 C444.85824,394.82776 442.19997,401.01352 441.375,408.21875 C440.52947,415.60356 444.72557,423.74517 451.375,423.78125 C456.75995,423.80993 461.45192,422.15464 465.5,416.34375 L463.05676,413.12906 C461.40372,415.01424 460.23986,415.98258 458.39644,416.78384 C455.27512,418.14056 451.48107,419.23399 449.73995,415.69399 C449.17445,414.54425 449.16151,412.84294 449.3125,410.71875 C463.67766,411.06162 470.27579,400.56019 471.13756,396.15181 C472.74417,387.93325 468.44611,383.1522 463.125,383.40625 M463.5,397.46875 C461.95149,401.52548 455.46221,405.30317 449.75628,405.35447 C450.96482,396.91546 454.90118,389.33747 459.875,388.96875 C465.30667,388.56609 464.31332,395.33803 463.5,397.46875 M587.92935,383.40625 C580.74374,383.74932 577.56136,386.31345 574.05435,390.09375 C569.66259,394.82776 567.00432,401.01352 566.17935,408.21875 C565.33382,415.60356 569.52992,423.74517 576.17935,423.78125 C581.5643,423.80993 586.25627,422.15464 590.30435,416.34375 L587.86111,413.12906 C586.20807,415.01424 585.04421,415.98258 583.20079,416.78384 C580.07947,418.14056 576.28542,419.23399 574.5443,415.69399 C573.9788,414.54425 573.96586,412.84294 574.11685,410.71875 C588.48201,411.06162 595.08014,400.56019 595.94191,396.15181 C597.54852,387.93325 593.25046,383.1522 587.92935,383.40625 M588.30435,397.46875 C586.75584,401.52548 580.26656,405.30317 574.56063,405.35447 C575.76917,396.91546 579.70553,389.33747 584.67935,388.96875 C590.11102,388.56609 589.11767,395.33803 588.30435,397.46875 M354.84446,384.09 L346.28196,384.09 L341.46946,404.7775 C338.71074,416.63643 342.88751,423.26919 348.40696,423.7775 C351.69193,424.08003 355.07652,422.35493 357.4114,419.06596 L356.28196,423.09 L364.78196,423.09 L374.09446,384.09 L365.53196,384.09 L358.9739,411.70796 C356.9462,416.12473 353.12556,418.94076 349.84446,416.465 C347.19048,414.46243 348.84214,409.25358 349.96946,404.5275 L354.84446,384.09 M315.37813,423.7775 C328.83459,423.25143 333.07727,411.11019 335.12813,403.7425 C337.27177,396.04149 336.46284,383.53666 328.00313,383.43375 C324.90969,383.39612 322.00263,385.13735 319.90938,386.9925 L326.25313,360.6175 L317.62813,360.6175 L306.19063,408.055 C304.45111,415.86104 306.38136,423.3441 315.37813,423.7775 M314.09688,410.52375 L318.75313,391.6175 C330.88582,385.64728 328.57427,395.85903 326.62813,404.2425 C325.65159,408.44919 323.42559,414.5242 319.69063,416.77375 C314.56894,418.67038 312.88313,415.66403 314.09688,410.52375 M287.15663,416.63765 L300.625,360.715 L309.25,360.715 L294.375,423.09 C289.83883,422.57067 288.15033,419.55539 287.15663,416.63765 M494.4375,384.09375 C491.55707,384.26624 488.73052,385.9659 486.6875,388.84375 L487.8125,384.8125 L479.3125,384.8125 L470,423.8125 L478.5625,423.8125 L485.125,396.1875 C488.08663,390.36739 493.58787,391.43816 496.71859,393.15257 L499.90625,386.03125 C498.68568,384.92568 497.25033,384.26893 495.6875,384.125 C495.27688,384.08718 494.84899,384.06911 494.4375,384.09375 M279.34375,353.0625 C275.35785,353.05705 272.13945,354.9123 269.75,357.34375 C276.33396,354.89877 284.97578,355.42612 282.125,367.09375 L275.375,394.6875 C267.83796,396.40612 261.51167,396.33588 255.90625,394.78125 C256.435,393.02259 256.96397,391.34882 257.5,389.84375 C262.21528,376.6043 269.37175,365.06154 275.5,359.34375 C275.25117,359.31468 275.00252,359.28736 274.75,359.28125 C266.9218,359.09196 257.68856,368.03927 250.5,385.34375 C247.42153,392.75433 246.52867,401.53171 246.90625,412.0625 C246.9977,414.61292 245.96073,415.84375 242.75,415.84375 L233.8125,415.84375 C230.06115,415.84375 227.31254,418.60908 225.40625,421.6875 C224.45847,423.21805 223.15246,423.71875 221.40625,423.71875 L211.03125,423.71875 C206.57801,423.71875 202.74003,429.12391 201.59375,431.6875 L215.4375,431.71875 C218.9619,431.7267 222.90385,430.22707 223.84375,427.28125 C224.45839,425.35484 225.23385,423.84375 227.1875,423.84375 L237.25,423.84375 C246.53998,423.84375 250.83126,411.82928 254.15625,400.71875 C259.90669,403.23586 266.88029,402.82892 273.59375,401.96875 L270,416.71875 C270.94199,419.86009 274.014,423.09375 277.25,423.09375 L289.625,371.21875 C291.17932,364.70318 292.03438,357.19937 285.25,354.34375 C283.12988,353.45137 281.15552,353.06498 279.34375,353.0625 M243.78125,404.53125 C244.30746,389.04608 250.37557,371.20112 262.15257,362.43138 C242.39633,365.95552 238.5331,389.72437 243.78125,404.53125z" >
          </path>
          <path opacity="1" fill="rgb(245, 220, 15)" fill-opacity="1" fill-rule="evenodd" stroke="none" stroke-width="1px" stroke-linecap="butt" stroke-linejoin="miter" stroke-opacity="1" d="M140.80512,124.44307 C140.48954,116.8959 137.95674,109.29261 133.84446,102.14704 C145.40584,83.622779 143.15705,58.912707 127.06066,42.816361 C120.00663,35.762334 111.31952,31.366697 102.20147,29.624435 C104.88234,31.270212 107.41539,33.247368 109.73654,35.568516 C122.55956,48.391552 125.06105,67.622572 117.27168,82.966804 C109.71805,77.067306 100.88709,72.515567 91.572737,67.697681 C84.623787,64.10338 79.717594,57.217864 77.806247,40.45197 C71.216273,40.15034 66.12818,42.142295 62.316259,45.954216 C58.504317,49.766157 56.512369,54.854243 56.814014,61.444203 C73.579929,63.355529 80.465367,68.261662 84.059727,75.210691 C88.877607,84.525041 93.429347,93.356005 99.328847,100.90964 C83.984607,108.69901 64.753659,106.19759 51.930561,93.374496 C49.609412,91.053347 47.632256,88.520293 45.98648,85.839425 C47.728734,94.957482 52.124456,103.64465 59.178405,110.69861 C75.274701,126.79491 99.984907,129.04385 118.50909,117.48242 C125.65466,121.59469 133.25786,124.12744 140.80512,124.44307z" id="path3404" >
          </path>
          <path opacity="1" fill="rgb(245, 220, 15)" fill-opacity="1" stroke="none" stroke-width="11.78761100999999900" stroke-linecap="round" stroke-linejoin="miter" stroke-miterlimit="4" stroke-dasharray="none" stroke-opacity="1" d="M384.15625,22.34375 L384.15625,129.125 C381.52847,129.81543 378.98223,130.67432 376.5,131.6875 L376.5,46.03125 L364.5,46.03125 L364.5,138.1875 C358.29317,142.49038 352.89663,147.88692 348.59375,154.09375 L256.4375,154.09375 L256.4375,166.09375 L342.09375,166.09375 C341.08057,168.57598 340.22168,171.12222 339.53125,173.75 L232.75,173.75 L232.75,185.75 L337.625,185.5 C337.53694,186.85258 337.5,188.21954 337.5,189.59375 C337.5,190.96796 337.53694,192.33501 337.625,193.6875 L232.75,193.4375 L232.75,205.4375 L339.53125,205.4375 C340.22168,208.06458 341.08057,210.61248 342.09375,213.09375 L256.4375,213.09375 L256.4375,225.09375 L348.625,225.09375 C352.92561,231.28867 358.29982,236.67401 364.5,240.96875 L364.5,333.15625 L376.5,333.15625 L376.5,247.46875 C378.98223,248.48097 381.52847,249.34152 384.15625,250.03125 L384.15625,356.84375 L396.15625,356.84375 L395.90625,251.9375 C397.25883,252.02546 398.62579,252.0625 400,252.0625 C401.37421,252.0625 402.74117,252.02546 404.09375,251.9375 L403.84375,356.84375 L415.84375,356.84375 L415.84375,250.03125 C418.47153,249.34152 421.01777,248.48097 423.5,247.46875 L423.5,333.15625 L435.5,333.15625 L435.5,240.96875 C441.70018,236.67401 447.07439,231.28867 451.375,225.09375 L543.5625,225.09375 L543.5625,213.09375 L457.90625,213.09375 C458.91943,210.61248 459.77832,208.06458 460.46875,205.4375 L567.25,205.4375 L567.25,193.4375 L462.375,193.6875 C462.46306,192.33501 462.5,190.96796 462.5,189.59375 C462.5,188.21954 462.46306,186.85258 462.375,185.5 L567.25,185.75 L567.25,173.75 L460.46875,173.75 C459.77832,171.12222 458.91943,168.57598 457.90625,166.09375 L543.5625,166.09375 L543.5625,154.09375 L451.40625,154.09375 C447.10337,147.88692 441.70683,142.49038 435.5,138.1875 L435.5,46.03125 L423.5,46.03125 L423.5,131.6875 C421.01777,130.67432 418.47153,129.81543 415.84375,129.125 L415.84375,22.34375 L403.84375,22.34375 L404.09375,127.21875 C402.74117,127.13069 401.37421,127.09375 400,127.09375 C398.62579,127.09375 397.25883,127.13069 395.90625,127.21875 L396.15625,22.34375 L384.15625,22.34375 M400,139.0625 C427.94161,139.06249 450.5,161.65213 450.5,189.59375 C450.49998,217.53538 427.94162,240.09375 400,240.09375 C372.05837,240.09374 349.5,217.53538 349.5,189.59375 C349.5,161.65213 372.05838,139.0625 400,139.0625" id="path3423" >
          </path>
          <path id="path3458" fill="rgb(245, 220, 15)" fill-rule="evenodd" stroke="none" stroke-width="1px" stroke-linecap="butt" stroke-linejoin="miter" stroke-opacity="1" fill-opacity="1" d="M371.23106,205.77851 C369.29484,210.95758 371.19003,215.67896 374.7666,218.15287 C381.53891,197.75345 387.50725,184.36933 394.74236,171.83738 L376.00403,171.83738 L370.87751,180.49944 L384.48931,180.49944 C380.0699,188.19847 375.31518,194.85415 371.23106,205.77851 M404.21875,170.25 C397.53833,170.25 391.24637,178.65645 390.15625,189 C389.06613,199.34356 393.60084,207.71874 400.28125,207.71875 C406.96167,207.71875 413.25362,199.34356 414.34375,189 C415.43387,178.65644 410.89917,170.25 404.21875,170.25 M401.46875,177.84375 C405.06775,177.84375 408.34127,182.85241 408.78125,189 C409.22124,195.14759 406.66151,200.125 403.0625,200.125 C399.46349,200.125 396.18998,195.14759 395.75,189 C395.31003,182.85241 397.86974,177.84375 401.46875,177.84375 M438.125,159.96875 C428.35549,167.45602 419.05386,175.60093 417.5,188.09375 C416.47978,196.29615 419.06754,207.70302 427.25,207.71875 C431.87039,207.72763 438.82592,205.12517 441.625,189.96875 C443.62668,179.13008 438.156,171.79085 433.375,170.46875 C435.93931,167.09182 437.87506,165.38544 441,162.84375 L438.125,159.96875 M436.25,189.90625 C436.83451,197.46827 431.6068,203.1044 427.125,198.53125 C423.58711,194.92125 421.24957,186.94715 428,177.96875 C434.44668,178.06469 435.85259,184.76478 436.25,189.90625 M362.83417,206.83917 L369.3749,171.92577 L362.21545,171.92577 L356.90518,199.89321 C355.86506,205.37119 359.31092,206.83917 362.83417,206.83917z" >
          </path>
        </svg>
        """

###


  archive

  Undo/redos

  Manages a stack of Events that describe exactly how the file was put together.
  The Archive is designed to describe the calculations needed to reconstruct the file
  step by step without actually saving the results of any of those calculations.

  It merely retains the bare minimum information to carry that calculation out again.

  For example, if we nudged a certain shape, we won't be saving the old and new point values,
  which could look like a big wall of characters like "M 434.37889,527.30393 C 434.37378,524.01..."
  Instead we just say "move shape 3 over 23 pixels and up 5 pixels."

  Since that procedure is 100% reproducable we can save just that information and always be able
  to do it again.


  This design is much faster and more efficient and allows us to save the entire history for a file on
  S3 and pull it back down regardless of where and when the file is opened again.

  The trade-off is we need to have lots of different Event subclasses that do different things, and
  practically operation in the program needs to be custom-fitted to an Event call.

  Again, doing things this way instead of a simpler one-size-fits-all solution gives us more control
  over what is happening and only store the bare minimum details we need in order to offer a
  full start-to-finish file history.


  Events are serialized in an extremely minimal way. For example, here is a MapEvent that describes a nudge:

  {"t":"m:n","i":[5],"a":{"x":0,"y":-10}}

  What this is saying, in order of appearance is:
    - The type of this event is "map: nudge"
    - We're applying this event to the element at the z-index 5
    - The arguments for the nudge operation are x = 0, y = -10

  That's just an example of how aggressively minimal this system is.


  History is saved as pure JSON on S3 under this scheme:

    development: s3.amazonaws.com/mondy_archives_dev/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json
    prodution:   s3.amazonaws.com/mondy_archives/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json

  "Waboom"


###


window.archive =

  # docready setup, just start with a base-case empty fake event

  setup: ->
    @events = [{ do: (->), undo: (->), position: 0, current: true }]


  # Core UI endpoints into the archive: undo and redo

  undo: ->
    @goToEvent(@currentPosition() - 1)

  redo: ->
    @goToEvent(@currentPosition() + 1)


  # A couple more goto shortcuts

  goToEnd: ->
    @goToEvent @events.length - 1

  goToBeginning: ->
    @goToEvent 0


  eventsUpToCurrent: ->
    # Get the events with anything after the current event sliced off
    @events.slice 0, @currentPosition() + 1


  currentEvent: ->
    # Get the current event
    ce = @events.filter((e) -> e.current)
    if ce?
      return ce[0]
    else
      return null


  currentPosition: ->
    # Get the current event's position
    ce = @currentEvent()
    if ce?
      return ce.position
    else
      return -1


  # A couple boolean checks

  currentlyAtEnd: ->
    @currentPosition() is @events.length - 1

  currentlyAtBeginning: ->
    @currentPosition() is 0


  # Happens every time a new event is created, meaning every time a user does anything

  addEvent: (event) ->
    # Cut off the events after the current event
    # and push the new event to the end
    @events = @eventsUpToCurrent() if @events.length

    # Clear the thumbnails cached in the visual history utility
    ui.utilities.history.deleteThumbsCached(@currentPosition())

    # Give it the proper position number
    event.position = @events.length

    # The current event is no longer current!
    @currentEvent()?.current = false

    # We have a new king in town
    event.current = true
    @events.push event

    # Is the visual history utility open?
    # Automatically update it if it is.
    uh = ui.utilities.history
    # If it falls as an event that is included
    # given the history utility's thumb frequency,
    # add it in.
    if event.position % uh.every is 0
      uh.buildThumbs(uh.every, event.position)

  # Each Event subclass gets its own add method

  addMapEvent: (fun, elems, data) ->
    @addEvent(new MapEvent(fun, elems, data))

  addExistenceEvent: (elem) ->
    @addEvent(new ExistenceEvent(elem))

  addPointExistenceEvent: (elem, point, at) ->
    @addEvent(new PointExistenceEvent(elem, point, at))

  addAttrEvent: (indexes, attr, value) ->
    return if indexes.length == 0
    @addEvent(new AttrEvent(indexes, attr, value))

  addZIndexEvent: (indexesBefore, indexesAfter, direction) ->
    return if indexesBefore.length + indexesAfter == 0
    @addEvent(new ZIndexEvent(indexesBefore, indexesAfter, direction))


  goToEvent: (ep) ->
    # Go to a specific event and execute all the events on the way there.
    #
    # I/P:
    #   ep: event position, an int

    # Old event position, where we just were
    oep = @currentPosition()

    # Mark the previously current event as not current
    currentEvent = @currentEvent()

    if currentEvent
      currentEvent.current = false

    # Execute all the events between the old event and the new event
    # First determine which direction we're going in: backwards of forwards

    diff = Math.abs(ep - oep)

    # Upper and lower bounds - don't let ep
    # exceed what we have available in @events

    if ep > (@events.length - 1)
      # We can't go after the last event
      ep = @events.length - 1
      @events[ep].current = true

    if ep < 0
      # We can't go before the first event
      ep = 0
      @events[0].current = true

    else
      # Otherwise we're good. This should usually be the case
      @events[ep].current = true


    if ep > oep
      # Going forward, execute prereqs from old event + 1 to new event
      for position in [oep + 1 .. ep]
        @events[position]?.do()
    else if ep < oep
      # Going backward
      for position in [oep .. ep + 1]
        @events[position]?.undo()
    # Otherwise we're not moving so don't do anything

    if not @simulating
      ui.selection.refresh()

    #@saveDiffState()


  runThrough: (speed = 30, i = 0) ->
    @goToEvent(i)
    if i < @events.length
      setTimeout =>
        @runThrough(speed, i + 1)
      , speed


  diffState: ->
    diff = {}
    dom.$main.children().each (ind, shape) ->
      diff[ind] = {}
      for attr in shape.attributes
        diff[ind][attr.name] = attr.value
    diff


  saveDiffState: ->
    @lastDiffState = @diffState()
    @atMostRecentEvent = io.makeFile()


  fileAt: (ep) ->
    cp = @currentPosition()
    @goToEvent ep
    file = io.makeFile()
    @goToEvent cp
    file


  toJSON: ->
    if @events.length > 1
      return {
        f: hex_md5(io.makeFile())
        e: @events.slice(1)
        p: @currentPosition()
      }
    else
      return {}


  toString: ->
    JSON.stringify @toJSON()


  loadFromString: (saved, checkMD5 = true) ->
    # Super hackish right now, I'm tired.
    saved = JSON.parse saved

    if Object.keys(saved).length is 0
      # Return empty if we just have an empty object
      return @setup()

    if checkMD5
      if saved.f != hex_md5(ui.file.contents)
        # Return empty if the file md5 hashes don't line up,
        # meaning this history is invalid for this file
        console.log "File contents md5 mismatch"
        return @setup()

    events = saved.e
    parsedEvents = events.map (x) -> new Event().fromJSON(x)
    i = 1
    parsedEvents.map (x) ->
      x.position = i
      i += 1
    # Rebuild the initial empty event
    @setup()
    # Add in the parsed events
    @events = @events.concat parsedEvents

    # By default the 0 index event is current. Disable this
    @events[0].current = false

    # Set the correct current event
    @events[parseInt(saved.p, 10)]?.current = true

  put: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/baddeley/put"
      type: "POST"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        file_hash: hex_md5(ui.file.contents)
        archive: archive.toString()
      success: (data) ->

  get: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/baddeley/get",
      data:
        session_token: ui.account.session_token
        file_hash: hex_md5(ui.file.contents)
      dataType: "json"
      success: (data) =>
        @loadFromString(data.archive)



setup.push ->
  if not ui.file?
    archive.setup()

###


  Archive Event

  Events are amazing creatures. They are specialized objects for certain types
  of events, obviously, that happen when one is using Mondy.

  The best part about them is they are serializable as  string,
  and can be completely restored from one as well.

  That means that this is a archive system that doesn't have to die when the session dies.

  Let me repeat that: WE CAN PASS AROUND FILE HISTORIES AS BLOBS OF TEXT.
  And it's rather space-efficient as well, given its power.


  Some key concepts:

  Abstraction through mapping

    There are different types of Events. Things like nudges and rotations are stored
    as the relevant measurements as opposed to actual changes between points,
    for efficiency's sake.

    It's much easier to just say "rotate the element at zindex 3 by 12°" than,
    "Find the element with the points "M577.5621054400491,303.51924490455684 C592.3321407555776,35..."
    and update that to "M560.5835302627165,358.31402081341434 C536.5694824830614,406.6805951105095..."

  Minimal serialization

    These are not meant to be human-readable, when they are stored they use tons of one-character indicators.
    A typical rotation event looks like this:
      {"t":"m:r","i":[0],"args":{"angle":42.278225912417064,"origin":{"x":498.21488701676367,"y":308.96076780376694,"zoomLevel":1}}}

   "t" = meaning type
   "m:r" = map: rotate
   "i" = index

  For now the args are more reasonably labeled so shit doesn't get TOO confusing

  We'll see how this goes and later I might change the grammar/standard if it's worth making more efficient.




  types

    "m:" = map... MapEvent
      This one has a second argument - which method do we map? It follows the colon.

      "r" = rotate
      "n" = nudge
      "s" = scale

    "e" = ExistenceEvent

    "d" = DiffEvent



###

class Event
  constructor: () ->

  # This is true when it was the last event to happen.
  # So basically, if current == true then this is where we're at in the timeline.
  current: false

  # The index this event is at in archive.events
  position: undefined

  toString: ->
    JSON.stringify @toJSON()

  fromJSON: (json) ->
    if typeof json is "string"
      json = JSON.parse json

    switch json.t[0]
      when "m"
        # MapEvent
        # Get the fun key from the character following the colon
        funKey = {
          n: "nudge"
          s: "scale"
          r: "rotate"
        }[json.t[2]]
        indexes = json.i
        args = json.a
        return new MapEvent(funKey, indexes, args)

      when "e"
        # ExistenceEvent
        ee = new ExistenceEvent(json.a)
        ee.mode = { d: "delete", c: "create" }[json.t[2]]

        return ee

      when "p"
        # PointExistenceEvent
        point = json.p
        at = json.i
        elem = parseInt json.e, 10
        mode = { d: "delete", c: "create" }[json.t[2]]
        pe = new PointExistenceEvent(elem, point, at)
        pe.mode = mode
        return pe

      when "a"
        # AttrEvent
        new AttrEvent(json.i, json.c, json.o)

      when "z"
        new ZIndexEvent(json.ib, json.ia, json.d)




window.Event = Event

###


  MapEvent

  An efficient way to store a nudge, scale, or rotate
  of an entire shape's points


###

class MapEvent extends Event
  constructor: (@funKey, @indexes, @args) ->
    # funKey: str, which method we're mapping
    #   "nudge"
    #   "scale"
    #   "rotate"
    #
    # indexes: array OR object
    #   if we're mapping on elements, an array of zindex numbers
    #   if we're mapping on points, an object where the keys are
    #   the element's zindex and the value is an array of point indexes
    #
    # args:
    #   args given to the method we're mapping
    #
    #   for nudge ("n")
    #     x: number
    #     y: number
    #
    #   for scale ("s")
    #     x: number
    #     y: number
    #     origin: posn
    #
    #   for rotate ("r")
    #     a: number
    #     origin: posn
    #

    # Determine whether this event happens to points or elements
    # This depends on if we're given input in the
    # form of [1,2,3,4] or { 4: [1,2,3,4] }
    @operatingOn = if @indexes instanceof Array then "elems" else "points"


    switch @funKey
      # Build the private undo and do map functions
      # that will get called on each member of elements

      when "nudge"
        @_undo = (e) =>
          e.nudge(-@args.x, -@args.y, true)
        @_do = (e) =>
          e.nudge(@args.x, @args.y, true)

      when "scale"
        # Damn NaN bugs
        @args.x = Math.max @args.x, 1e-5
        @args.y = Math.max @args.y, 1e-5

        @_undo = (e) =>
          e.scale(1 / @args.x, 1 / @args.y, new Posn @args.origin)
        @_do = (e) =>
          e.scale(@args.x, @args.y, new Posn @args.origin)

      when "rotate"
        @_undo = (e) =>
          e.rotate(-@args.angle, new Posn @args.origin)
        @_do = (e) =>
          e.rotate(@args.angle, new Posn @args.origin)


  undo: () ->
    @_execute @_undo

  do: () ->
    @_execute @_do

  _execute: (method) ->
    # method
    #   _do or _undo
    #
    # Abstraction on mapping over given elements of points

    if @operatingOn is "elems"
      # Get elem at each index in @indexes
      # and run method on it
      if not archive.simulating
        ui.selection.points.deselectAll()
        ui.selection.elements.deselectAll()

      for index in @indexes
        elem = queryElemByZIndex(parseInt(index, 10))
        if not archive.simulating
          ui.selection.elements.selectMore elem
        method(elem)
        elem.redrawHoverTargets()


    else
      # Get elem for each key value and the list of point indexes for it
      # Then get the point in the elem for each point index and run the method on it
      for own index, pointIndexes of @indexes
        elem = queryElemByZIndex(parseInt(index, 10))
        if not archive.simulating
          ui.selection.elements.deselectAll()
          ui.selection.points.deselectAll()
        for pointIndex in pointIndexes
          point = elem.points.at(parseInt(pointIndex, 10))
          if @args.antler?
            switch @args.antler
              when "p2"
                if point.antlers.succp2?
                  oldAngle = point.antlers.succp2.angle360(point)
                  method(point.antlers.succp2)
                  newAngle = point.antlers.succp2.angle360(point)

                  if point.antlers.lockAngle
                    point.antlers.basep3.rotate(newAngle - oldAngle, point)

                  point.antlers.redraw() if point.antlers.visible
                else
                  console.log "wtf"

              when "p3"
                oldAngle = point.antlers.basep3.angle360(point)
                method(point.antlers.basep3)
                newAngle = point.antlers.basep3.angle360(point)

                if point.antlers.lockAngle
                  point.antlers.succp2.rotate(newAngle - oldAngle, point)

                point.antlers.redraw() if point.antlers.visible

            point.antlers.commit()
          else
            method(point)
          if not archive.simulating
            ui.selection.points.selectMore point
        elem.commit()
        elem.redrawHoverTargets()


  toJSON: ->
    # t = type, "m:" = map:
    #   "n" = nudge, "s" = scale, "r" = rotate
    # i = z-indexes of elements mapping on
    # a = args
    t: "m:#{ { nudge: "n", scale: "s", rotate: "r" }[@funKey] }"
    i: @indexes
    a: @args

###

  AttrEvent

  Set the values of various attributes of various elements.
  Very flexible.

###


class AttrEvent extends Event
  constructor: (@indexes, @changes, @oldValues) ->
    # indexes: array of ints
    #          OR, when recreated from a serialized copy,
    # changes: an object where the keys
    #          are attrs and values are the values

    # If we were just given a single int as an index for
    # a single element, just put that into an array
    if typeof @indexes is "number"
      @indexes = [@indexes]

    # If we are just given a single attribute
    # just do the same thing as above.
    if typeof @changes is "string"
      @changes = [@changes]

    # So here's the deal. We can give this event lots of different inputs.
    # CASE 1: We can give it an array of attribute names.
    #
    #   ["fill", "stroke"]
    #
    # In this case it will set all of the elements to the same value:
    # the value held by the element at indexes[0].
    #
    # CASE 2: We can also give it an object of attributes and values.
    #
    #   {
    #     fill: "#FF0000"
    #     stroke: "#000000"
    #   }
    #
    # In this case it will assume nothing and use those values.
    #
    # CASE 3: We can also give it an object of objects of attributes and values.
    # The outer-most object is the indexes.
    #
    #   {
    #     2: {
    #       fill: "#CC00FF"
    #       stroke: "#000000"
    #     }
    #     6: {
    #       fill: "#DD0077"
    #       stroke: "#FFFFFF"
    #     }
    #   }
    #
    # In this case, we are actually assigning different values to different
    # elements. It's the ultimate level of micromanagement that we can do.
    #
    # When we serialize this, we keep changes in the form expected
    # for either CASE 2 or CASE 3. If we originally got CASE 1, we
    # will be saving it as CASE 2.

    createOldValues = (not @oldValues?)

    # This object stores the old values for the undo
    if createOldValues
      @oldValues = {}

    # Helper variable - just an array of the attr names we're changing
    # (to be defined). Ignored in CASE 3
    @attrs = []

    # This is true if we're in CASE 3. We will set this to true if
    # we detect that a few blocks down
    @microManMode = false

    if @changes instanceof Array
      # Array of attribute names. CASE 1.
      @attrs = @changes
      @changes = {}

      firstElem = queryElemByZIndex(@indexes[0])
      # Sample the first elem for the assumed values
      for attr in @attrs
        @changes[attr] = firstElem.data[attr].toString()

      if createOldValues
        # Save the old values for each of the elements for each of
        # the attrs we've defined
        for i in @indexes
          elem = queryElemByZIndex i
          @oldValues[i] = {}
          for attr in @attrs
            @oldValues[i][attr] = elem.dataArchived[attr].toString()
            elem.updateDataArchived(attr)

    else if typeof @changes is "object"
      # Now we have to distinguish between CASEs 2 and 3

      keys = Object.keys @changes
      numKeys = keys.filter (k) -> /\d+/gi.test(k)
      if keys.length is numKeys.length
        # Oh shit! All the keys are digits, so this is CASE 3, where we
        # are assigning different values to different elements!
        @microManMode = true

        if createOldValues
          # Since each element has its own attr/value object we don't
          # care about setting attrs anymore.
          for i in @indexes
            elem = queryElemByZIndex(i)
            @oldValues[i] = {}
            for own attr, _ of @changes[i]
              @oldValues[i][attr] = elem.dataArchived[attr].toString()
              elem.updateDataArchived(attr)

      else
        # Simply a key of attributes and values. CASE 2.

        # The attrs are the keys of @changes, so set that.
        @attrs = Object.keys(@changes)

        if createOldValues
          for i in @indexes
            elem = queryElemByZIndex(i)
            @oldValues[i] = {}
            for attr in @attrs
              @oldValues[i][attr] = elem.dataArchived[attr].toString()
              elem.updateDataArchived(attr)



  do: ->
    @applyValues @changes, @microManMode

  undo: ->
    @applyValues @oldValues, true

  applyValues: (from, elemSpecific) ->
    # An abstraction for do/undo. Sets the values from the object given.
    #
    # A note on elemSpecific:
    # This is always true when we are undoing, because this event always stores old
    # values seperately for each element. (If you change a blue and red circle both to be green,
    # you need to set each one back to blue or red individually)
    #
    # So @undo always calls this as true, because the input is a z-index -> attr -> value object
    # as opposed to just an attr -> value object like we have when this event is not called
    # with CASE 3 input. (See above)
    #
    # This is a bit confusing but it's effective.
    for i in @indexes
      elem = queryElemByZIndex(parseInt i, 10)

      if elemSpecific
        for own attr, val of from[i]
          elem["set#{attr.camelCase().capitalize()}"](val)
      else
        for attr in @attrs
          elem["set#{attr.camelCase().capitalize()}"](from[attr])

      elem.commit()


  toJSON: ->
    t: "a"
    i: @indexes
    c: @changes
    o: @oldValues

###

  Z-Index event

  Shift elements up or down in the z-axis

###



class ZIndexEvent extends Event
  constructor: (@indexesBefore, @indexesAfter, @direction) ->

    mf = (e) -> e.moveForward()
    mb = (e) -> e.moveBack()
    mff = (e) -> e.bringToFront()
    mbb = (e) -> e.sendToBack()

    console.log @direction

    switch @direction
      when "mf"
        @_do = mf
        @_undo = mb
      when "mb"
        @_do = mb
        @_undo = mf
      when "mff"
        @_do = mff
        @_undo = mbb
      when "mbb"
        @_do = mbb
        @_undo = mff

  do: ->
    for index in @indexesBefore
      @_do(queryElemByZIndex(index))
    ui.elements.sortByZIndex()

  undo: ->
    for index in @indexesAfter
      @_undo(queryElemByZIndex(index))
    ui.elements.sortByZIndex()

  toJSON: ->
    t: "z"
    ib: @indexesBefore
    ia: @indexesAfter
    d: @direction


###

  ExistenceEvent

  Created when a new element is created, or an element is deleted.
  Create and deletes elements in either direction for do/undo.
  Capable of handling many elements in one event.

###

class ExistenceEvent extends Event
  constructor: (elem) ->
    # Given elem, which can be either
    #
    #   int or array of ints:
    #     we're deleting the elem(s) at the z-index(s)
    #
    #   an SVG element or array of SVG elements:
    #     we're creating the element(s) at the highest z-index
    #     IN THE ORDER IN WHICH THEY APPEAR
    #
    # IMPORTANT: This should be called AFTER the element has actually been created


    # What we want to end up with is an object that looks like this:
    # {
    #   4: "<path d=\"....\"></path>"
    #   7: "<ellipse cx=\"...\"></ellipse>"
    # }
    #
    # And we need to save a @mode ("create" or "delete") that says which should
    # happen on DO. The opposite happens on UNDO. They are opposites after all.

    @args = {}

    if (elem instanceof Object) and not (elem instanceof Array)
      # If it's an object, it might just be a set of args
      # from a serialized copy of this event, so let's check
      # if it is.
      keys = Object.keys(elem)
      numberKeys = keys.filter (k) -> k.match(/^[\d]*$/gi) isnt null
      if keys.length is numberKeys.length
        # All the keys are just strings of digits,
        # so this is a previously serialized version of this event.
        @args = elem
        return @

    # Check if elem is a number
    if typeof elem is "number"
      # Get the element at that z-index. We're deleting it.
      e = queryElemByZIndex(elem)?.repToString()
      if e?
        @args[elem] = @cleanUpStringElem e
        @mode = "delete"
      else
        ui.selection.elements.all.map (e) -> e.delete()
        return

    else if not (elem instanceof Array)
      # Must be a string or DOM element now

      # If it's a DOM element, serialize it to a string
      if isSVGElement elem
        elem = new XMLSerializer().serializeToString elem

      # We're creating it, at the newest z-index.
      # Since we're just creating one this is simple.
      @args[ui.elements.length - 1] = @cleanUpStringElem elem
      @mode = "create"

    # Otherwise it must be an array, so do the same thing as above but with for-loops
    else
      # All the same checks
      if typeof elem[0] is "number"
        # Add many zindexes and query the element at that index every time
        for ind in elem
          e = queryElemByZIndex(elem)?.repToString()
          if e?
            @args[ind] = @cleanUpStringElem e
            @mode = "delete"
          else
            ui.selection.elements.all.map (e) -> e.delete()
            return

        @mode = "delete"

      else
        # Must be strings or DOM elements now

        # If it's DOM elements, turn them all into strings
        if isSVGElement elem[0]
          onCanvasAlready = !!elem[0].parentNode
          serializer = new XMLSerializer()
          elem = elem.map (e) -> serializer.serializeToString e

        # Increment new z-indexes starting at the first available one
        # Add the elements to args in the order in which they appear,
        # under the incrementing z-indexes

        # If they're already on the canvas
        newIndex = ui.elements.length

        if onCanvasAlready
          newIndex -= elem.length

        for e in elem
          @args[newIndex] = @cleanUpStringElem e
          ++ newIndex
        @mode = "create"


  cleanUpStringElem: (s) ->
    # Get rid of that shit we don't like
    s = s.replace(/uuid\=\"\w*\"/gi, "")
    s


  draw: ->
    # For each element in args, parse it and append it
    for own index, elem of @args
      index = parseInt index, 10
      parsed = io.parseElement($(elem))
      parsed.appendTo("#main")
      if not archive.simulating
        ui.selection.elements.deselectAll()
        ui.selection.elements.select [parsed]
      zi = parsed.zIndex()
      # Then adjust its z-index
      if zi isnt index
        if zi > index
          for i in [1..(zi - index)]
            parsed.moveBack()
        else if zi < index
          # This should never happen but why not
          for i in [1..(index - zi)]
            parsed.moveForward()

  delete: ->
    # Build an object of which elements we want to delete before
    # we start deleting them,
    # because this fucks with the z-indexes
    plan = {}
    for own index, elem of @args
      index = parseInt index, 10
      plan[index] = queryElemByZIndex(index)

    for elem in objectValues plan
      elem.delete()

    if not archive.simulating
      ui.selection.elements.validate()

  undo: ->
    if @mode is "delete" then @draw() else @delete()

  do: ->
    if @mode is "delete" then @delete() else @draw()

  toJSON: ->
    # t = type, "e:" = existence:
    #   "d" = delete, "c" = create
    # i = z-index to create or delete at
    # e = elem data
    t: "e:#{ { "delete": "d", "create": "c" }[@mode] }"
    a: @args



###

  PointExistenceEvent

###

class PointExistenceEvent extends Event
  constructor: (@ei, @point, at) ->
    # Given an elem's z-index and a point (index or value) this
    # acts just like the ExistenceEvent.
    #
    # elem: int - z-index of elem being affected
    #
    # point: int (for deletion) or string (for creation)
    #        The point we are changing.

    elem = @getElem()

    if typeof @point is "number"
      # Deleting the point
      @mode = "remove"
      @point = elem.points.at @point
      @pointIndex = @point

    else
      @mode = "create"

      if typeof @point is "string"
        # Adding the point
        @point = new Point(@point)

      if at?
        @pointIndex = at
      else
        @pointIndex = elem.points.all().length - 1

  do: ->
    if @mode is "remove" then @remove() else @add()

  undo: ->
    if @mode is "remove" then @add() else @remove()

  getElem: -> queryElemByZIndex @ei

  add: ->
    # Clone the point so our copy of the point can never be edited in the UI
    clonedPoint = @point.clone()

    elem = @getElem()
    elem.hidePoints()
    # Push it into the points linked list
    elem.points.push clonedPoint

    # If this point's coordinates are the same as the elem's first point's
    # but it's not actually the same point object
    if (clonedPoint.equal elem.points.first) and not (clonedPoint == elem.points.first)
      #
      elem.points.close()
    elem.commit()
    clonedPoint.draw()
    if not archive.simulating
      ui.selection.elements.deselectAll()
      ui.selection.points.select clonedPoint
    @getElem().redrawHoverTargets()

  remove: ->
    elem = @getElem()
    elem.points.remove @pointIndex

    # Show the most recent point
    elem.hidePoints()
    if not archive.simulating
      ui.selection.elements.deselectAll()
      ui.selection.points.select elem.points.last
    elem.commit()

  toJSON: ->
    t: "p:#{ { "remove": "d", "create": "c" }[@mode] }"
    e: @ei
    p: @point.toString()
    i: @pointIndex





###

  Commonly accessed DOM elements

###

dom =

  setup: ->
    @$body = $('body')
    @body = @$body[0]

    @$main = $('#main')
    @main = @$main[0]

    @$ui = $('#ui')
    @ui = @$ui[0]

    @$bg = $('#bg')
    @bg = @$bg[0]

    @$annotations = $('#annotations')
    @annotations = @$annotations[0]

    @$hoverTargets = $('#hover-targets')
    @hoverTargets = @$hoverTargets[0]

    @$grid = $('#grid')
    @grid = @$grid[0]

    @$utilities = $('#utilities')
    @utilities = @$utilities[0]

    @$selectionBox = $('#selection-box')
    @selectionBox = @$selectionBox[0]

    @$dragSelection = $('#drag-selection')
    @dragSelection = @$dragSelection[0]

    @$menuBar = $('#menu-bar')
    @menuBar = @$menuBar[0]

    @$currentSwatches = $('#current-swatches')
    @currentSwatches = @$currentSwatches[0]

    @$toolPalette = $('#tool-palette')
    @toolPalette = @$toolPalette[0]

    @$toolCursorPlaceholder = $('#tool-cursor-placeholder')
    @toolCursorPlaceholder = @$toolCursorPlaceholder[0]

    @$canvas = $('#canvas')
    @canvas = @$canvas[0]

    @$logoLeft = $("#logo #left-bar")
    @$logoMiddle = $("#logo #middle-bar")
    @$logoRight = $("#logo #right-bar")
    @logoLeft = @$logoLeft[0]
    @logoMiddle = @$logoMiddle[0]
    @logoRight = @$logoRight[0]

    @$filename = $("#filename-menu")
    @filename = @$filename[0]

    @$login = $("#login-mg")
    @login = @$login[0]

    @$tmpPaste = $('#tmp-paste')
    @tmpPaste = @$tmpPaste[0]

    @$pngSandbox = $('#png-download-sandbox')
    @pngSandbox = @$pngSandbox[0]

    @$currentService = $('#current-service')
    @currentService = @$currentService[0]

    @$serviceLogo = $('.service-logo')
    @serviceLogo = @$serviceLogo[0]

    @$serviceGallery = $('#service-file-gallery')
    @serviceGallery = @$serviceGallery[0]

    @$serviceGalleryThumbs = $('#service-file-gallery-thumbnails')
    @serviceGalleryThumbs = @$serviceGalleryThumbs[0]

    @$serviceBrowser = $('#service-file-browser')
    @serviceBrowser = @$serviceBrowser[0]

    @$registerButton = $('#register-mg')
    @registerButton = @$registerButton[0]

    @$dialogTitle = $("#dialog-title")
    @dialogTitle = @$dialogTitle[0]

setup.push -> dom.setup()
###

  UI handling

  Handles
    - Mouse event routing
    - UI state memory
  Core UI functions and interface for all events used by the tools.


###


window.ui =
  # This is the highest level of UI in Mondy.
  # It contains lots of more specific objects and dispatches events to tools
  # as appropriate. It also handles tool switching.
  #
  # It has many child objects with more specific functions, like hotkeys and cursor (tracking)

  setup: ->
    # Default settings for a new Mondrian session.

    @uistate = new UIState()
    @uistate.restore()

    # This means the user switched tabs and came back.
    # Now we have no idea where the cursor is,
    # so don't even try showing the placeholder if it's up.
    ui.window.on 'focus', =>
      dom.$toolCursorPlaceholder.hide()

    # Make sure the window isn't somehow scrolled. This will hide all the UI, happens very rarely.
    window.scrollTo 0, 0

    # Base case for tool switching.
    #@lastTool = tools.cursor

    # Set the default fill and stroke colors in case none are stored in localStorage
    @fill = new Swatch("5fcda7").appendTo("#fill-color")
    @stroke = new Swatch("000000").appendTo("#stroke-color")

    @fill.type = "fill"
    @stroke.type = "stroke"

    # The default UI config is the draw config obviously!
    @changeTo "draw"

    @selection.elements.on 'change', =>
      @refreshUtilities()
      @transformer.refresh()
      @utilities.transform.refresh()


  clear: ->
    $("#ui .point.handle").remove()


  # UI state management
  # TODO Abstract into its own class

  importState: (state) ->
    # Given an object of certain attributes,
    # configure the UI to match that state.
    # Keys to give:
    #   fill:        hex string of color
    #   stroke:      hex string of color
    #   strokeWidth: number
    #   normal:      posn.toString()
    #   zoomLevel:   number

    @fill.absorb new Color state.fill
    @stroke.absorb new Color state.stroke

    @canvas.setZoom parseFloat state.zoom
    @refreshAfterZoom()

    @canvas.normal = new Posn(state.normal)
    @canvas.refreshPosition()

    if state.tool?
      secondRoundSetup.push =>
        @switchToTool(objectValues(tools).filter((t) -> t.id is state.tool)[0])
    else
      secondRoundSetup.push =>
        @switchToTool(tools.cursor) # Noobz



  new: (width, height, normal = @canvas.normal, zoom = @canvas.zoom) ->
    # Set up the UI for a new file. Give two dimensions.
    # TODO Add a user interface for specifying file dimensions
    @canvas.width = width
    @canvas.height = height
    @canvas.zoom = zoom
    @canvas.normal = normal
    @canvas.redraw()
    @canvas.zoom100()
    @deleteAll()


  configurations:
    # A configuration is defined as an function that returns an object.
    # The object needs to have a "show" attribute which is an array
    # of elements to show when we choose that UI configuration.
    # Before this is done, the previous configuration's "show"
    # elements are hidden. This lets us toggle easily between UI modes, like
    # going from draw mode to save mode for example.
    #
    # A configuration can also have an "etc" function which will just run
    # with no parameters when the configuration is selected.
    draw: ->
      show:
        [dom.$canvas
        dom.$toolPalette
        dom.$menuBar
        dom.$filename
        dom.$currentSwatches
        dom.$utilities]
    gallery: ->
      show:
        [dom.$currentService
        dom.$serviceGallery]
    browser: ->
      show:
        [dom.$currentService
        dom.$serviceBrowser]


  changeTo: (config) ->
    # Hide the old config
    @currentConfig?.show.map (e) -> e.hide()

    # When we switch contexts we want to get hotkeys back immediately,
    # becuase it's pretty much guaranteed that whatever
    # might have disabled them before is now gone.
    @hotkeys.enable().reset()

    if "config" is "draw"
      @refreshUtilities()
    else
      for util in @utilities
        util.hide()

    @currentConfig = @configurations[config]?()
    if @currentConfig?
      @currentConfig.show.map (e) -> e.show()
      @currentConfig.etc?()

      # Set the title if we want one.
      if @currentConfig.title?
        dom.$dialogTitle.show().text(@currentConfig.title)
      else
        dom.$dialogTitle.hide()

    @menu.closeAllDropdowns()

    @

  refreshAfterZoom: ->
    for elem in @elements
      elem.refreshUI()
    @selection.points.show()
    @grid.refreshRadii()


  # Tool switching/management

  switchToTool: (tool) ->
    return if tool is @uistate.get('tool')

    @uistate.get('tool')?.tearDown()
    @uistate.set 'tool', tool

    dom.$toolCursorPlaceholder?.hide()
    dom.$body?.off('mousemove.tool-placeholder')
    dom.body?.setAttribute 'tool', tool.cssid

    tool.setup()

    if tool isnt tools.paw
      # All tools except paw (panning; space-bar) have a button
      # in the UI. Update those buttons unless we're just temporarily
      # activating the paw.
      q(".tool-button[selected]")?.removeAttribute('selected')
      q("##{tool.id}-btn")?.setAttribute('selected', '')

      # A hack, somewhat. Changing the document cursor offset in the CSS
      # fires a mousemove so if we're changing to a tool with a different
      # action point then it's gonna disappear. But the mousemove event object
      # has an offsetX, offsetY attribute pair which will match the tool's
      # own offsetX and offsetY, so we just take the first event where those
      # don't match and hide the placeholder.
      dom.$body.on('mousemove.tool-placeholder', (e) =>
        if (e.offsetX != tool.offsetX) or (e.offsetY != tool.offsetY)
          dom.$toolCursorPlaceholder.hide()
          dom.$body.off('mousemove.tool-placeholder'))

    @refreshUtilities()

    return if @cursor.currentPosn is undefined

    dom.$toolCursorPlaceholder
      .show()
      .attr('tool', tool.cssid)
      .css
        left: @cursor.currentPosn.x - tool.offsetX
        top:  @cursor.currentPosn.y - tool.offsetY


  switchToLastTool: ->
    @switchToTool @uistate.get 'lastTool'


  # Event proxies for tools

  hover: (e, target) ->
    e.target = target
    @uistate.get('tool').dispatch(e, "hover")
    topUI = isOnTopUI(target)
    if topUI
      switch topUI
        when "menu"
          menus = objectValues(@menu.menus)
          # If there's a menu that's open right now
          if menus.filter((menu) -> menu.dropdownOpen).length > 0
            # Get the right menu
            menu = menus.filter((menu) -> menu.itemid is target.id)[0]
            menu.openDropdown() if menu?

  unhover: (e, target) ->
    e.target = target
    @uistate.get('tool').dispatch(e, "unhover")

  click: (e, target) ->
    # Certain targets we ignore.
    if (target.nodeName.toLowerCase() is "emph") or (target.hasAttribute("buttontext"))
      t = $(target).closest(".menu-item")[0]
      if not t?
        t = $(target).closest(".menu")[0]
      target = t

    topUI = isOnTopUI(target)

    if topUI
      # Constrain UI to left clicks only.
      return if e.which isnt 1

      switch topUI
        when "menu"
          @menu.menu(target.id)?._click(e)

        when "menu-item"
          @menu.item(target.id)?._click(e)

        else
          @topUI.dispatch(e, "click")
    else
      if e.which is 1
        @uistate.get('tool').dispatch(e, "click")
      else if e.which is 3
        @uistate.get('tool').dispatch(e, "rightClick")

  doubleclick: (e, target) ->
    @uistate.get('tool').dispatch(e, "doubleclick")

  mousemove: (e) ->
    # Paw tool specific shit. Sort of hackish. TODO find a better spot for this.
    topUI = isOnTopUI(e.target)
    if topUI
      @topUI.dispatch(e, "mousemove")
    if @uistate.get('tool') is tools.paw
      dom.$toolCursorPlaceholder.css
        left: e.clientX - 8
        top: e.clientY - 8

  mousedown: (e) ->
    if not isOnTopUI(e.target)
      @menu.closeAllDropdowns()
      @refreshUtilities()
      @uistate.get('tool').dispatch(e, "mousedown")

  mouseup: (e) ->
    topUI = isOnTopUI(e.target)
    if topUI
      @topUI.dispatch(e, "mouseup")
    else
      e.stopPropagation()
      @uistate.get('tool').dispatch(e, "mouseup")

  startDrag: (e) ->
    topUI = isOnTopUI(e.target)
    if topUI
      @topUI.dispatch(e, "startDrag")
    else
      @uistate.get('tool').initialDragPosn = new Posn e
      @uistate.get('tool').dispatch(e, "startDrag")

      for key in @hotkeys.modifiersDown
        @uistate.get('tool').activateModifier(key)

  continueDrag: (e, target) ->
    e.target = target
    topUI = isOnTopUI(target)
    if topUI
      @topUI.dispatch(e, "continueDrag")
    else
      @uistate.get('tool').dispatch(e, "continueDrag")

  stopDrag: (e, target) ->
    document.onselectstart = -> true

    releaseTarget = e.target
    e.target = target
    topUI = isOnTopUI(e.target)

    if topUI
      if (target.nodeName.toLowerCase() is "emph") or (target.hasAttribute("buttontext"))
        target = target.parentNode

      switch topUI
        when "menu"
          if releaseTarget is target
            @menu.menu(target.id)?._click(e)
        when "menu-item"
          if releaseTarget is target
            @menu.item(target.id)?._click(e)

        else
          @topUI.dispatch(e, "stopDrag")
    else
      @uistate.get('tool').dispatch(e, "stopDrag")
      @uistate.get('tool').initialDragPosn = null
      @snap.toNothing()


  # Colorz

  fill: null

  stroke: null

  # The elements on the board
  elements: [] # Elements on the board

  queryElement: (svgelem) ->
    # I/P: an SVG element in the DOM
    # O/P: its respective Monsvg object
    for elem in @elements
      if elem.rep is svgelem
        return elem


  # TODO Abstract
  hoverTargetsHighlighted: []

  # TODO Abstract
  unhighlightHoverTargets: ->
    for hoverTarget in @hoverTargetsHighlighted
      hoverTarget.unhighlight()
    @hoverTargetsHighlighted = []


  refreshUtilities: ->
    return if not appLoaded
    for own key, utility of @utilities
      if not utility.shouldBeOpen()
        utility.hide()
      else
        utility.show()


  deleteAll: ->
    for elem in @elements
      elem.delete()
    @elements = []
    dom.main.removeChildren()
    @selection.refresh()


  # Common colors
  colors:
    transparent: new Color(0,0,0,0)
    white:  new Color(255, 255, 255)
    black:  new Color(0, 0, 0)
    red:    new Color(255, 0, 0)
    yellow: new Color(255, 255, 0)
    green:  new Color(0, 255, 0)
    teal:   new Color(0, 255, 255)
    blue:   new Color(0, 0, 255)
    pink:   new Color(255, 0, 255)
    null:   new Color(null, null, null)
    # Logo colors
    logoRed:    new Color "#E03F4A"
    logoYellow: new Color "#F1CF2E"
    logoBlue:   new Color "#3FB2E0"


setup.push -> ui.setup()
###

  Animated Mondy logo for indicating progress

###

ui.logo =
  animate: ->
    @_animateRequests += 1

    if @_animateRequests is 1
      clearInterval(@animateLogoInterval)
      @animateLogoInterval = setInterval =>
        if @_animateRequests == 0
          @_reset()
        else
          vals = [ui.colors.logoRed, ui.colors.logoYellow, ui.colors.logoBlue]
          a = parseInt(Math.random() * 3)
          dom.$logoLeft.css("background-color", vals[a])
          vals = vals.slice(0, a).concat(vals.slice(a + 1))
          a = parseInt(Math.random() * 2)
          dom.$logoMiddle.css("background-color", vals[a])
          vals = vals.slice(0, a).concat(vals.slice(a + 1))
          dom.$logoRight.css("background-color", vals[0])
      , 170

  stopAnimating: ->
    @_animateRequests -= 1

    if @_animateRequests < 0
      @_animateRequests = 0

  _animateRequests: 0

  _reset: ->
    clearInterval(@animateLogoInterval)
    dom.$logoLeft.css("background-color", ui.colors.logoRed)
    dom.$logoMiddle.css("background-color", ui.colors.logoYellow)
    dom.$logoRight.css("background-color", ui.colors.logoBlue)
###

  JSON Serializable UI State

###



class UIState
  constructor: (@attributes = @DEFAULTS()) ->
    @on 'change', =>
      @saveLocally()

  restore: ->
    # Restore the previous state in localStorage if it exists
    storedState = localStorage.getItem 'uistate'
    @importJSON(JSON.parse storedState) if storedState?
    @

  set: (key, val) ->
    # Prevent echo loops and pointless change callbacks
    return if @attributes[key] == val
    switch key
      when 'tool'
        @attributes.lastTool = @attributes.tool
        @attributes.tool = val
      else
        @attributes[key] = val

    @trigger 'change', key, val
    @trigger "change:#{key}", val

  get: (key) ->
    @attributes[key]

  saveLocally: ->
    localStorage.setItem('uistate', @toJSON())

  apply: ->
    ui.fill.absorb @get 'fill'
    ui.stroke.absorb @get 'stroke'

  toJSON: ->
    fill:        @attributes.fill.hex
    stroke:      @attributes.stroke.hex
    strokeWidth: @attributes.strokeWidth
    zoom:        @attributes.zoom
    normal:      @attributes.normal.toJSON()
    tool:        @attributes.tool.id
    lastTool:    @attributes.lastTool.id

  importJSON: (attributes) ->
    @attributes =
      fill:        new Color attributes.fill
      stroke:      new Color attributes.stroke
      strokeWidth: attributes.strokeWidth
      zoom:        attributes.zoom
      normal:      Posn.fromJSON(attributes.normal)
      tool:        tools[attributes.tool]
      lastTool:    tools[attributes.lastTool]
    @trigger 'change'

  DEFAULTS: ->
    # These are "pre-parsed"; we don't bother
    # storing this in JSON
    fill:        new Color "#5fcda7"
    stroke:      new Color "#000000"
    strokeWidth: 1.0
    zoom:        1.0
    normal:      new Posn -1, -1
    tool:        tools.cursor
    lastTool:    tools.cursor

$.extend UIState::, mixins.events

window.UIState = UIState
###

  Manages elements being selected

  API:

  All selected elements:
  ui.selection.elements.all

  All selected points:
  ui.selection.points.all

  Both ui.selection.elements and ui.selection.points
  have the following methods:

  select(elems)
  selectMore(elems)
  selectAll
  deselect(elems)
  deselectAll

###

ui.selection =

  elements:

    all: []
      # Selected elements


    clone: -> @all.map (elem) -> elem.clone()


    empty: -> @all.length == 0


    exists: -> not @empty()


    select: (elems) ->
      # I/P: elem or list of elems
      # Select only elems

      ui.selection.points.deselectAll()

      if elems instanceof Array
        @all = elems
      else
        @all = [elems]

      @trigger 'change'


    selectMore: (elems) ->
      # I/P: elem, or list of elems
      # Adds elem(s) to the selection

      ui.selection.points.deselectAll()

      if elems instanceof Array
        for elem in elems
          @all.ensure elem
      else
        @all.ensure elems

      @trigger 'change'


    selectAll: ->
      # No I/O
      # Select all elements

      ui.selection.points.deselectAll()

      @all = ui.elements
      @trigger 'change'


    selectWithinBounds: (bounds) ->
      # I/P: Bounds
      # Select all elements within given Bounds

      ui.selection.points.deselectAll()

      rect = bounds.toRect()
      @all = ui.elements.filter (elem) ->
        elem.overlaps rect
      @trigger 'change'


    deselect: (elems) ->
      # I/P: elem or list of elems
      # Deselect given elem(s)

      @all.remove elems
      @trigger 'change'


    deselectAll: ->
      # No I/O
      # Deselects all elements

      return if @all.length is 0

      @all = []
      @trigger 'change'


    each: (func) ->
      @all.forEach func


    map: (func) ->
      @all.map func


    filter: (func) ->
      @all.filter func


    zIndexes: ->
      # O/P: a list of the z-indexes of the selected elements
      # ex:  [2, 5, 7]

      (e.zIndex() for e in @all)


    ofType: (type) ->
      # I/P: string of element's nodename
      # ex:  'path'

      # O/P: a list of the selected elements of a certain type
      # ex:  [Path, Path, Path]

      @filter (e) -> e.type is type


    validate: ->
      # No I/O
      # Make sure every selected elem exists in the UI

      @all = @filter (elem) ->
        ui.elements.has elem
      @trigger 'change'


    # Exporting

    export: (opts) ->
      return "" if @empty()

      opts = $.extend(
        trim: false
      , opts)

      svg = new SVG(@clone())

      if opts.trim
        svg.trim()

      svg.toString()


    exportAsDataURI: ->
      "data:image/svg+xml;base64,#{btoa @export()}"


    exportAsPNG: (opts) ->
      new PNG @export(opts)

    asDataURI: ->

  points:

    all: []
      # Selected points


    empty: -> @all.length == 0


    exists: -> not @empty()


    select: (points) ->
      # I/P: Point or list of Points
      # Selects points, deslects any previously selected points

      ui.selection.elements.deselectAll()

      if points instanceof Array
        @all = points
      else
        @all = [points]

      @all.forEach (p) -> p.select()

      @trigger 'change'

    selectMore: (points) ->
      # I/P: Point or list of Points
      # Selects points

      ui.selection.elements.deselectAll()

      if points instanceof Array
        points.forEach (point) =>
          @all.ensure point
          point.select()
      else
        @all.ensure points
        points.select()


      @trigger 'change'


    deselect: (points) ->
      points.forEach (point) ->
        point.deselect()
      @all.remove points
      @trigger 'change'

    deselectAll: ->
      return if @all.length is 0

      @all.forEach (point) ->
        point.deselect()
      @all = []

      @trigger 'change'

    zIndexes: ->
      # O/P: Object where keys are elem zIndexes
      #      and values are lists of point indexes
      # ex: { 3: [5, 6], 7: [1], 22: [29] }
      zIndexes = {}
      for point in @all
        zi = point.owner.zIndex()
        zIndexes[zi] ?= []
        zIndexes[zi].push point.at
      zIndexes


    show: -> @all.map (p) -> p.show


    hide: -> @all.map (p) -> p.hide true # Force it


    each: (func) ->
      @all.forEach func


    filter: (func) ->
      @all.filter func


    validate: ->
      @all = @filter (pt) ->
        ui.elements.has pt.owner

      @trigger 'changed'


  refresh: ->
    @elements.validate()


# Give both an event register
$.extend ui.selection.elements, mixins.events
$.extend ui.selection.points, mixins.events
$.extend ui.selection,
  macro: (actions) ->
    # Given an object with 'elements' and/or 'points'
    # functions, maps these on all selected objects of that type
    # 'transformer' function optional as well, where the
    # transformer is the context

    if actions.elements?
      @elements.each (e) -> actions.elements.call e
    if actions.points?
      @points.each (p) -> actions.points.call p
    if actions.transformer? and @elements.exists()
      actions.transformer.call ui.transformer

    ui.utilities.transform.refreshValues()

  nudge: (x, y, makeEvent = true) ->
    @macro
      elements: ->
        @nudge x, y
      points: ->
        @nudge x, y
        @antlers?.refresh()
        @owner.commit()
      transformer: ->
        @nudge(x, -y).redraw()

    if makeEvent
      # I think this is wrong
      archive.addMapEvent 'nudge', @elements.zIndexes(), { x: x, y: y }
      @elements.each (e) -> e.refreshUI()


  scale: (x, y, origin = ui.transformer.center()) ->
    @macro
      elements: ->
        @scale x, y, origin


  rotate: (a, origin = ui.transformer.center()) ->
    @macro
      elements: ->
        @rotate a, origin
      transformer: ->
        @rotate(a, origin).redraw()


  delete: ->
    @macro
      elements: ->
        @delete()

ui.window =

  setup: ->
    window.onfocus = (e) => @trigger 'focus', [e]
    window.onblur = (e) => @trigger 'blur', [e]
    window.onerror = (msg, url, ln) => @trigger 'error', [msg, url, ln]
    window.onresize = (e) => @trigger 'resize', [e]
    window.onscroll = (e) => @trigger 'scroll', [e]
    window.onmousewheel = (e) => @trigger 'mousewheel', [e]

  listeners: {}

  listenersOne: {}

  on: (event, action) ->
    listeners = @listeners[event]
    if listeners is undefined
      listeners = @listeners[event] = []
    listeners.push action

  one: (event, action) ->
    listeners = @listenersOne[event]
    if listeners is undefined
      listeners = @listenersOne[event] = []
    listeners.push action

  trigger: (event, args) ->
    l = @listeners[event]
    if l?
      for a in l
        a.apply(@, args)
    lo = @listenersOne[event]
    if lo?
      for a in lo
        a.apply(@, args)
      delete @listenersOne[event]

  width: ->
    window.innerWidth

  height: ->
    window.innerHeight

  halfw: ->
    @width() / 2

  halfh: ->
    @height() / 2

  center: ->
    new Posn(@width() / 2, @height() /2)

  centerOn: (p) ->
    x = @width() / 2 - (p.x * ui.canvas.zoom)
    y = @height() / 2 - (p.y * ui.canvas.zoom)
    ui.canvas.normal = new Posn x, y
    ui.canvas.refreshPosition()


setup.push -> ui.window.setup()
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



setup.push ->
  ui.window.on("error", (msg, url, ln) ->
    trackEvent "Javascript", "Error", "#{msg}"
  )
###

  Keeping track of when the user is away from keyboard.
  We can do calculations and stuff when this happens, and
  not bother doing certain things like re-saving the browser file state.

###

ui.afk =

  active: false

  activate: ->
    @active = true

    @startTasks()

  activateTimerId: undefined

  reset: ->
    @active = false

    clearTimeout @activateTimerId

    @activateTimerId = setTimeout =>
      @activate()
    , 2000

  tasks: {}

  do: (key, fun) ->
    @tasks[key] = fun

  stop: (key) ->
    delete @tasks[key]

  startTasks: (tasks = objectValues @tasks) ->
    # Recursively go through the tasks one at a time and execute
    # them one at a time as long as we're still in active afk mode
    hd = tasks[0]
    hd?()

    # If we're still on active afk time
    # keep churning through the tasks
    if tasks.length > 1 and @active
      @startTasks(tasks.slice 1)


###

  TopUI

  An agnostic sort of "tool" that doesn't care what tool is selected.
  Specifically for dealing with top UI elements like utilities.

  Operates much like a Tool object, but the keys are classnames of top UI objects.

###

ui.topUI =

  dispatch: (e, event) ->
    for cl in e.target.className.split(" ")
      @[event]["." + cl]?(e)
    @[event]["#" + e.target.id]?(e)


  hover:
    "slider knob": (e) ->


  unhover:
    "slider knob": ->


  click:
    ".swatch": (e) ->
      return if e.target.parentNode.className == "swatch-duo"
      $swatch = $(e.target)
      offset = $swatch.offset()
      ui.utilities.color.setting = e.target
      ui.utilities.color.toggle().position(offset.left + 41, offset.top).ensureVisibility()

    "#transparent-permanent-swatch": ->
      ui.utilities.color.set ui.colors.null
      ui.utilities.color.updateIndicator()
      if ui.selection.elements.all.length
        archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"))

    ".tool-button": (e) ->
      ui.switchToTool tools[e.target.id.replace("-btn", "")]

    ".slider": (e) ->
      $(e.target).trigger("release")


  mousemove:
    "slider knob": ->


  mousedown:
    "slider knob": ->


  mouseup:
    "#color-pool": (e) ->
      ui.utilities.color.selectColor e

      trackEvent "Color", "Choose", ui.utilities.color.selectedColor.toString()

      if ui.selection.elements.all.length > 0
        archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"))


  startDrag:
    ".slider-container": (e) ->
      console.log 5
      ui.cursor.lastDownTarget = $(e.target).find(".knob")[0]


  continueDrag:
    "#color-pool": (e) ->
      ui.utilities.color.selectColor e

    ".knob": (e) ->
      change = new Posn(e).subtract(ui.cursor.lastPosn)
      $(e.target).nudge(change.x, 0)


  stopDrag:
    ".knob": (e) ->
      $(e.target).trigger("stopDrag")





###

  Swatch is to Color as Point is to Posn

###


class Swatch extends Color
  constructor: (@r, @g, @b, @a = 1.0) ->
    if @r instanceof Color
      @g = @r.g
      @b = @r.b
      @a = @r.a
      @r = @r.r
    super @r, @g ,@b, @a
    @$rep = $("<div class=\"swatch\"></div>")
    @rep = @$rep[0]
    @refresh()
    @$rep.on "set", (event, color) =>
      @absorb color
      @refresh()
    @

  refresh: ->
    # TODO investigate this being called unnecessarily (select all shapes and see)
    if @r is null
      @rep.style.backgroundColor = ""
      @rep.style.border = ""
      @rep.setAttribute("empty", "")
      @rep.setAttribute("val", "empty")
    else
      @rep.style.backgroundColor = @toString()
      @rep.style.border = "1px solid #{@clone().darken(1.5).toHexString()}"
      @rep.removeAttribute("empty")
      @rep.setAttribute("val", @toString())

    if @type?
      @rep.setAttribute("type", @type)

      tiedTo = @tiedTo()
      if tiedTo instanceof Array
        for elem in @tiedTo()
          elem.data[@type] = @clone()
          elem.commit()

      else
        tiedTo.data[@type] = @clone()
        tiedTo.commit()


  tiedTo: -> ui.selection.elements.all

  type: null # "fill" or "stroke"

  appendTo: (selector) ->
    q(selector).appendChild(@rep)
    @

window.Swatch = Swatch



class SwatchDuo
  constructor: (@fill, @stroke) ->
    # I/P: two Swatch objects

    if @fill instanceof Monsvg
      if @fill.data.stroke is undefined
        @stroke = new Swatch(null)
      else
        @stroke = new Swatch @fill.data.stroke

      if @fill.data.fill is undefined
        @fill = new Swatch(null)
      else
        @fill = new Swatch @fill.data.fill

    @fill.type = "fill"
    @stroke.type = "stroke"

    @$rep = $("<div class=\"swatch-duo\"></div>")

    @$rep.append(@fill.$rep)
    @$rep.append(@stroke.$rep)
    @$rep.attr("key", @toString())

    @rep = @$rep[0]

  tiedTo: ->

  toString: ->
    "#{@fill.toHexString()}/#{@stroke.toHexString()}"


###

  Snapping

        /
       /
      O
     /    o
    /
   /
  /

  Provides four main endpoints:
    toAnyOf
    toOneOf
    toThis
    toNothing

  ...with which you should be able to implement any sort of snapping behavior.

  Call any of these within a tool use snapping. Usually within the tool's activateModifier method.

  NOTE: toNothing gets called in all tearDown methods, so undoing snapping is usually already taken care of.
        It's more the calling it to begin with that has to be done.

###



ui.snap =


  toNothing: ->
    # Reset snapping to nothing
    @removeAnnotationLine()
    @supplementEvent = (e) -> e


  toAnyOf: (lines, tolerance, onUpdate = ->) ->
    # Snap to any or none of the given lines
    # When you do snap, it's because the cursor is within
    # the given tolerance of a certain line.
    #
    # If two or more lines are found to match,
    # take the closer one.
    @removeAnnotationLine()
    @supplementEvent = (e) -> e
    # Need to finish this.


  toOneOf: (lines, posnLevel = "client", onUpdate = ->) ->
    # Always snap to the closest of these lines
    @removeAnnotationLine()
    @supplementEvent = (e) ->
      e = cloneObject e
      distances = {}
      lines.map (l) ->
        perpDist = new Posn(e["#{posnLevel}X"], e["#{posnLevel}Y"]).perpendicularDistanceFrom(l)
        if perpDist?
          distances[perpDist[0]] = perpDist[1]

      snap = distances[Math.min.apply(@, Object.keys(distances).map(parseFloat))]
      e["#{posnLevel}X"] = snap.x
      e["#{posnLevel}Y"] = snap.y
      ui.cursor.currentPosn = snap
      onUpdate(e)
      e

  supplementForGrid: (e) ->
    e = cloneObject e
    cp = e.canvasPosnZoomed
    cp = @snapPointToGrid cp
    e

  snapPointToGrid: (p) ->
    freq = ui.grid.frequency
    p.x = p.x.toNearest freq.x, freq.x / 3
    p.y = p.y.toNearest freq.y, freq.y / 3
    p

  toThis: (line, onUpdate = ->) ->
    @removeAnnotationLine()
    # Always always always snap to this one line

  annotationLine: null

  removeAnnotationLine: ->
    # This just removes the old annotation line. It gets called every time the snapping method changes.
    @annotationLine?.remove()
    @annotationLine = null

  updateAnnotationLine: (a, b) ->
    if not @annotationLine?
      @annotationLine = ui.annotations.drawLine(a, b, 'rgba(73,130,224,0.3)')
    else
      @annotationLine.absorbA a
      @annotationLine.absorbB b
      @annotationLine.commit()

  presets:
    every45: (op, posnLevel) ->
      ui.snap.toOneOf([
        new Ray(op, 0)
        new Ray(op, 45)
        new Ray(op, 90)
        new Ray(op, 135)
        new Ray(op, 180)
        new Ray(op, 225)
        new Ray(op, 270)
        new Ray(op, 315)], posnLevel)


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
    ui.uistate.set 'normal', @normal
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

###

  Cursor event overriding :D

  This shit tracks exactly what the cursor is doing and implements some
  custom cursor functions like dragging, which are dispatched via the ui object.

###

ui.cursor =


  reset: ->

    @down = false
    @wasDownLast = false
    @downOn = undefined

    @dragging = false
    @draggingJustBegan = false

    @currentPosn = undefined
    @lastPosn = undefined
    @lastEvent = undefined

    @lastDown = undefined
    @lastDownTarget = undefined

    @lastUp = undefined
    @lastUpTarget = undefined

    @inHoverState = undefined
    @lastHoverState = undefined

    @resetOnNext = false

    @doubleclickArmed = false

    true

  snapChangeAccum:
    x: 0
    y: 0

  resetSnapChangeAccumX: ->
    @snapChangeAccum.x = 0

  resetSnapChangeAccumY: ->
    @snapChangeAccum.y = 0

  dragAccum: () ->
    s = @lastPosn.subtract @lastDown

    x: s.x
    y: s.y

  armDoubleClick: ->
    @doubleclickArmed = true
    setTimeout =>
      @doubleclickArmed = false
    , SETTINGS.DOUBLE_CLICK_THRESHOLD

  setup: ->
    # Here we bind functions to all mouse events that override the default browser behavior for these
    # and track them on a low level so we can do custom interactions with the tools and ui.
    #
    # Each important event does an isDefaultQuarantined check, which asks if the element has the
    # [quarantine] attribute or if one of its parents does. If so, we stop the cursor override
    # and let the browser continue with the default behavior.

    @reset()


    @_click = (e) =>

      # Quarantine check, and return if so
      if isDefaultQuarantined(e.target)
        return true
      else
        e.stopPropagation()

    @_mousedown = (e) =>

      ui.afk.reset()

      # Quarantine check, and return if so
      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        @reset()


        return true
      else
        e.stopPropagation()

        # If the user was in an input field and we're not going back to
        # app-override interaction, blur the focus from that field
        $('input:focus').blur()
        $('[contenteditable]').blur()

        # Also blur any text elements they may have been editing

        # We're back in the app-override level, so fire those hotkeys back up!
        ui.hotkeys.use("app")

        # Prevent the text selection cursor when dragging
        e.originalEvent.preventDefault()

        # Send the event to ui, which will dispatch it to the appropriate places
        ui.mousedown(e, e.target)

        # Set tracking variables
        @down = true
        @lastDown = new Posn(e)
        @downOn = e.target
        @lastDownTarget = e.target

    @_mouseup = (e) =>

      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        ui.dragSelection.end((->), true)
        return true
      else
        ui.hotkeys.use("app")

        ui.mouseup(e, e.target)
        # End dragging sequence if it was occurring
        if @dragging and not @draggingJustBegan
          ui.stopDrag(e, @lastDownTarget)
        else
          if @doubleclickArmed
            @doubleclickArmed = false
            ui.doubleclick(@lastEvent, @lastDownTarget)
            if isDefaultQuarantined(e.target)
              ui.hotkeys.disable() if not allowsHotkeys(e.target)
              ui.dragSelection.end((->), true)
          else
            # It's a static click, meaning the cursor didn't move
            # between mousedown and mouseup so no drag occurred.
            ui.click(e, e.target)
            # HACK
            if e.target.nodeName is "text"
              @armDoubleClick()

        @dragging = false
        @down = false
        @lastUp = new Posn(e)
        @lastUpTarget = e.target
        @draggingJustBegan = false

    @_mousemove = (e) =>

      @doubleclickArmed = false

      ui.afk.reset()
      @lastPosn = @currentPosn
      @currentPosn = new Posn(e)

      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        return true
      else
        if true
          ui.mousemove(e, e.target)
          e.preventDefault()

          # Set some tracking variables
          @wasDownLast = @down
          @lastEvent = e
          @currentPosn = new Posn(e)

          # Initiate dragging, or continue it if it's been initiated.
          if @down
            if @dragging
              ui.continueDrag(e, @lastDownTarget)
              @draggingJustBegan = false
            # Allow for slight movement without triggering drag
            else if @currentPosn.distanceFrom(@lastDown) > SETTINGS.DRAG_THRESHOLD
              ui.startDrag(@lastEvent, @lastDownTarget)
              @dragging = @draggingJustBegan = true

    @_mouseover = (e) =>
      # Just some simple hover actions, as long as we're not dragging something.
      # (We don't want to indicate actions that can't be taken - you can't click on
      # something if you're already holding something down and dragging it)
      return if @dragging

      @lastHoverState = @inHoverState
      @inHoverState = e.target

      # Unhover from the last element we hovered on
      if @lastHoverState?
        ui.unhover(e, @lastHoverState)

      # And hover on the new one! Simple shit.
      ui.hover(e, @inHoverState)

    $('body')
      .click (e) =>
        @_click(e)
      .mousemove (e) =>
        @_mousemove(e)
      .mousedown (e) =>
        @_mousedown(e)
      .mouseup (e) =>
        @_mouseup(e)
      .mouseover (e) =>
        @_mouseover(e)
      .on 'contextmenu', (e) =>
        # Handling right-clicking in @_mouse* handlers
        e.preventDefault()



    # O-K: we're done latching onto the mouse events.

    # Lastly, reset the cursor to somewhere off the screen if they switch tabs and come back
    ui.window.on 'focus', =>
      @currentPosn = new Posn(-100, -100)


setup.push -> ui.cursor.setup()
# ui.dragSelection
#
# Drag rectangle over elements to select many
# Sort of a ghost-tool/utility


ui.dragSelection =

  origin:
    x: 0
    y: 0

  tl:
    x: 0
    y: 0

  width: 0
  height: 0

  asRect: ->
    new Rect
      x: dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x
      y: dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y
      width: @width
      height: @height

  bounds: ->
    new Bounds(
      dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x,
      dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y,
      @width, @height)

  start: (posn) ->
    @origin.x = posn.x
    @origin.y = posn.y
    dom.$dragSelection.show()

  move: (posn) ->
    @tl = new Posn(Math.min(posn.x, @origin.x), Math.min(posn.y, @origin.y))
    @width = Math.max(posn.x, @origin.x) - @tl.x - 1
    @height = Math.max(posn.y, @origin.y) - @tl.y

    dom.$dragSelection.css
      top: @tl.y
      left: @tl.x
      width: @width
      height: @height

  end: (resultFunc, fuckingStopRightNow = false) ->
    dom.$dragSelection.hide()

    return if fuckingStopRightNow

    # Don't bother checking all the elements, this is
    # essentially a click on the background turned
    # to an accidental drag.
    if (@width < 3 and @height < 3)
      return ui.selection.elements.deselectAll()

    iz = 1 / ui.canvas.zoom

    resultFunc @bounds().scale(iz, iz, ui.canvas.origin)

    # Selection bounds should disappear right away
    dom.$dragSelection.hide().css
      left: ''
      top: ''
      width: ''
      height: ''


###

  UI selected elements transformer

###


ui.transformer =


  angle: 0


  resetAccum: ->
    @accumX = 1.0
    @accumY = 1.0
    @accumA = 0.0
    @origin = undefined
    @


  hide: ->
    for own i, r of @reps
      r.style.display = "none"


  show: ->
    @resetAccum()
    for own i, r of @reps
      r.style.display = "block"


  center: ->
    new LineSegment(@tl, @br).midPoint()


  refresh: ->

    @deriveCorners(ui.selection.elements.all) # Just to get the center

    center = @center()

    if ui.selection.elements.all.length is 0
      return @hide()
    else
      @show()

    angles = new Set(ui.selection.elements.all.map((elem) ->
      elem.metadata.angle
    ))

    if angles.length is 1
      @angle = parseFloat angles[0]
    else
      ui.selection.elements.all.map (elem) ->
        elem.metadata.angle = 0

    for elem in ui.selection.elements.all
      if @angle isnt 0
        elem.rotate(360 - @angle, center)
        elem.clearCachedObjects()
      elem.clearCachedObjects()
      elem.lineSegments()

    @deriveCorners(ui.selection.elements.all)

    if @angle isnt 0
      for elem in ui.selection.elements.all
        elem.rotate(@angle, center)
      toAngle = @angle
      @angle = 0
      @rotate(toAngle, center)

    @redraw()

    @

  deriveCorners: (shapes) ->
    if shapes.length == 0
      @tl = @tr = @br = @bl = new Posn 0, 0
      @width = @height = 0
      return

    xRanges = (elem.xRange() for elem in shapes)
    yRanges = (elem.yRange() for elem in shapes)

    getMin = (rs) -> (Math.min.apply(@, rs.map (a) -> a.min))
    getMax = (rs) -> (Math.max.apply(@, rs.map (a) -> a.max))

    xMin = getMin(xRanges)
    xMax = getMax(xRanges)
    yMin = getMin(yRanges)
    yMax = getMax(yRanges)

    @tl = new Posn(xMin, yMin)
    @tr = new Posn(xMax, yMin)
    @br = new Posn(xMax, yMax)
    @bl = new Posn(xMin, yMax)

    @lc = new Posn(xMin, yMin + (yMax - yMin) / 2)
    @rc = new Posn(xMax, yMin + (yMax - yMin) / 2)
    @tc = new Posn(xMin + (xMax - xMin) / 2, yMin)
    @bc = new Posn(xMin + (xMax - xMin) / 2, yMax)

    @width = xMax - xMin
    @height = yMax - yMin

    if @width is 0
      @width = 1
    if @height is 0
      @height = 1


  pixelToFloat: (amt, length) ->
    return 1 if amt is 0
    return 1 + (amt / length)


  redraw: ->

    if ui.selection.elements.all.length is 0
      return @hide()

    tl = @correctAngle(@tl)

    zl = ui.canvas.zoom

    center = @center().zoomed()

    # This is so fucking ugly I'm sorry

    for corner in ["tl", "tr", "br", "bl", "tc", "rc", "bc", "lc"]
      cp = @[corner].zoomedc()
      @reps[corner].style.left = Math.floor(cp.x, 10)
      @reps[corner].style.top = Math.floor(cp.y, 10)
      @reps[corner].style.WebkitTransform = "rotate(#{@angle}deg)"
      @reps[corner].style.MozTransform = "rotate(#{@angle}deg)"

    @reps.outline.style.width = "#{Math.ceil(@width * zl, 10)}px"
    @reps.outline.style.height = "#{Math.ceil(@height * zl, 10)}px"

    tl.zoomed()

    @reps.outline.style.left = "#{Math.floor(tl.x, 10)}px"
    @reps.outline.style.top = "#{Math.floor(tl.y, 10)}px"
    @reps.outline.style.WebkitTransform = "rotate(#{@angle}deg)"
    @reps.outline.style.MozTransform = "rotate(#{@angle}deg)"

    @reps.c.style.left = "#{Math.ceil(center.x, 10)}px"
    @reps.c.style.top = "#{Math.ceil(center.y, 10)}px"

    @


  correctAngle: (p) ->
    p.clone().rotate(360 - @angle, @center())


  drag: (e) ->
    change =
      x: 0
      y: 0

    center = @center()

    # Just for readability's sake...
    cursor = e.canvasPosnZoomed.clone().rotate(360 - @angle, center)

    # This will be "tl"|"top"|"tr"|"right"|"br"|"bottom"|"bl"|"left"
    direction = e.target.className.replace('transform handle ', '').split(' ')[1]

    origins =
      tl:     @br
      tr:     @bl
      br:     @tl
      bl:     @tr
      top:    @bc
      right:  @lc
      bottom: @tc
      left:   @rc

    origin = origins[direction]

    # Change x
    if ["tr", "right", "br"].has direction
      change.x = cursor.x - @correctAngle(@rc).x
    if ["tl", "left", "bl"].has direction
      change.x = @correctAngle(@lc).x - cursor.x

    # Change y
    if ["tl", "top", "tr"].has direction
      change.y = @correctAngle(@tc).y - cursor.y
    if ["bl", "bottom", "br"].has direction
      change.y = cursor.y - @correctAngle(@bc).y

    x = @pixelToFloat(change.x, @width)
    y = @pixelToFloat(change.y, @height)

    # Flipping logic

    if x < 0
      # Flip it horizontally
      opposites =
        tl:     @reps.tr
        tr:     @reps.tl
        br:     @reps.bl
        bl:     @reps.br
        top:    @reps.bc
        right:  @reps.lc
        bottom: @reps.tc
        left:   @reps.rc

      ui.cursor.lastDownTarget = opposites[direction]
      switch direction
        when "left", "bl", "tl"
          return @_flipOver "R"
        when "right", "br", "tr"
          return @_flipOver "L"

    if y < 0
      opposites =
        tl:     @reps.bl
        tr:     @reps.br
        br:     @reps.tr
        bl:     @reps.tl
        top:    @reps.bc
        right:  @reps.lc
        bottom: @reps.tc
        left:   @reps.rc

      ui.cursor.lastDownTarget = opposites[direction]
      switch direction
        when "bottom", "bl", "br"
          return @_flipOver "T"
        when "top", "tl", "tr"
          return @_flipOver "B"

    if ui.hotkeys.modifiersDown.has "shift"
      # Constrain proportions
      if direction[0] is "side"
        if x == 1
          x = y
        else if y == 1
          y = x
      if x < y
        y = x
      else x = y

    if ui.hotkeys.modifiersDown.has "alt"
      # Scale around the center
      origin = center
      x = x * x
      y = y * y

    x = x.ensureRealNumber()
    y = y.ensureRealNumber()

    x = Math.max(1e-5, x)
    y = Math.max(1e-5, y)

    @scale x, y, origin
    @redraw()

    ui.selection.scale x, y, origin


  clonedPosns: ->
    [@tl, @tc, @tr, @rc, @br, @bc, @bl, @lc].map (p) -> p.clone()


  _flipOver: (side) ->
    # side
    #   either "T", "R", "B", "L"

    [tl, tc, tr, rc, br, bc, bl, lc] = @clonedPosns()

    switch side
      when "T"
        @tl = @bl.reflect tl
        @tc = @bc.reflect tc
        @tr = @br.reflect tr

        @rc = @rc.reflect tr
        @lc = @lc.reflect tl

        @bc = tc
        @bl = tl
        @br = tr

        ui.selection.scale(1, -1, @bc)

      when "B"
        @bl = @tl.reflect bl
        @bc = @tc.reflect bc
        @br = @tr.reflect br

        @rc = @rc.reflect br
        @lc = @lc.reflect bl

        @tc = bc
        @tl = bl
        @tr = br

        ui.selection.scale(1, -1, @tc)

      when "L"
        @tl = @tr.reflect tl
        @lc = @rc.reflect lc
        @bl = @br.reflect bl

        @tc = @tc.reflect tl
        @bc = @bc.reflect bl

        @rc = lc
        @br = bl
        @tr = tl

        ui.selection.scale(-1, 1, @rc)

      when "R"
        @tr = @tl.reflect tr
        @rc = @lc.reflect rc
        @br = @bl.reflect br

        @tc = @tc.reflect tr
        @bc = @bc.reflect br

        @lc = rc
        @bl = br
        @tl = tr

        ui.selection.scale(-1, 1, @lc)

    @redraw()


  flipOriginHorizontally: (o) ->
    switch o
      when @tl
        @tr
      when @tr
        @tl
      when @br
        @bl
      when @bl
        @br
      when @rc
        @lc
      when @lc
        @rc

  flipOriginVertically: (o) ->
    switch o
      when @tl
        @tr
      when @tr
        @tl
      when @br
        @bl
      when @bl
        @br
      when @rc
        @lc
      when @lc
        @rc

  scale: (x, y, @origin) ->
    # I/P:
    #   y: Float
    #   origin: Posn

    center = @center()

    for p in @pointsToScale @origin
      p.rotate(360 - @angle, center) if @angle isnt 0
      p.scale x, y, @origin.clone().rotate(360 - @angle, center)
      p.rotate(@angle, center) if @angle isnt 0
    @

    @width *= x
    @height *= y

    if @width is 0
      @width = 1
    if @height is 0
      @height = 1

    @accumX *= x
    @accumY *= y

    @


  pointsToScale: (origin) ->
    switch origin
      when @tc then return [@bl, @bc, @br, @rc, @lc]
      when @rc then return [@bl, @lc, @tl, @tc, @bc]
      when @bc then return [@tl, @tc, @tr, @rc, @lc]
      when @lc then return [@br, @rc, @tr, @bc, @tc]
      when @tl then return [@tr, @br, @bl, @tc, @rc, @bc, @lc]
      when @tr then return [@tl, @br, @bl, @tc, @rc, @bc, @lc]
      when @br then return [@tl, @tr, @bl, @tc, @rc, @bc, @lc]
      when @bl then return [@tl, @tr, @br, @tc, @rc, @bc, @lc]
      else return [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]


  nudge: (x, y) ->
    for p in [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]
      p.nudge x, -y
    @

  rotate: (a, @origin) ->
    @angle += a
    @angle %= 360

    @accumA += a
    @accumA %= 360

    for p in [@tl, @tr, @br, @bl, @tc, @rc, @bc, @lc]
      p.rotate a, @origin
    @


  setup: ->
    @resetAccum()
    @reps =
      tl: q "#trfm-tl"
      tr: q "#trfm-tr"
      br: q "#trfm-br"
      bl: q "#trfm-bl"
      tc: q "#trfm-tc"
      rc: q "#trfm-rc"
      bc: q "#trfm-bc"
      lc: q "#trfm-lc"
      c:  q "#trfm-c"
      outline: q "#trfm-outline"


  tl: new Posn(0,0)
  tr: new Posn(0,0)
  br: new Posn(0,0)
  bl: new Posn(0,0)
  tc: new Posn(0,0)
  rc: new Posn(0,0)
  bc: new Posn(0,0)
  lc: new Posn(0,0)

  onRotatingMode: ->
    $(@reps.c).hide()

  offRotatingMode: ->
    return if ui.selection.elements.all.length is 0
    $(@reps.c).show()


setup.push -> ui.transformer.setup()
###

  Mondrian.io hotkeys management

  This has to be way more fucking complicated than it should.
  Problems:
    • Holding down CMD on Mac mutes all successive keyups.
    • Pushing down key A and key B, then releasing key B, ceases to register key A continuing to be pressed
      so this uses a simulated keypress interval to get around that by storing all keys that are pressed
      and while there are any, executing them all on a 100 ms interval. It feels native, but isn't.

###


ui.hotkeys =

  # Hotkeys is disabled when the user is focused on a quarantined
  # default-behavior area.

  sets:
    # Here we can store various sets of hotkeys, and switch between
    # which we're using at a particular time. The main set is app,
    # and it's selected by default.

    # The structure of a set:
    #  context: give any context and it will be @ (this) in the function bodies
    #  down:    functions to call when keystrokes are pushed down
    #  up:      functions to call when keys are released

    root:
      context: ui
      down:
        'cmd-S': (e) ->
          e.preventDefault() # Save
          @file.save()
        'cmd-N': (e) ->
          e.preventDefault() # New
          console.log "new"
        'cmd-O': (e) ->
          e.preventDefault()
          if @file.service?
            @file.service.open()

      up: {}

    app:
      context: ui
      ignoreAllOthers: false
      down:
        # Tool hotkeys
        'V' : (e) -> @switchToTool tools.cursor
        'P' : (e) -> @switchToTool tools.pen
        'C' : (e) -> @switchToTool tools.crayon
        '\\': (e) -> @switchToTool tools.line
        'L' : (e) -> @switchToTool tools.ellipse
        'T' : (e) -> @switchToTool tools.type
        'M' : (e) -> @switchToTool tools.rectangle
        'R' : (e) -> @switchToTool tools.rotate
        'Z' : (e) -> @switchToTool tools.zoom
        'I' : (e) -> @switchToTool tools.eyedropper

        # Start up the paw
        'space': (e) ->
          e.preventDefault()
          @switchToTool tools.paw

        'shift-X': ->
          f = ui.fill.clone()
          ui.fill.absorb ui.stroke
          ui.stroke.absorb f

        # Text resizing

        'cmd-.': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] += 1
            t.commit()
          ui.transformer.refresh()

        'cmd-shift-.': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] += 10
            t.commit()
          ui.transformer.refresh()

        'cmd-,': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] -= 1
            t.commit()
          ui.transformer.refresh()

        'cmd-shift-,': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] -= 10
            t.commit()
          ui.transformer.refresh()


        'cmd-F': (e) ->
          e.preventDefault()

        'U': (e) ->
          e.preventDefault()
          pathfinder.merge(@selection.elements.all)

        # Ignore certain browser defaults
        'cmd-D': (e) -> e.preventDefault() # Bookmark

        'cmd-S': (e) ->
          e.preventDefault() # Save
          ui.file.save()

        'ctrl-L': -> ui.annotations.clear()

        # Nudge
        'leftArrow':        -> @selection.nudge -1,  0  # Left 1px
        'rightArrow':       -> @selection.nudge 1,   0  # Right 1px
        'upArrow':          -> @selection.nudge 0,   1  # Up 1px
        'downArrow':        -> @selection.nudge 0,  -1  # Down 1px
        'shift-leftArrow':  -> @selection.nudge -10, 0  # Left 10px
        'shift-rightArrow': -> @selection.nudge 10,  0  # Right 10px
        'shift-upArrow':    -> @selection.nudge 0,  10  # Up 10px
        'shift-downArrow':  -> @selection.nudge 0, -10  # Down 10px

      up:
        'space': -> @switchToLastTool()
        '+': -> @refreshAfterZoom()
        '-': -> @refreshAfterZoom()


  use: (set) ->
    if typeof set is "string"
      @using = @sets[set]
    else if typeof set is "object"
      @using = set

    for own key, val of @sets.root.down
      @using.down[key] = val if not @using.down[key]?

    @enable()

  reset: ->
    @lastKeystroke = ''
    @modifiersDown = []
    @keysDown = []

  disable: ->
    if @using is @sets.app
      @disabled = true
    @

  enable: ->
    @disabled = false
    # Hackish
    @cmdDown = false
    @

  modifiersDown: []

  # Modifier key functions
  #
  # When the user pushes Alt, Shift, or Cmd, depending
  # on what they're doing, we might want
  # to change something.
  #
  # Example: when dragging a shape, hitting Shift
  # makes it start snapping to the closest 45°


  registerModifier: (modifier) ->
    if not @modifiersDown.has modifier
      @modifiersDown.push modifier
      ui.uistate.get('tool').activateModifier modifier

  registerModifierUp: (modifier) ->
    if @modifiersDown.has modifier
      @modifiersDown = @modifiersDown.remove modifier
      ui.uistate.get('tool').deactivateModifier modifier


  keysDown: []

  cmdDown: false

  simulatedKeypressInterval: null

  beginSimulatedKeypressTimeout: null

  keypressIntervals: []

  lastKeystroke: ''

  lastEvent: {}


  ###
    Strategy:

    Basically, don't persist keystrokes repeatedly if CMD is down. While CMD is down,
    anything else that happens just happens once and that's it.

    So CMD + A + C will select all and copy once, even is C is held down forever.
    Holding down Shift + LefArrow however will repeatedly nudge the selection left 10px.

    So we save all modifiers being held down, and loop all keys unless CMD is down.
  ###

  setup: ->
    @use "app"

    ui.window.on 'focus', =>
      @modifiersDown = []
      @keysDown = []

    $(document).on('keydown', (e) =>

      if isDefaultQuarantined(e.target)
        if not e.target.hasAttribute("h")
          return true

      # Reset the away from keyboard timer - they're clearly here
      ui.afk.reset()

      # Stop immediately if hotkeys are disabled
      return true if @disabled

      # Parse the keystroke into a string we can read/map to a function
      keystroke = @parseKeystroke(e)

      # Stop if we haven't recognized this keystroke via parseKeystroke
      return false if keystroke is null

      # Save this event for
      @lastEvent = e

      if not e.metaKey
        @cmdDown = false
        @registerModifierUp "cmd"
      else
        @registerModifier "cmd"

      # Cmd has been pushed
      if keystroke is 'cmd'
        if not @cmdDown
          @cmdDown = true # Custom tracking for cmd
          @registerModifier "cmd"
        return

      else if keystroke in ['shift', 'alt', 'ctrl']
        @registerModifier keystroke

        # Stop registering previously registered keystrokes without this as a modifier.
        for key in @keysDown
          @using.up?[@fullKeystroke(key, "")]?.call(@using.context, e)
        return

      else
        if not @keysDown.has keystroke
          newStroke = true
          @keysDown.push keystroke
        else
          newStroke = false

      # By now, the keystroke should only be a letter or number.

      # Default to app hotkeys if for some reason
      # we have no @using hotkeys object
      if not @using?
        @use "app"

      fullKeystroke = @fullKeystroke(keystroke)
      #console.log "FULL: #{fullKeystroke}"

      e.preventDefault() if fullKeystroke is "cmd-O"

      if @using.down?[fullKeystroke]? or @using.up?[fullKeystroke]?

        if @keypressIntervals.length is 0

          # There should be no interval going.
          @simulatedKeypress()
          @keypressIntervals = []

          # Don't start an interval when CMD is down
          if @cmdDown
            return

          # Just fill it with some bullshit so it doesnt pass the check
          # above for length == 0 while a beginSimulatedKeypress timeout
          # is pending.
          @keypressIntervals = [0]

          if @beginSimulatedKeypressTimeout?
            clearTimeout @beginSimulatedKeypressTimeout

          @beginSimulatedKeypressTimeout = setTimeout(=>
            @keypressIntervals.push setInterval((=> @simulatedKeypress()), 100)
          , 350)
        else if @keypressIntervals.length > 0
          ###
            Allow new single key presses while the interval is getting set up.
            (This becomes obvious when you try nudging an element diagonally
            with upArrow + leftArrow, for example)
          ###
          @simulatedKeypress() if newStroke

          return false # Putting this here. Might break shit later. Seems to fix bugs for now.

        else
          return false # Ignore the entire keypress if we are already simulating the keystroke
      else
        if @using.ignoreAllOthers
          return false
        else
          if @using.blacklist? and @using.blacklist != null
            chars = @using.blacklist
            character = fullKeystroke

            if character.match(chars)
              if @using.inheritFromApp.has character
                @sets.app.down[character].call(ui)
                @using.context.$rep.blur()
                @use "app"
              return false
            else
              return true


    ).on('keyup', (e) =>
      return true if @disabled

      keystroke = @parseKeystroke(e)

      if @keysDown.length is 1
        @clearAllIntervals()

      return false if keystroke is null

      @using.up?[keystroke]?.call(@using.context, e)

      if @modifiersDown.length > 0
        @using.up?[@fullKeystroke(keystroke)]?.call(@using.context, e)

      # if is modifier, call up for every key down and this modifier

      if @isModifier(keystroke)
        for key in @keysDown
          @using.up?[@fullKeystroke(key, keystroke)]?.call(@using.context, e)


      @using.up?.always?.call(@using.context, @lastEvent)

      if keystroke is 'cmd' # CMD has been released!
        @modifiersDown = @modifiersDown.remove 'cmd'
        ui.uistate.get('tool').deactivateModifier 'cmd'
        @keysDown = []
        @cmdDown = false

        for own hotkey, action of @using.up
          action.call(@using.context, e) if hotkey.mentions "cmd"

        @lastKeystroke = '' # Let me redo CMD strokes completely please
        return @maintainInterval()

      else if keystroke in ['shift', 'alt', 'ctrl']
        @modifiersDown = @modifiersDown.remove keystroke
        ui.uistate.get('tool').deactivateModifier keystroke
        return @maintainInterval()
      else
        @keysDown = @keysDown.remove keystroke
        return @maintainInterval()
    )


  clearAllIntervals: ->
    for id in @keypressIntervals
      clearInterval id
    @keypressIntervals = []


  simulatedKeypress: ->
    ###
      Since we delay the simulated keypress interval, often a key will be pushed and released before the interval starts,
      and the interval will start after and continue running in the background.

      If it's running invalidly, it won't be obvious because no keys will be down so nothing
      will happen, but we don't want an empty loop running in the background for god knows
      how long and eating up resources.

      This prevents that from happening by ALWAYS checking that this simulated press is valid
      and KILLING IT IMMEDIATELY if not.
    ###


    @maintainInterval()

    #console.log @keysDown.join(", ")

    # Assuming it is still valid, carry on and execute all hotkeys requested.

    return if @keysDown.length is 0 # If it's just modifiers, don't bother doing any more work.

    for key in @keysDown
      fullKeystroke = @fullKeystroke(key)

      if @cmdDown
        if @lastKeystroke is fullKeystroke
          # Don't honor the same keystroke twice in a row with CMD
          4
          #return

      if @using.down?[fullKeystroke]?
        @using.down?[fullKeystroke].call(@using.context, @lastEvent)
        @lastKeystroke = fullKeystroke

      @using.down?.always?.call(@using.context, @lastEvent)


  maintainInterval: -> # Kills the simulated keypress interval when appropriate.
    if @keysDown.length is 0
      @clearAllIntervals()


  isModifier: (key) ->
    switch key
      when "shift", "cmd", "alt"
        return true
      else
        return false



  parseKeystroke: (e) ->

    modifiers =
      8: 'backspace'
      16: 'shift'
      17: 'ctrl'
      18: 'alt'
      91: 'cmd'
      92: 'cmd'
      224: 'cmd'

    if modifiers[e.which]?
      return modifiers[e.which]

    accepted = [
      new Range(9, 9) # Enter
      new Range(13, 13) # Enter
      new Range(65, 90) # a-z
      new Range(32, 32) # Space
      new Range(37, 40) # Arrow keys
      new Range(48, 57) # 0-9
      new Range(187, 190) # - + .
      new Range(219, 222) # [ ] \ '
    ]

    # If e.which isn't in any of the ranges, stop here.
    return null if accepted.map((x) -> x.containsInclusive e.which).filter((x) -> x is true).length is 0

    # Certain keycodes we rename to be more clear
    remaps =
      13: 'enter'
      32: 'space'
      37: 'leftArrow'
      38: 'upArrow'
      39: 'rightArrow'
      40: 'downArrow'
      187: '+'
      188: ','
      189: '-'
      190: '.'
      219: '['
      220: '\\'
      221: ']'
      222: "'"

    keystroke = remaps[e.which] || String.fromCharCode(e.which)

    return keystroke

  fullKeystroke: (key, mods = @modifiersPrefix()) ->
    "#{mods}#{if mods.length > 0 then '-' else ''}#{key}"


  ###
    Returns a string line 'cmd-shift-' or 'alt-cmd-shift-' or 'shift-'
    Always in ALPHABETICAL order. Modifier prefix order must match that of hotkey of the hotkey won't work.
    This is done so we can compare single strings and not arrays or strings, which is faster.
  ###

  modifiersPrefix: ->
    mods = @modifiersDown.sort().join('-')
    if /Win/.test navigator.platform
      mods = mods.replace('ctrl', 'cmd')
    mods



setup.push -> ui.hotkeys.setup()

###

  File Gallery

  Plugs into Dropbox to showcase SVG files available for editing lets user open any by clicking it.
  Made to be able to plug into any other service later on given a standard, simple API. :)

###

ui.gallery =

  service: undefined

  open: (@service) ->
    # Start the file open dialog given a specific service (Dropbox, Drive, Skydrive...)

    # Some UI tweaks to set up the gallery
    ui.changeTo "gallery"
    $('.service-logo').attr("class", "service-logo #{@service.name.toLowerCase()}")
    $(".file-listing").css("opacity", "1.0")
    $('#service-search-input').attr('placeholder', 'Search for files')
    $('#cancel-open-file').one('click', ->
      ui.clear()
      ui.file.load()
      ui.changeTo("draw")
    )
    $loadingIndicator = dom.$serviceGallery.find('.loading')
    serviceNames = ui.account.services.map (s) -> services[s].name
    $loadingIndicator.text("Connecting to #{serviceNames.join(', ')}...").show()

    # Ask the service for the SVGs we can open.
    # When we get these, draw them to the gallery.

    dom.$serviceGalleryThumbs.empty()

    async =>

      for service in ui.account.services
        services[service].getSVGs (response) =>

          # Hide "Connecting to Dropbox..."
          $loadingIndicator.hide()

          # Clear the search bar and autofocus on it.
          dom.$currentService.find('input:text').val("").focus()

          # Write the status message.
          $('#service-file-gallery-message').text("#{response.length} SVG files found")

          # Draw the file listings
          @draw response if response.length > 0


  choose: ($fileListing) ->
    # Given a jQuerified .file-listing div,
    # download the contents of that file and start editing it.

    path = $fileListing.attr "path"
    name = $fileListing.attr "name"
    key = $fileListing.attr "key"
    service = $fileListing.attr "service"

    ui.clear()

    # Call the service for the file contents we want.
    new File().fromService(services[service])(key).use(yes)

    ui.changeTo("draw")

    # Some shmancy UI work to bring visual focus to the clicked file,
    # reinforcing the selection was recognized.

    for file in $(".file-listing")
      $file = $(file)
      if ($file.attr("name") isnt name) or ($file.attr("path") isnt path)
        $file.css("opacity", 0.2).unbind("click")


  draw: (response) ->
    # Clear out the gallery of old thumbnails
    #dom.$serviceGalleryThumbs.empty()
    ui.canvas.setZoom 1.0

    for file in response
      $fileListing = @fileListing file
      dom.$serviceGalleryThumbs.append $fileListing
      $fileListing.one "click", ->
        ui.gallery.choose $ @

    @drawThumbnails response[0], response.slice 1


  drawThumbnails: (hd, tl) ->
    $thumb = $(".file-listing[key=\"#{hd.key}\"] .file-thumbnail-img")

    if hd.thumbnail?
      # If the thumbnail has been generated previously and it's up to date,
      # fetch it and put that up.
      # Meowset takes care of making sure it's up to date and everything. Basically,
      # we get a "thumbnail" attr if we should use one and we don't if we should generate a new one.

      img = new Image()
      img.onload = =>
        @appendThumbnail(hd.thumbnail, $thumb)
      img.src = hd.thumbnail

    else
      # If the file has no thumbnail in S3, we're gonna actually fetch its source and
      # generate a thumbnail for it here on the client. When we finish that we're gonna send
      # it back to Meowset, who will save it to S3 for next time.

      hd.service.get "#{hd.path}#{hd.name}", (response) =>
        contents = response.contents
        shit = dom.$main.children().length
        bounds = io.getBounds contents


        dimen = bounds.fitTo(new Bounds(0, 0, 260, 260))


        png = io.makePNGURI(contents, 260)


        if dom.$main.children().length != shit
          debugger

        @appendThumbnail(png, $thumb, dimen)

        if hd.service != services.local
          # Don't bother making thumbnails when we're working out of
          # local storage. It's faster and cheaper to
          # generate the thumbnails on the client every time
          # because we're not getting the source from Meowset anyway.
          $.ajax
            url: "#{SETTINGS.MEOWSET.ENDPOINT}/files/thumbnails/put"
            type: "POST"
            data:
              session_token: ui.account.session_token
              full_path: "#{hd.path}#{hd.name}"
              last_modified: "#{hd.modified}"
              content: png

    # Recursion
    if tl.length > 0
      @drawThumbnails(tl[0], tl.slice 1)


  fileListing: (file) ->
    # Ad-hoc templating
    $l = $("""
        <div class="file-listing" service="#{file.service.name.toLowerCase()}" path="#{file.path}" name="#{file.name}" key="#{file.key}" quarantine>
          <div class="file-thumbnail">
            <div class="file-thumbnail-img"></div>
          </div>
          <div class="file-name">#{file.name}</div>
          <div class="file-path">in #{file.displayLocation}</div>
        </div>
      """)


  appendThumbnail: (png, $thumb, dimen) ->
    img = new Image()
    img.onload = ->
      $thumb.append @
      $img = $(img)
      img.style.margin = "#{(300 - $img.height()) / 2}px #{(300 - $img.width()) / 2}px"
    img.src = png


setup.push ->
  $("#service-search-input").on("keyup.gs", (e) ->
    $self = $ @
    val = $self.val().toLowerCase()

    if val is ""
      $(".file-listing").show()
    else
      $(".file-listing").each(->
        $fl = $ @
        path = $fl.attr("path")
        name = $fl.attr("name")
        key = $fl.attr("key")

        if name.toLowerCase().indexOf(val) > -1
          $fl.show()
        else
          $fl.hide()
      )
  )


###

  File location browser/chooser
  Used for Save as

###

ui.browser =

  service: undefined

  saveToPath: '/'

  open: (@service) ->

    @saveToPath = '/'

    $so = dom.$serviceBrowser.find("#service-options")
    $so.empty()

    @removeDirectoryColumnsAfter 1

    for service in ui.account.services
      $so.append @serviceButton service

    # Open the file browser
    ui.changeTo "browser"

    $('#current-file-saving-name-input').val(ui.file.name.replace(".svg", "")).fitToVal(20)

    $('#service-search-input').attr('placeholder', 'Search for folder')
    $('#cancel-save-file').unbind('click').on('click', -> ui.changeTo("draw"))
    $('#confirm-save-file').unbind('click').on('click', => @save())

    $loadingIndicator = dom.$serviceBrowser.find('.loading')
    $loadingIndicator.hide()

    if @service?
      $so.addClass("has-selection")
      $so.find(".#{@service.name}").addClass("selected")
      $('.service-logo').attr("class", "service-logo #{@service.name.toLowerCase()}")
      $loadingIndicator.text("Conecting to #{@service.name}...").show()
      @addDirectoryColumn("/", 1, -> $loadingIndicator.hide())



  save: ->
    fn = "#{ $("#current-file-saving-name-input").val() }.svg"
    ui.changeTo("draw")
    @service.put "#{@saveToPath}#{fn}", io.makeFile(), (response) =>
      debugger
      new File().fromService(@service)(fn).use()


  addDirectoryColumn: (path, index, success = ->) ->

    @removeDirectoryColumnsAfter index

    @service.getSaveLocations path, (folders, files) =>
      # Build the new directory column and append it to the main directory
      success()
      $("#browser-directory").append(@directoryColumn folders, files, index)

      # Expensive operation:
      #@recursivePreload folders

  recursivePreload: (folders) ->
    @service.getSaveLocations folders[0].path, =>
      if folders.length > 1
        @recursivePreload(folders.slice 1)

  removeDirectoryColumnsAfter: (index) ->
    # Remove any columns we may have had open that are
    # past the current index of focus.
    $(".scrollbar-screen-directory-col").each ->
      $self = $(@)
      $self.remove() if parseInt($self.attr("index"), 10) >= index


  directoryColumn: (directories, files, index) ->
    # Build the col and make sure it's at the right horizontal location
    $colContainer = $("""
      <div class=\"scrollbar-screen-directory-col\" index=\"#{index}\">
        <div class=\"directory-col\"></div>
      </div>
    """).css
      left: "#{201 * index}px"

    $col = $colContainer.find('.directory-col')

    # Add the directory buttons first
    if directories.length > 0
      $col.append $("<div folders></div>")
      for dir in directories
        $col.find("[folders]").append @directoryButton(dir.path, dir.path.match(/\/[^\/]*$/)[0].substring(1), index)

    # Add the file buttons below them
    if files.length > 0
      $col.append $("<div files></div>")
      for file in files
        $col.find("[files]").append @fileButton(file.path, file.path.match(/\/[^\/]*$/)[0].substring(1), index)

    $colContainer


  directoryButton: (path, name, index) ->
    $("<div class=\"directory-button\">#{name}</div>").on("click", ->
      $self = $ @
      # If it's not already selected, then select it
      if not $self.hasClass "selected"
        ui.browser.saveToPath = "#{path}/"
        ui.browser.addDirectoryColumn("#{path}", index + 1)
        $("#current-file-saving-directory-path").text("#{path}/")
        $self.parent().parent().find('.directory-button').removeClass('selected')
        $self.addClass("selected").parent().parent().addClass("has-selection")
      else
        $self.removeClass("selected").parent().parent().removeClass("has-selection")
        ui.browser.removeDirectoryColumnsAfter (index + 1)
    )

  fileButton: (path, name, index) ->
    $("<div class=\"file-button\">#{name}</div>").on("click", ->
      $('#current-file-saving-name-input').val(name.replace(".svg", "")).trigger("keyup")
    )

  serviceButton: (name) ->
    $("<div class=\"service-button #{name}\">#{name[0].toUpperCase() + name.substring(1)} </div>").on("click", =>
      @open(services[name])
    )



###

  UI Control

  A superclass for custom input controls such as smart text boxes and sliders.

###


class Control

  constructor: (attrs) ->
    # I/P:
    #   object of:
    #     id:     the id for HTML rep
    #     value:  default value
    #     commit: a function that takes the value and does whatever with it!
    # Call the class extension's unique build method,
    # which builds the DOM elements for this control and
    # puts them in the @rep namespace.

    for key, val of attrs
      @[key] = val
    @

    @$rep = $(@rep)

    # Endpoints that we can use to interface with this Control object
    # via its DOM representation. Although in most cases you should just
    # keep track of the actual Control object and interface with it directly.

    @$rep.bind("focus", => @focus())
    @$rep.bind("blur", => @blur())
    @$rep.bind("read", (callback) => callback(@read()))
    @$rep.bind("set", (value) => @set(value))

    @commitFunc = attrs.commit
    @commit = ->
      @commitFunc(@read())

  focused: false

  value: null

  valueWhenFocused: undefined

  appendTo: (selector) ->
    # Should only be called once. Appends control's
    # DOM elements to wherever we want them.
    q(selector).appendChild @rep

  focus: ->
    # Make sure there's not more than one focused control at a time
    ui.controlFocused?.blur()

    @valueWhenFocused = @read()

    # Set this control up as self-aware and turn on its hotkey control
    @focused = true
    ui.controlFocused = @
    ui.hotkeys.use @hotkeys

  blur: ->
    ui.controlFocused = undefined
    @focused = false
    # Commit if they changed anything
    @commit() if @read() != @valueWhenFocused

  update: ->
    @rep.setAttribute "value", @value


  # Standard methods to fill in when making subclasses:

  commit: ->
    # Apply the value to whatever it's supposed to do.

  build: ->
    # Defines @rep

  read: ->
    # Reads the DOM elements for the current value and returns it

  write: (value) ->
    # Sets the DOM elements to reflect a certain value

  set: (@value) ->
    # Set the value to whatever.
    # It should super into this to automatically run @update and set @value
    @write(@value) # Reflec the change in the DOM
    @update()


  # Standard objects to fill in

  hotkeys: {}





###

  Dropdown control

###

class Dropdown extends Control
  constructor: (attrs) ->

    super attrs

    @$chosen = @$rep.find('.dropdown-chosen')
    @$list = @$rep.find('.dropdown-list')

    @options.map (o) =>
      @$list.append o.$rep

    if attrs.default?
      @$chosen.empty().append()

    @select @options[0]

    @close()

    @$chosen.click => @toggle()

  select: (@selected) ->
    # the ol reddit switch a roo
    @$chosen.children().first().appendTo(@$list)
    @$chosen.append(@selected.$rep)
    @refreshListeners()
    @callback(@selected.val)

  opened: false

  open: ->
    # Fucking beautiful plugin
    @$list.find('div').tsort()

    @opened = true
    @$list.show()
    @refreshListeners()

  close: ->
    @opened = false
    @$list.hide()

  refreshListeners: ->
    @$list.find('div').off('click')
    @$list.find('div').on('click', (e) =>
      @select @getOption e.target.innerHTML
      @close()
    )

  toggle: ->
    if @opened
      @close()
    else
      @open()

  getOption: (value) ->
    @options.filter((o) -> o.val is value)[0]


class DropdownOption
  constructor: (@val) ->
    @$rep = $("<div class=\"dropdown-item\">#{@val}</div>")


class FontFaceOption extends DropdownOption
  constructor: (@name) ->
    super

    @$rep.css
      'font-family': @name
      'font-size': '14px'



###

  NumberBox

  _______________
  | 542.3402 px |
  ---------------

  An input:text that only accepts floats and can be adjusted with
  up/down arrows (alt/shift modifiers to change rate)

###

class NumberBox extends Control

  constructor: (attrs) ->
    # I/P:
    #   object of:
    #     rep:   HTML rep
    #     value: default value ^_^
    #     commit: callback for every change of value, given event and @read()
    #     [onDown]: callback for every keydown, given event and @read()
    #     [onUp]:   callback for every keyup, given event and @read()
    #     [onDone]: callback for every time the user seems to be done
    #               incrementally editing with arrow keys / typing in
    #               a value. Happens on arrowUp and enter
    #     [min]:    min value allowed
    #     [max]:    max value allowed
    #     [places]: round to this many places whenever it's changed

    super attrs

    if attrs.addVal?
      @addVal = attrs.addVal
    else
      @addVal = @_addVal

    @rep.setAttribute("h", "")

    # This has to be defined in the constructor and not as part of the class itself,
    # because we want the scope to be the object instnace and not the object constructor.
    @hotkeys = $.extend({
      context: @
      down:
        always: (e) ->
          @onDown?(e, @read())

        enter: (e) ->
          @write(@read())
          @commit()
          @onDone?(e, @read())

        upArrow: (e) ->
          @addVal e, 1

        downArrow: (e) ->
          @addVal e, -1

        "shift-upArrow": (e) ->
          @addVal e, 10

        "shift-downArrow": (e) ->
          @addVal e, -10

        "alt-upArrow": (e) ->
          @addVal e, 0.1

        "alt-downArrow": (e) ->
          @addVal e, -0.1

      up:

        # Specific onDone events with arrow keys
        upArrow:         (e) -> @onDone?(e, @read())
        downArrow:       (e) -> @onDone?(e, @read())
        "shift-upArrow": (e) -> @onDone?(e, @read())
        "shift-downArrow": (e) -> @onDone?(e, @read())
        "alt-upArrow":   (e) -> @onDone?(e, @read())
        "alt-downArrow": (e) -> @onDone?(e, @read())

        always: (e) ->
          @onUp?(e, @read())

      blacklist: /^[A-Z]$/gi

      inheritFromApp: [
        'V'
        'P'
        'M'
        'L'
        '\\'
        'O'
        'R'
      ]
    }, attrs.hotkeys)

  read: ->
    parseFloat @$rep.val()


  write: (@value) ->
    if @places?
      @value = parseFloat(@value).places @places
    if @max?
      @value = Math.min(@max, @value)
    if @min?
      @value = Math.max(@min, @value)
    @$rep.val(@value)


  _addVal: (e, amt) ->
    e.preventDefault()
    oldVal = @read()
    if not oldVal?
      oldVal = 0
    newVal = @read() + amt
    @write(newVal)
    @commit()


window.NumberBox = NumberBox


###

  TestBox

  ___________
  | #FF0000 |
  -----------

###

class TextBox extends Control

  constructor: (attrs) ->
    # I/P:
    #   object of:
    #     rep:   HTML rep
    #     value: default value ^_^
    #     commit: callback for every change of value, given event and @read()
    #     maxLength: maximum str length for value
    #     [onDown]: callback for every keydown, given event and @read()
    #     [onUp]:   callback for every keyup, given event and @read()
    #     [onDone]: callback for every time the user seems to be done
    #               incrementally editing with arrow keys / typing in
    #               a value. Happens on arrowUp and enter

    super attrs

    @rep.setAttribute("h", "")

    if attrs.maxLength?
      @rep.setAttribute("maxLength", attrs.maxLength)

    # This has to be defined in the constructor and not as part of the class itself,
    # because we want the scope to be the object instnace and not the object constructor.
    @hotkeys = $.extend({
      context: @
      down:
        always: (e) ->
          @onDown?(e, @read())

        enter: (e) ->
          @write(@read())
          @commit()
          @onDone?(e, @read())

      up:
        always: (e) ->
          @onUp?(e, @read())

      blacklist: null

      inheritFromApp: [
        'V'
        'P'
        'M'
        'L'
        '\\'
        'O'
        'R'
      ]
    }, attrs.hotkeys)


  read: ->
    @$rep.val()


  write: (@value) ->
    @$rep.val(@value)

window.TextBox = TextBox





class Slider extends Control

  constructor: (attrs) ->
    # I/P:
    #   object of:
    #     rep: div containing slider elements:
    #       %div.slider.left-icon
    #       %div.slider.right-icon
    #       %div.slider.track
    #     commit: callback for every change of value
    #     inverse: goes max to min instead
    #     onRelease: callback for when the user stops dragging
    #     valueTipFormatter: a method that returns a string
    #                        given the value of @read().
    #                        If defined, a live tip will
    #                        appear under the slider that shows
    #                        the current value when it's being moved.

    super attrs

    @hotkeys = {}

    @$knob = @$rep.find('.knob')
    @$track = @$rep.find('.track')
    if @valueTipFormatter?
      @$knob.append(@$tip = $("<div class=\"slider tip\"></div>"))

    @knobWidth = @$knob.width()

    @trackMin = parseFloat(@$track.css("left"))
    @trackWidth = parseFloat(@$track.css("width")) - @knobWidth
    @trackMax = @trackMin + @trackWidth

    @$knob.on("nudge", =>
      @commit()
      @$tip?.show().text(@valueTipFormatter(@read()))
    )
    .on("stopDrag", =>
      @onRelease?(@read())
      @$tip?.hide()
      )
    .attr("drag-x", "#{@trackMin} #{@trackMax}")

    @set 0.0

    @$iconLeft = @$rep.find(".left-icon")
    @$iconRight = @$rep.find(".right-icon")

    @$knob.on("click", (e) => e.stopPropagation())

    @$iconLeft.on "click", (e) =>
      e.stopPropagation()
      @set 0.0
      @commit()

    @$iconRight.on "click", (e) =>
      e.stopPropagation()
      @set 1.0
      @commit()

    @$track = @$rep.find(".track")

    @$rep.on "release", =>
      @onRelease?(@read())



  read: ->
    @leftCSSToFloat(parseFloat(@$knob.css("left")))


  write: (value) ->
    @$knob.css("left", @floatToLeftCSS(value))


  floatToLeftCSS: (value) ->
    value = Math.min(1.0, (Math.max(0.0, value)))
    if @inverse
      value = 1.0 - value

    l = ((@trackWidth * value) + @trackMin).px()


  leftCSSToFloat: (left) ->
    f = (parseFloat(left) - @trackMin) / @trackWidth
    if @inverse
      return 1.0 - f
    else
      return f




###

  Menubar, which manage MenuItems

###

ui.menu =

  # MenuItems
  menus: {}

  # MenuItems
  items: {}

  menu: (id) ->
    objectValues(@menus).filter((menu) -> menu.itemid == id)[0]

  item: (id) ->
    objectValues(@items).filter((item) -> item.itemid == id)[0]

  closeAllDropdowns: ->
    for own k, item of @menus
      item.closeDropdown()

  refresh: ->
    for own key, menu of @menus
      menu.refresh()


###

  MenuItem

  An item on the top program menu, like Open, Save... etc
  Template.

###

class Menu
  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

    @$rep = $("##{@itemid}")
    @rep = @$rep[0]

    @$dropdown = $("##{@itemid}-dropdown")
    @dropdown = @$dropdown[0]

    # Save this neffew in ui.menu. This is how we're gonna access it from now on.
    @dropdownSetup()

    if @onlineOnly
      @bindOnlineListeners()

  refresh: ->
    @items().map -> @_refresh()

  refreshEnabledItems: ->
    @items().map ->
      if @enableWhen?
        if @enableWhen() then @enable() else @disable()

  refreshAfterVisible: ->
    # Slower operations get called in here
    # to prevent visible lag.
    @items().map -> @refreshAfterVisible?()

  items: ->
    @$rep.find('.menu-item').map ->
      ui.menu.item(@id)

  disabled: false

  dropdownOpen: false

  bindOnlineListeners: ->
    if not navigator.onLine
      @hide()

    window.addEventListener("offline", @hide.bind @)
    window.addEventListener("online", @show.bind @)

  text: (val) ->
    @$rep.find("> [buttontext]").text(val)
    @

  _click: ->
    # This is standard for MenuItems: they open their dropdown.
    # You can also give it an onOpen method, which gets called
    # after the dropdown has opened.
    @toggleDropdown()
    ui.refreshUtilities()
    @click?()

  openDropdown: ->
    return if @dropdownOpen

    # You can't have more than one dropdown open at the same time
    ui.menu.closeAllDropdowns()

    # Make this button highlighted unconditionally
    # while the dropdown is open
    @$rep.attr("selected", "")

    @refresh()

    # Open the dropdown
    @$dropdown.show()
    @dropdownOpen = true

    trackEvent "Menu #{@itemid}", "Action (click)"

    # Call the refresh method
    async => @refreshAfterVisible()
    @

  closeDropdown: ->
    return if not @dropdownOpen

    @$rep.removeAttr("selected")
    @$rep.find("input:focus").blur()
    @$dropdown.hide()
    @dropdownOpen = false
    @onClose?()
    @

  toggleDropdown: ->
    if @dropdownOpen then @closeDropdown() else @openDropdown()

  show: ->
    return @ if @onlineOnly and !navigator.onLine
    @$rep?.removeClass "hidden"
    @

  hide: ->
    @$rep?.addClass "hidden"
    @

  dropdownSetup: ->
    # Fill in
    # Use this to bind listeners/special things to special elements in the dropdown.
    # Basically, do special weird things in here.

  group: ->
    @$rep.closest(".menu-group")

  groupHide: ->
    @group()?.hide()

  groupShow: ->
    @group()?.css("display", "inline-block")


###

  A button in a menu dropdown.

  Simple shit. Just has a handful of methods.

    text
      Change what it says.

    action
      Change what it does.

    refresh
      Change other things about it
      when its dropdown gets opened.

    disable
      Disable it

    enable
      Enable it

###



class MenuItem
  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

    @$rep = $("##{@itemid}")
    @rep = @$rep[0]

    if @hotkey?
      ui.hotkeys.sets.app.down[@hotkey] = (e) =>
        e.preventDefault()
        @_refresh()
        return if @disabled
        @action(e)
        trackEvent "Menu item #{@itemid}", "Action (hotkey)"
        @owner()?.refresh()
        @$rep.addClass("down")
        @owner()?.$rep.addClass("down")

        if @hotkey.mentions "cmd"
          setTimeout =>
            @$rep.removeClass("down")
            @owner()?.$rep.removeClass("down")
            @_refresh()
          , 50

      if not (@hotkey.mentions "cmd")
        return if @disabled
        ui.hotkeys.sets.app.up[@hotkey] = (e) =>
          @$rep.removeClass("down")
          @owner()?.$rep.removeClass("down")
          @after?()
          @_refresh()



  _click: (e) ->
    @_refresh()
    return if @disabled
    @owner()?.closeDropdown() if @closeOnClick
    @owner()?.$rep.find("[selected]").removeAttr("selected")
    @action?(e)
    @owner()?.refreshEnabledItems()
    trackEvent "Menu item #{@itemid}", "Action (click)"


  closeOnClick: true


  save: ->
    # Fill in


  _refresh: ->
    @refresh?()
    if @enableWhen?
      if @enableWhen() then @enable() else @disable()


  refresh: ->
    # Fill in


  owner: ->
    ui.menu.menu(@$rep.closest(".menu").attr("id"))


  show: ->
    @$rep.show()
    $(".separator[visiblewith=\"#{@itemid}\"]").show()
    @


  hide: ->
    @$rep.hide()
    $(".separator[visiblewith=\"#{@itemid}\"]").hide()
    @


  disable: ->
    @disabled = true
    @$rep.addClass "disabled"
    @


  enable: ->
    @disabled = false
    @$rep.removeClass "disabled"
    @


  text: (val) ->
    @$rep.find("[buttontext]").text val


  group: ->
    @$rep.closest(".menu-group")


  groupHide: ->
    @group()?.hide()


  groupShow: ->
    @group()?.css("display", "inline-block")


setup.push ->


  ui.menu.menus.file = new Menu
    itemid: "file-menu"



setup.push ->

  ui.menu.menus.edit = new Menu
    itemid: "edit-menu"

  ui.menu.items.undo = new MenuItem
    itemid: "undo-item"

    action: (e) ->
      e.preventDefault()
      archive.undo()

    hotkey: "cmd-Z"

    closeOnClick: false

    enableWhen: ->
      not archive.currentlyAtBeginning()


  ui.menu.items.redo = new MenuItem
    itemid: "redo-item"

    action: (e) ->
      e.preventDefault()
      archive.redo()

    hotkey: "cmd-shift-Z"

    closeOnClick: false

    enableWhen: ->
      not archive.currentlyAtEnd()


  ui.menu.items.visualHistory = new MenuItem
    itemid: "visual-history"

    action: (e) ->
      ui.utilities.history.toggle()

    hotkey: "0"

    closeOnClick: false

    enableWhen: ->
      archive.events.length > 0


  ui.menu.items.selectAll = new MenuItem
    itemid: "select-all-item"

    action: (e) ->
      e.preventDefault()
      ui.selection.elements.selectAll()

    hotkey: "cmd-A"

    closeOnClick: false

    enableWhen: ->
      ui.elements.length > 0


  ui.menu.items.cut = new MenuItem
    itemid: "cut-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.cut()

    hotkey: "cmd-X"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0


  ui.menu.items.copy = new MenuItem
    itemid: "copy-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.copy()

    hotkey: "cmd-C"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0


  ui.menu.items.paste = new MenuItem
    itemid: "paste-item"

    action: (e) ->
      e.preventDefault()
      ui.clipboard.paste()

    hotkey: "cmd-V"

    closeOnClick: false

    enableWhen: ->
      ui.clipboard.data?


  ui.menu.items.delete = new MenuItem
    itemid: "delete-item"

    action: (e) ->
      e.preventDefault()
      archive.addExistenceEvent(ui.selection.elements.all.map (e) -> e.zIndex())
      ui.selection.delete()
      ui.selection.elements.validate()


    hotkey: "backspace"

    closeOnClick: false

    enableWhen: ->
      ui.selection.elements.all.length > 0




setup.push ->

  ui.menu.menus.view = new Menu
    itemid: "view-menu"

  ui.menu.items.zoomOut = new MenuItem
    itemid: "zoom-out-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoomOut()
      false
    after: ->
      ui.refreshAfterZoom()
    hotkey: "-"
    closeOnClick: false


  ui.menu.items.zoomIn = new MenuItem
    itemid: "zoom-in-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoomIn()
      false
    after: ->
      ui.refreshAfterZoom()

    hotkey: "+"
    closeOnClick: false


  ui.menu.items.zoom100 = new MenuItem
    itemid: "zoom-100-item"
    action: (e) ->
      e.preventDefault()
      ui.canvas.zoom100()
      false
    after: ->
      ui.refreshAfterZoom()
    hotkey: "1"
    closeOnClick: false


  ui.menu.items.grid = new MenuItem
    itemid: "show-grid-item"
    hotkey: "shift-'"
    action: ->
      ui.grid.toggle()
    closeOnClick: false


setup.push ->

  ui.menu.menus.about = new Menu
    itemid: "about-menu"

    refreshAfterVisible: ->

setup.push ->

  ui.menu.menus.login = new Menu
    itemid: "login-menu"

    onlineOnly: true

    refreshAfterVisible: ->
      $("#login-email-input").focus()

    submit: ($self) ->
      email = $("#login-email-input").val()
      passwd = $("#login-passwd-input").val()

      if email == ""
        $self.error("email required")
      else if passwd == ""
        $self.error("password required")
      else
        ui.account.login(email, passwd)
      #@closeDropdown()


  $("#submit-login").click ->
    ui.menu.menus.login.submit($(@))

  $("#login-passwd-input").hotkeys
    down:
      enter: ->
        ui.menu.menus.login.submit()


setup.push ->

  ui.menu.menus.register = new Menu
    itemid: "register-menu"

    onlineOnly: true

    refreshAfterVisible: ->
      $("#register-name").focus()

    submit: ->
      name =   $("#register-name").val()
      email =  $("#register-email").val()
      passwd = $("#register-passwd").val()

      #return if name == "" or email == "" or passwd == ""

      ui.account.create(name, email, passwd, (data) ->
        # pass
      )

  $("#submit-registration").click -> ui.menu.menus.register.submit()

  $("#register-passwd").hotkeys
    down:
      enter: ->
        ui.menu.menus.register.submit()

setup.push ->

  ui.menu.menus.geometry = new Menu
    itemid: "geometry-menu"

setup.push ->

  ui.menu.menus.account = new Menu
    itemid: "account-menu"

    onlineOnly: true

    showAndFillIn: (email) ->
      @group().style.display = "inline-block"
      @$rep.find("span#logged-in-email").text email

    onClose: ->
      @$dropdown.attr("mode", "normal")
setup.push ->

  ui.menu.menus.share = new Menu
    itemid: "share-menu"

    onlineOnly: true

  ui.menu.items.shareAsLink = new MenuItem
    itemid: "share-permalink-item"

    action: ->
      services.permalink.put()

setup.push ->
  ui.menu.menus.embed = new Menu
    itemid: "embed-menu"

    template: () ->
      height = ((ui.canvas.height / ui.canvas.width) * @width) + 31 # 3px for border above footer
      height = Math.ceil(height)
      "<iframe width=\"#{@width}\" height=\"#{height}\" frameborder=\"0\" src=\"#{SETTINGS.EMBED.ENDPOINT}/files/permalinks/#{ui.file.key}/embed\"></iframe>"

    onlineOnly: true

    refreshAfterVisible: ->
      if ui.file.constructor is PermalinkFile
        @generateCode()
        @$textarea.select()
      else
        # Save it to s3 if we haven't yet
        @$textarea.val "Saving, please wait..."
        @$textarea.disable()
        services.permalink.put(undefined, io.makeFile(), =>
          @generateCode()
          @$textarea.enable()
          @$textarea.select()
        )

    dropdownSetup: ->
      @width = 500
      @$textarea = @$rep.find("textarea")

      @widthControl = new NumberBox
        rep:   @$rep.find('input')[0]
        value: @width
        min: 100
        max: 1600
        places: 0
        hotkeys:
          up:
            always: ->
              @commit()

        commit: (val) =>
          @width = val
          @generateCode()


    generateCode: ->
      @$textarea.val @template()

setup.push ->

  ui.menu.items.filename = new MenuItem
    itemid: "filename-item"

    refresh: (name, path, service) ->
      @$rep.find("#file-name-with-extension").text(ui.file.name)
      @$rep.find("#service-logo-for-filename").show().attr("class", "service-logo-small #{ui.file.service.name}")

      @$rep.find("#service-path-for-filename").html(ui.file.path)

    action: (e) ->
      e.stopPropagation()

setup.push ->

  ui.menu.items.save = new MenuItem
    itemid: "save-item"

    action: (e) ->
      e?.preventDefault()

      ui.file.save =>
        @enable()
        @text("Save")

      trackEvent "Local files", "Save"

      @disable()
      @text("Saving...")

    hotkey: 'cmd-S'

    refresh: ->
      if ui.file.readonly
          @disable()
          @text("This file is read-only")
      else
        if ui.file.hasChanges()
          @enable()
          @text("Save")
        else
          @disable()
          @text("All changes saved")


  ui.menu.items.saveAs = new MenuItem
    itemid: "save-as-item"

    action: (e) ->
      e?.preventDefault()

      ui.browser.open()

    hotkey: 'cmd-shift-S'

    refresh: ->
      @enable()


setup.push ->

  ui.menu.items.new = new MenuItem
    itemid: "new-item"

    action: (e) ->
      ui.new(1000, 750, new Posn(0,0), 1.0)

      switch ui.file.service
        when services.permalink, services.local
          f = new LocalFile(services.local.nextDefaultName()).use()
          ui.file.save()
          archive.setup()
        when services.dropbox
          services.dropbox.defaultName ui.file.path, (name) ->
            new DropboxFile("#{ui.file.path}#{name}").use()

    hotkey: 'N'



setup.push ->

  ui.menu.items.logout = new MenuItem
    itemid: "logout-item"

    action: ->
      ui.account.logout()


setup.push ->


  # Open...

  ui.menu.items.open = new MenuItem
    itemid: "open-item"

    action: ->
      ui.file.service.open()


  # Open from hard drive...

  ui.menu.items.openHD = new MenuItem
    itemid: "open-from-hd-item"

    action: ->

    refresh: ->
      $input = $("#hd-file-loader")
      reader = new FileReader
      name = null

      reader.onload = (e) =>
        new LocalFile(name).set(e.target.result).use(true).save()
        @owner().closeDropdown()

      $input.change ->
        @setAttribute("value", "")
        file = @files[0]
        return if not file?
        name = file.name
        reader.readAsText file
        trackEvent "Local files", "Open from HD"


  # Open from URL...

  ui.menu.items.openURL = new MenuItem
    itemid: "open-from-url-item"

    action: ->
      @inputMode()
      setTimeout ->
        ui.cursor.reset()
      , 1

    openURL: (url) ->
      name = url.match(/[^\/]*\.svg$/gi)
      name = if name then name[0] else services.local.nextDefaultName()

      $.ajax
        url: "#{SETTINGS.BONITA.ENDPOINT}/curl/?url=#{url}"
        type: 'GET'
        data: {}
        success: (data) ->
          data = new XMLSerializer().serializeToString(data)
          file = new LocalFile(name).set(data).use(true)
          trackEvent "Local files", "Open from URL"
        error: (data) ->
          console.log "error"

    clickMeMode: ->
      @$rep.find("input").blur()
      @$rep.removeClass("input-mode")
      @$rep.removeAttr("selected")

    inputMode: ->
      self = @
      @$rep.addClass("input-mode")
      @$rep.attr("selected", "")
      @$rep.find('input').val("").focus().on("paste", (e) =>
        setTimeout (=>
          @openURL $(e.target).val()
          @clickMeMode()
          @owner().closeDropdown()
        ), 10
      )

    closeOnClick: false

    refresh: ->
      @clickMeMode()

setup.push ->

  ui.menu.items.dropboxConnect = new MenuItem
    itemid: "connect-to-dropbox-item"

    enableWhen: -> navigator.onLine

    refresh: () ->
      if ui.account.session_token
        @enable()
        @rep.parentNode.setAttribute("href", "#{SETTINGS.MEOWSET.ENDPOINT}/poletto/connect-to-dropbox?session_token=#{ui.account.session_token}")
        @$rep.parent().off('click').on('click', ->
          ui.window.one "focus", ->
            ui.menu.menus.file.closeDropdown()
            ui.account.checkServices()
            trackEvent "Dropbox", "Connect Account"
        )

      else
        @disable()
        @$rep.parent().click (e) ->
          e.preventDefault()



setup.push ->

  ui.menu.items.downloadSVG = new MenuItem
    itemid: "download-as-SVG-item"

    refreshAfterVisible: ->
      # TODO refactor these variable names, theyre silly
      $link = q("#download-svg-link")
      if @disabled
        $link.removeAttribute("href")
        $link.removeAttribute("download")
      else
        $link.setAttribute("href", io.makeBase64URI())
        $link.setAttribute("download", ui.file.name)
      $($link).one 'click', ->
        trackEvent "Download", "SVG", ui.file.name


  ui.menu.items.downloadPNG = new MenuItem
    itemid: "download-as-PNG-item"

    refreshAfterVisible: ->
      $link = q("#download-png-link")
      if @disabled
        $link.removeAttribute("href")
        $link.removeAttribute("download")
      else
        $link.setAttribute("href", io.makePNGURI())
        $link.setAttribute("download", ui.file.name.replace("svg", "png"))
      $($link).one 'click', ->
        trackEvent "Download", "PNG", ui.file.name

setup.push ->


  ui.menu.items.moveBack = new MenuItem
    itemid: 'move-back-item'

    hotkey: '['

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.moveBack()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mb')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.moveForward = new MenuItem
    itemid: 'move-forward-item'

    hotkey: ']'

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.moveForward()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mf')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.sendToBack = new MenuItem
    itemid: 'send-to-back-item'

    hotkey: 'shift-['

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.sendToBack()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mbb')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false


  ui.menu.items.bringToFront = new MenuItem
    itemid: 'bring-to-front-item'

    hotkey: 'shift-]'

    action: ->
      zIndexesBefore = ui.selection.elements.zIndexes()
      ui.selection.elements.all.map (e) -> e.bringToFront()
      archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mff')

    enableWhen: -> ui.selection.elements.all.length > 0

    closeOnClick: false



ui.utilities = {}

class Utility

  constructor: (attrs) ->
    for own i, x of attrs
      @[i] = x
    if @setup?
      setup.push => @setup()
    @$rep = $(@root)

    setup.push => if @shouldBeOpen() then @show() else @hide()

  shouldBeOpen: ->

  show: ->
    return if ui.canvas.petrified
    @visible = true
    @rep?.style.display = "block"
    @onshow?()
    @

  hide: ->
    @visible = false
    @$rep.find('input').blur()
    @rep?.style.display = "none"
    @

  toggle: ->
    if @visible then @hide() else @show()

  position: (@x, @y) ->
    @rep?.style.left = x.px()
    @rep?.style.top = y.px()
    @

  saveOffset: ->
    @offset = new Posn($(@rep).offset())
    @


###

  Color picker

###

ui.utilities.color = new Utility
  setup: ->

    @rep = q("#color-picker-ut")
    @poolContainer = q("#pool-container")
    @poolContext = q("#color-picker-ut canvas#color-pool").getContext("2d")
    @saturationSliderContainer = q("#saturation-slider")
    # We get two of these bad boys due to how the infinite scroll illusion works.
    @currentIndicator1 = q("#color-marker1")
    @currentIndicator2 = q("#color-marker2")
    @inputs =
      r: q("#color-r")
      g: q("#color-g")
      b: q("#color-b")
      hex: q("#color-hex")

    @hide()

    # Build the infinite color pool.
    @drawPool()

    # Set up infinite scroll.
    @poolContainer.onscroll = (e) ->
      if @scrollTop == 0
        @scrollTop = 1530
      else if @scrollTop == 3060 - 260
        @scrollTop = 1530 - 260
      # This lets us keep the mouse down and scroll at the same time.
      # Super cool effect nobody will notice, but it's 2 loc so w/e
      if ui.cursor.down
        ui.utilities.color.selectColor(ui.cursor.lastEvent)

    @saturationSlider = new Slider
      rep: @saturationSliderContainer,
      commit: (val) =>
        @drawPool val
        @set @getColorAt @selected
        @center

    @rControl = new NumberBox
      rep: @inputs.r
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("r", val)

    @gControl = new NumberBox
      rep: @inputs.g
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("g", val)

    @gControl = new NumberBox
      rep: @inputs.b
      min: 0
      max: 255
      value: 0
      commit: (val) =>
        @alterVal("b", val)

    @hexControl = new TextBox
      rep: @inputs.hex
      value: 0
      commit: (val) =>
        @set new Color(val)
        @refresh()
        @selectedColor.updateHex()
        @hexControl.write(@selectedColor.hex)
      hotkeys:
        blacklist: null
      maxLength: 6


  alterVal: (which, val) ->
    @selectedColor[which] = val
    @selectedColor.recalculateHex()
    @set @selectedColor
    @refresh()


  refresh: ->
    # Update the color pool saturation
    @drawPool(@selectedColor.saturation())

    # Update the saturation slider
    @saturationSlider.write(@selectedColor.saturation())

    # Update the position of the indicator
    @selected = @getPositionOf @selectedColor
    @updateIndicator().centerOnIndicator()


  shouldBeOpen: -> no # lol


  onshow: ->
    @poolContainer.scrollTop = 600
    @selectedColor = new Color(@setting.getAttribute("val"))
    @selected = @getPositionOf @selectedColor
    @saturationSlider.set(@selectedColor.saturation())
    @drawPool(@selectedColor.saturation())
    @updateIndicator()
    @centerOnIndicator()
    trackEvent "Color", "Open picker"


  ensureVisibility: ->
    @rep.style.top = "#{Math.min(ui.window.height() - 360, parseFloat(@rep.style.top))}px"
    @saveOffset()


  centerOnIndicator: ->
    @poolContainer.scrollTop = parseFloat(@currentIndicator1.style.top) - 130
    @


  setting: null


  set: (color) ->
    @selectedColor = color

    $(@setting).trigger("set", [color])

    $(@inputs.r).val(color.r)
    $(@inputs.g).val(color.g)
    $(@inputs.b).val(color.b)
    $(@inputs.hex).val(color.hex)


  selectColor: (e) ->
    @selected = new Posn(e).subtract(@offset).subtract(new Posn(10, 12))
    @selected.y += @poolContainer.scrollTop
    color = @getColorAt @selected
    @set color
    @updateIndicator()


  updateIndicator: ->
    if @selectedColor.toString() == "none"
      @hideIndicator(@currentIndicator1)
      @hideIndicator(@currentIndicator2)
    else
      @showIndicator(@currentIndicator1)
      @showIndicator(@currentIndicator2)
      @positionIndicator @currentIndicator1, @selected
      @selected.y = (@selected.y + 1530) % 3060
      @positionIndicator @currentIndicator2, @selected
      @


  showIndicator: (indicator) ->
    indicator.style.display = "block"

  hideIndicator: (indicator) ->
    indicator.style.display = "none"


  getColorAt: (posn) ->
    data = @poolContext.getImageData(posn.x, posn.y, 1, 1)
    new Color(data.data[0], data.data[1], data.data[2])


  getPositionOf: (color) ->
    primary = color.max()
    secondary = color.mid()
    tertiary = color.min()

    switch primary
      when color.r
        y = 0
        switch secondary
          when color.g
            y += secondary
          when color.b
            y -= secondary

      when color.g
        y = 510
        switch secondary
          when color.b
            y += secondary
          when color.r
            y -= secondary

      when color.b
        y = 1020
        switch secondary
          when color.r
            y += secondary
          when color.g
            y -= secondary

    if y < 0
      y += 1530

    y %= 1530

    x = 260 - (color.lightness() * 260)

    new Posn(x, y)


  positionIndicator: (indicator, posn) ->
    indicator.className = if posn.x < 130 then "indicator black" else "indicator white"
    indicator.style.left = posn.x.px()
    indicator.style.top = (posn.y).px()


  sample: (elem) ->
    @setting = ui.fill.rep
    @set(if elem.data.fill? then elem.data.fill else ui.colors.null)
    @setting = ui.stroke.rep
    @set(if elem.data.stroke? then elem.data.stroke else ui.colors.null)


  drawPool: (saturation = 1.0) ->

    gradient = @poolContext.createLinearGradient(0, 0, 0, 3060)

    colors = [ui.colors.red, ui.colors.yellow, ui.colors.green,
              ui.colors.teal, ui.colors.blue, ui.colors.pink]

    for i in [0..12]
      gradient.addColorStop((1 / 12) * i, colors[i % 6].clone().desaturate(1.0 - saturation).toHexString())

    @poolContext.fillStyle = gradient
    @poolContext.fillRect(0, 0, 260, 3060)

    # 1530 3060

    wb = @poolContext.createLinearGradient(0, 0, 260, 0)
    wb.addColorStop(0.02, "#FFFFFF")
    wb.addColorStop(0.5, "rgba(255, 255, 255, 0.0)")
    wb.addColorStop(0.5, "rgba(0, 0, 0, 0.0)")
    wb.addColorStop(0.98, "#000000")

    @poolContext.fillStyle = wb
    @poolContext.fillRect(0, 0, 260, 3060)





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


ui.utilities.typography = new Utility
  setup: ->
    @$rep = $("#typography-ut")
    @rep = @$rep[0]

    @$faces = @$rep.find("#font-faces-dropdown")
    @$size = @$rep.find("#font-size-val")

    @sizeControl = new NumberBox
      rep: @$size[0]
      value: 24
      min: 1
      max: 1000
      places: 2
      commit: (val) =>
        @setSize val

    @faceControl = new Dropdown
      options: @faces
      rep:     @$faces[0]
      callback: (val) =>
        @setFace(val)

  faces: new FontFaceOption(fontFace) for fontFace in ['Arial', 'Arial Black', 'Cooper Black', 'Georgia', 'Monaco', 'Verdana', 'Impact', 'Gill Sans']

  setFace: (face) ->
    ui.selection.elements.ofType("text").map (t) ->
      t.setFace face
      t.commit()
    ui.transformer.refresh()


  setSize: (val) ->
    ui.selection.elements.ofType("text").map (t) ->
      t.setSize val
      t.commit()
    ui.transformer.refresh()

  refresh: ->
    sizes = []
    ui.selection.elements.ofType("text").map (t) ->
      fs = t.data['font-size']
      if not sizes.has fs
        sizes.push fs
    if sizes.length is 1
      @sizeControl.write sizes[0]
    @faceControl.close()

  onshow: ->
    @refresh()

  shouldBeOpen: ->
    (ui.selection.elements.ofType("text").length > 0) or (ui.uistate.get('tool') is tools.type) # TEXT EDITING AHH


ui.utilities.history = new Utility

  setup: ->
    @$rep = $("#archive-ut")
    @rep = @$rep[0]
    @$container = $("#archive-thumbs")
    @container = @$container[0]
    @$controls = $("#archive-controls")
    @controls = @$controls[0]

    @stepsSlider = new Slider
      rep: $("#archive-steps-slider")[0]
      commit: (val) =>
      valueTipFormatter: (val) =>
        "#{Math.round(@maxSteps * val) + 1}"
      onRelease: (val) =>
        @build Math.round(@maxSteps * val) + 1
      inverse: true

  thumbsCache: {}

  deleteThumbsCached: (after) ->
    toDelete = []
    for own key, thumb of @thumbsCache
      if parseInt(key, 10) > after
        toDelete.push key
    for key in toDelete
      delete @thumbsCache[key]
    @

  shouldBeOpen: -> false

  open: ->
    @show()

    # Set this to just return true to keep it open
    @shouldBeOpen = -> true

    # Build it async so the window pops open and shows
    # the loading progress while it's compiling the thumbnails
    async =>
      @build()

  close: ->
    @$container.empty()
    @shouldBeOpen = -> false
    @hide()

  toggle: ->
    if @visible then @close() else @open()


  build: (@every) ->
    if archive.events.length < 3
      @$controls.hide()
      @every = 1
      return @$container.html('<div empty>Make changes to this file to get a visual history of it.</div>')

    @$controls.show()

    # Calculate max value for steps slider
    @maxSteps = Math.round(archive.events.length / 4)

    if not @every?
      @every = Math.round(@maxSteps / 2)
      @stepsSlider.write(0.5)

    # Remember where we were
    @$container.html('<div empty>Processing <br> file history... <br> <span percentage></span></div>')
    async =>
      @buildThumbs @every


  buildThumbs: (@every, startingAt = 0) ->

    # If we're redrawing the entire thumbs list
    # clear whatever was in there before be it old thumbs
    # or the empty message
    @$container.empty() if startingAt < 2

    cp = archive.currentPosition()
    cs = ui.selection.elements.zIndexes()

    ui.canvas.petrify()

    # Put the archive in simulating mode to omit
    # unnecessary UI actions
    archive.simulating = true

    # Go to where we want to start going up from
    archive.goToEvent startingAt

    @thumbs = []

    @_buildRecursive archive.currentPosition(), @every, =>

      # Go back to where we started from
      archive.goToEvent cp

      archive.simulating = false

      ui.canvas.depetrify()

      ui.selection.elements.deselectAll()
      for zi in cs
        ui.selection.elements.selectMore(queryElemByZIndex(zi))

      @$container.empty() if startingAt is 0

      @thumbs.map ($thumb) =>
        @$container.prepend $thumb

      @refreshThumbs(archive.currentPosition())


  _buildRecursive: (i, @every, done) ->
    percentage = Math.min(Math.round((i / archive.events.length) * 100), 100)
    @$container.find('[percentage]').text("#{percentage}%")

    archive.goToEvent i

    if @thumbsCache[i]?
      src = @thumbsCache[i]

    else
      contents = io.makeFile()
      src = io.makePNGURI(ui.elements, 150)
      @thumbsCache[i] = src

    img = new Image()
    img.src = src

    $thumb = $("<div class=\"archive-thumb\" position=\"#{i}\"></div>")
    $thumb.prepend img
    $thumb.off("click").on("click", ->
      $self = $ @
      i = parseInt($self.attr("position"), 10)
      archive.goToEvent i
      ui.utilities.history.refreshThumbs.call($thumb, i))

    @thumbs.push $thumb
    async =>
      if i < archive.events.length - 1
        @_buildRecursive(Math.min(i + @every, archive.events.length - 1), @every, done)
      else
        done()


  refreshThumbs: (i) ->
    # Go to this event's index, and update all the other
    $(".archive-thumb").removeClass("future")
    $(".archive-thumb").each ->
      $self = $ @
      if parseInt($self.attr("position"), 10) > i
        $self.addClass "future"



###

  Tools class and organization object.
  Higher-level tool event method dispatcher and event augmentation.
  Includes template for all possible methods.

###

# All tools are stored under this namespace
window.tools = {}

class Tool

  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

  tearDown: ->

  setup: ->

  activateModifier: (modifier) ->

  deactivateModifier: (modifier) ->

  followingAngle: false

  typeOf: (target) ->
    # Depending on what is being clicked on/hovered over/dragged,
    # tools will do different things. This method performs various tests
    # on event.target. Return what is being clicked on as a string.

    if isSVGElementInMain target
      return "elem"
    else if isBezierControlHandle target
      return "antlerPoint"
    else if isPointHandle target
      return "point"
    else if isTransformerHandle target
      return "transformerHandle"
    else if isHoverTarget target
      return "hoverTarget"
    else
      return "background"



  buildEvent: (e) ->
    # Viewport coordinates are those of the actual white board we are drawing on,
    # the canvas.
    #
    # I/P: e: event object
    # O/P: e: augmented event object

    e.clientPosn = new Posn(e.clientX, e.clientY)

    e.canvasX = (e.clientX - ui.canvas.normal.x) / ui.canvas.zoom
    e.canvasY = (e.clientY - ui.canvas.normal.y) / ui.canvas.zoom

    e.canvasPosn = lab.conversions.posn.clientToCanvas(e.clientPosn)
    e.canvasPosnZoomed = lab.conversions.posn.clientToCanvasZoomed(e.clientPosn)

    if ui.grid.visible()
      e = ui.snap.supplementForGrid e
    if ui.snap.supplementEvent?
      e = ui.snap.supplementEvent e

    e.modifierKeys = e.shiftKey or e.metaKey or e.ctrlKey or e.altKey

    # Amt the cursor has moved on this event
    if ui.cursor.lastPosn?
      e.changeX = e.clientX - ui.cursor.lastPosn.x
      e.changeY = -(e.clientY - ui.cursor.lastPosn.y)

      e.changeX /= ui.canvas.zoom
      e.changeY /= ui.canvas.zoom

      e.changeXSnapped = e.changeX + ui.cursor.snapChangeAccum.x
      e.changeYSnapped = e.changeY + ui.cursor.snapChangeAccum.y

    e.typeOfTarget = @typeOf e.target

    # Now we query the appropriate JS object representations of the target,
    # and potentially its relatives. Store this in the event object as well.
    switch e.typeOfTarget
      when "elem"
        e.elem = ui.queryElement e.target # Monsvg object

      when "point"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.point = e.elem.points.at e.target.getAttribute("at") # Point object

      when "antlerPoint"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.point = e.elem.queryAntlerPoint(e.target) # Point object

      when "hoverTarget"
        e.elem = queryElemByUUID e.target.getAttribute("owner") # Monsvg object
        e.pointA = e.elem.points.at parseInt(e.target.getAttribute 'a') # Point object
        e.pointB = e.elem.points.at parseInt(e.target.getAttribute 'b') # Point object
        e.hoverTarget = e.pointB.hoverTarget # HoverTarget object

    # By now, the event object should have a typeOfTarget attribute
    # and the appropriate JS object(s) embedded in it for the tool
    # to interface with the objects on the screen appropriately.
    #
    # From now on, ONLY (clientX, clientY) or (canvasX, canvasY)
    # should ever be used in tool methods. OK MOTHERFUCKERS? LETS KEEP THIS STANDARD.
    #
    # So let's return the new event now.

    e


  dispatch: (e, eventType) ->
    # Sends a mouse event to the appropriate tool method.
    # I/P: e: event object
    #      eventType: "hover", "unhover", "click", "startDrag", "continueDrag", "stopDrag"
    #                 Basically, a string describing the actual behavior of the mouse.
    #                 Brought in from ui/cursor_tracking.coffee
    # O/P: Nothing, simply calls the appropriate method.

    # If we're unhovering, this is a special case where we actually target the LAST hover target,
    # not the current one. We need to set this before we run @buildEvent

    # First let's get the additional info we need to carry this out no matter what.
    e = @buildEvent e

    # A note about how methods should be organized:
    # The method should be named after the event.typeOfTarget (output from tool.typeOf)
    # and it should live in an object named after the eventType given this by ui/ui.coffee
    # The eventType will be one of the strings listed in the I/P section for this method above.
    #
    # So hovering over a point with the cursor will call tools.cursor.hover.point(e)

    args = [e]

    if eventType is 'startDrag'
      for modifier in ui.hotkeys.modifiersDown
        @activateModifier modifier
      @draggingType = e.typeOfTarget

    if eventType is "doubleclick" and @ignoreDoubleclick
      eventType = "click"

    if @[eventType]?
      # If a method explicitly for this target type exists, run it. This is the most common case.
      if @[eventType][e.typeOfTarget]?
        return @[eventType][e.typeOfTarget]?.apply @, args

      # If it doesn't, check for events that apply to multiple target types.
      # Multi-target keys should be named by separating the targets with underscores.
      # For example, hovering over a point might trigger hover.point_elem or hover.hoverTarget_elem_point
      for own key, value of @[eventType]
        if key.mentions e.typeOfTarget
          return value.apply @, args

      # If there are none that mention it, check for an "all" event.
      # This should seldom be in use.
      if @[eventType].all?
        return @[eventType].all.apply @, args

      # By now, we clearly don't care about this event/target combo. So do nothing.


  recalculateLastDrag: ->
    if ui.cursor.dragging
      ui.cursor._mousemove ui.cursor.lastEvent


noop =
  background: (e) ->
  elem: (e) ->
  point: (e) ->
  antlerPoint: (e) ->
  toolPlaceholder: (e) ->
  hoverTarget: (e) ->

Tool::hover        = noop
Tool::unhover      = noop
Tool::click        = noop
Tool::rightClick   = noop
Tool::mousedown    = noop
Tool::mouseup      = noop
Tool::startDrag    = noop
Tool::continueDrag = noop
Tool::stopDrag     = noop

###

  Cursor tool

  Default tool that performs selection and transformation.


      #
      #   #
      #      #
      #         #
      #            #
      #               #
      #      #  #  #  #  #
      #   #
      ##
      #

###

tools.cursor = new Tool

  # Cursor image action point coordinates
  offsetX: 1
  offsetY: 1

  # CSS "tool" attribute given to the body when this tool is selected
  # to have its custom cursor show up.
  cssid: 'cursor'
  id: 'cursor'

  tearDown: ->
    for elem in ui.elements
      if not ui.selection.elements.all.has elem
        elem.hidePoints()

  initialDragPosn: undefined

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        switch @draggingType
          when "elem", "hoverTarget", "point"
            op = @initialDragPosn
            if op?
              ui.snap.presets.every45(op)

            # Recalculate the last drag event, so it snaps
            # as soon as Shift is pushed.
            @recalculateLastDrag()
      when "alt"
        switch @draggingType
          when "elem"
            3
            #@duplicateElemModeOn()


  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        switch @draggingType
          when "elem", "hoverTarget"
            ui.snap.toNothing()
            @recalculateLastDrag()
      when "alt"
        switch @draggingType
          when "elem"
            3
            #@duplicateElemModeOff()


  hover:
    background: (e) ->
      for elem in ui.elements
        elem.hidePoints?()
      ui.unhighlightHoverTargets()
    elem: (e) ->
      e.elem.hover()

      ###
      if not ui.selection.elements.all.has e.elem
        e.elem.hover()

        if e.elem.group?
          e.elem.group.map (elem) -> elem.showPoints()

      ui.unhighlightHoverTargets()
      ###

    point: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.elem.unhoverPoints()
        e.elem.showPoints()
        ui.unhighlightHoverTargets()

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.elem.unhoverPoints()
        e.elem.showPoints()
        e.hoverTarget.highlight()

  unhover:
    background: (e) ->
    elem: (e) ->
      e.elem.unhover()

    point: (e) ->
      e.elem.hidePoints()

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      if e.currentHover isnt e.elem.rep
        e.elem.unhoverPoints()
        e.elem.hidePoints()
      e.hoverTarget.unhighlight()

  click:
    background: (e) ->
      if not e.modifierKeys
        ui.selection.elements.deselectAll()
      ui.selection.points.deselectAll()
    elem: (e) ->
      # Is this shit selected already?
      elem = e.elem
      selected = ui.selection.elements.all.has elem
      ui.selection.points.deselectAll()

      # If the shift key is down, this is a toggle operation.
      # Whether or not the element is already selected, do the opposite.
      # It's also additive/subtractive from the current selection
      # which might include many elements.
      if e.shiftKey
        if selected
          ui.selection.elements.deselect elem
          elem.showPoints()
          elem.hover()
        else
          if elem.group?
            ui.selectMore elem.group.elements
          else
            ui.selection.elements.selectMore elem
            elem.unhover()
            elem.removePoints()
      else
        if not selected
          if elem.group?
            ui.selection.elements.select elem.group.elements
            elem.group.map (elem) -> elem.removePoints()
          else
            ui.selection.elements.select elem
            elem.unhover()
            elem.removePoints()

      ui.unhighlightHoverTargets()

    point: (e) ->
      if e.shiftKey
        ui.selection.points.selectMore e.point
      else
        ui.selection.points.select e.point

    antlerPoint: (e) ->

    hoverTarget: (e) ->
      ui.selection.points.selectMore(e.hoverTarget.a)
      ui.selection.points.selectMore(e.hoverTarget.b)

  doubleclick:
    elem: (e) ->
      trackEvent "Text", "Doubleclick edit"
      if e.elem instanceof Text
        e.elem.selectAll()


  startDrag:

    # This happens once at the beginning of every time the user drags something.
    background: (e) ->
      ui.dragSelection.start(new Posn(e))
    elem: (e) ->

      e.elem.unhover()

      # If we're dragging an elem, deselect any selected points.
      ui.selection.points.deselectAll()

      # Also hide any hover targets that may be visible.
      ui.unhighlightHoverTargets()

      # Is the element selected already? If so, we're going to be dragging
      # the entire selection that it's a part of.
      #
      # If not, select this element and anything it may be grouped with.
      if not ui.selection.elements.all.has e.elem
        if e.elem.group?
          ui.selection.elements.select e.elem.group.elements
        else
          ui.selection.elements.select e.elem

      # Remove the select elements' points entirely
      # so we don't accidentally start dragging those.
      for elem in ui.selection.elements.all
        elem.removePoints()

      ui.selection.elements.all.map (elem) -> elem.commit()
      @guidePointA = ui.transformer.center()

    antlerPoint: (e) ->

    point: (e) ->
      e.point.antlers?.show()
      e.point.owner.removeHoverTargets()
      ui.selection.points.select e.point

      if ui.selection.elements.all.has e.elem and ui.hotkeys.modifiersDown.has "alt"
          e.elem.clone().appendTo('#main')

    transformerHandle: (e) ->

    hoverTarget: (e) ->
      if not ui.selection.elements.all.has e.elem
        e.hoverTarget.active()

        ui.selection.elements.deselectAll()
        ui.selection.points.deselectAll()

        @guidePointA = ui.transformer.center()

  snapChange:
    x: 0
    y: 0

  changeAccum:
    x: 0
    y: 0

  continueDrag:
    background: (e) ->
      ui.dragSelection.move(new Posn(e.clientX, e.clientY))
    elem: (e) ->
      # Hide point UI elements
      e.elem.removePoints()

      # If there is an accum from last snap to undo, do that first
      ac = @snapChange
      if ac.x isnt 0 and ac.y isnt 0
        # Only bother if there is something to do
        ui.selection.nudge(-ac.x, -ac.y)
      # Move the shape in its "true" position
      ui.selection.nudge(e.changeX + @changeAccum.x, e.changeY + @changeAccum.y, false)

      # resnap

      if ui.grid.visible()
        bl = ui.transformer.bl
        nbl = ui.snap.snapPointToGrid bl.clone()

        @snapChange =
          x: nbl.x - bl.x
          y: bl.y - nbl.y

        if @snapChange.x is -e.changeX
          @changeAccum.x += e.changeX
        else
          @changeAccum.x = 0

        if @snapChange.y is -e.changeY
          @changeAccum.y += e.changeY
        else
          @changeAccum.y = 0

        ui.selection.nudge(@snapChange.x, @snapChange.y, false)


    point: (e) ->
      if ui.selection.elements.all.has e.elem
        return @continueDrag.elem(e)

      e.point.nudge(e.changeX, e.changeY)
      e.point.antlers?.refresh()

      # We're moving a single point individually,
      # ruining any potential virginal integrity
      e.elem.woohoo()

      e.elem.commit()

    antlerPoint: (e) ->
      e.point.nudge(e.changeX, e.changeY)
      e.elem.commit()

    transformerHandle: (e) ->
      ui.transformer.drag e

    hoverTarget: (e) ->
      if ui.selection.elements.all.has e.elem
        return @continueDrag.elem.call tools.cursor, e
      else
        e.hoverTarget.nudge(e.changeX, e.changeY)


  stopDrag:
    background: (e) ->
      ui.dragSelection.end (b) -> ui.selection.elements.selectWithinBounds b

    elem: (e) ->
      for elem in ui.selection.elements.all
        elem.redrawHoverTargets()
        elem.commit()

      # Save this event
      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)

      if @duping
        archive.addExistenceEvent(@duping.rep)
      else
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: nudge.x, y: -nudge.y })
      @changeAccum =
        x: 0
        y: 0

      #@duping = undefined

    point: (e) ->
      e.elem.redrawHoverTargets()
      e.elem.clearCachedObjects()
      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)
      archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x,
        y: -nudge.y
      })

    antlerPoint: (e) ->
      e.elem.redrawHoverTargets()

      nudge = new Posn(e).subtract(ui.cursor.lastDown)
      nudge.setZoom(ui.canvas.zoom)

      archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x
        y: -nudge.y
        antler: (if e.point.role is -1 then "p3" else "p2")
      })


    transformerHandle: (e) ->
      ui.utilities.transform.refresh()
      for elem in ui.selection.elements.all
        elem.redrawHoverTargets()
      archive.addMapEvent("scale", ui.selection.elements.zIndexes(), {
        x: ui.transformer.accumX
        y: ui.transformer.accumY
        origin: ui.transformer.origin
      })
      ui.transformer.resetAccum()

    hoverTarget: (e) ->
      e.elem.redrawHoverTargets()
      e.elem.clearCachedObjects()

      ui.selection.points.selectMore(e.hoverTarget.a)
      ui.selection.points.selectMore(e.hoverTarget.b)

      nudge = new Posn(e).subtract(ui.cursor.lastDown)

      eventData = {}
      zi = e.elem.zIndex()
      eventData[zi] = []
      eventData[zi].push(e.hoverTarget.a.at, e.hoverTarget.b.at)

      archive.addMapEvent("nudge", eventData, {
        x: nudge.x
        y: -nudge.y
      })



###

  Paw tool

  Pan around.

###

tools.paw = new Tool

  offsetX: 8
  offsetY: 8

  id:    'paw'
  cssid: 'paw'

  setup: ->
    # Ran into a crazy bug where the canvas normal suddenly had NaN
    # as its X value. Prevent that from happening

    if isNaN(ui.canvas.normal.x)
      ui.canvas.normal.x = 0
    if isNaN(ui.canvas.normal.y)
      ui.canvas.normal.y = 0

  tearDown: ->

  continueDrag:
    all: (e) ->
      ui.canvas.nudge(
        e.changeX * ui.canvas.zoom,
        e.changeY * ui.canvas.zoom)

  mousedown:
    all: ->
      dom.toolCursorPlaceholder.setAttribute 'tool', 'paw-clutch'

  mouseup:
    all: ->
      dom.toolCursorPlaceholder.setAttribute 'tool', 'paw'

###

  Pen tool

  Polygon/path-drawing tool


            #
            #
          #####
          #* *#
          # * #
       ###########
       # * * * * #
       #* * * * *#
       # * * * * #



tools.pen = new Tool

  offsetX: 5
  offsetY: 0

  cssid: 'pen'

  id: 'pen'

  ignoreDoubleclick: true

  tearDown: ->
    if @drawing
      ui.selection.elements.select @drawing
      @drawing.redrawHoverTargets()
      @drawing.points.map (p) ->
        p.hideHandles?()
        p.hide()
      @drawing = false
    @clearPoints()


  # Metadata: what shape we're in, what point was just put down,
  # which is being dragged, etc.

  drawing: false
  firstPoint: null
  lastPoint: null
  currentPoint: null

  clearPoints: ->
    # Resetting most of the metadata.
    @firstPoint = null
    @currentPoint = null
    @lastPoint = null


  beginNewShape: (e) ->
    # Ok, if we're drawing and there's no stroke color defined
    # but the stroke width isn't 0, we need to resort to black.
    if (ui.uistate.get('strokeWidth') > 0) and (ui.stroke.toString() is "none")
      ui.stroke.absorb ui.colors.black

    # State a new Path!
    shape = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY}")
    shape.appendTo('#main')
    shape.commit().showPoints()

    archive.addExistenceEvent(shape.rep)

    @drawing = shape
    @firstPoint = shape.points.first
    @currentPoint = @firstPoint



  endShape: ->

    # Close up the shape we're drawing.
    # This happens when the last point is clicked.

    @drawing.points.close().hide()
    @drawing.commit()
    @drawing.redrawHoverTargets()
    @drawing.points.first.antlers.basep3 = null

    @drawing = false
    @clearPoints()


  addStraightPoint: (x, y) ->

    # On a static click, add a point inheriting the last point's succp2 antler.
    # If there was one, this will be a SmoothTo. If there wasn't, then a LineTo.

    last = @drawing.points.last
    succp2 = last.antlers.succp2

    if @drawing.points.last.antlers?.succp2?
      if last instanceof CurvePoint and succp2.x isnt last.x and succp2.y isnt last.y
        point = new SmoothTo(x, y, x, y, @drawing, last)
      else
        point = new CurveTo(last.antlers.succp2.x, last.antlers.succp2.y, x, y, x, y, @drawing, last)
    else
      point = new LineTo(x, y, @drawing)

    @drawing.points.push point

    last.hideHandles?()
    @drawing.hidePoints()
    point.draw()

    archive.addPointExistenceEvent(@drawing.zIndex(), point)

    @drawing.commit().showPoints()
    @currentPoint = point

  addCurvePoint: (x, y) ->
    # CurveTo
    x2 = x
    y2 = y

    last = @drawing.points.last
    last.hideHandles?()
    point = new CurveTo(last.x, last.y, x, y, x, y, @drawing, @drawing.points.last)

    @drawing.points.push point

    if last.antlers?.succp2?
      point.x2 = point.prec.antlers.succp2.x
      point.y2 = point.prec.antlers.succp2.y

    last.hideHandles?()
    @drawing.hidePoints()
    point.draw()

    archive.addPointExistenceEvent(@drawing.zIndex(), point)

    @drawing.commit().showPoints()
    @currentPoint = point


  updateCurvePoint: (e) ->
    @currentPoint.antlers.importNewSuccp2(new Posn(e.canvasX, e.canvasY))

    if @drawing.points.closed
      @currentPoint.antlers.show()
      @currentPoint.antlers.succp.persist()

    @currentPoint.antlers.lockAngle = true
    @currentPoint.antlers.show()
    @currentPoint.antlers.refresh()
    @drawing.commit()


  leaveShape: (e) ->
    @drawing = false


  hover:
    point: (e) ->
      if @drawing
        switch e.point
          when @lastPoint
            e.point.actionHint()
            undo = e.point.antlers.hideTemp 2
            @unhover.point = =>
              undo()
              e.point.hideActionHint()
              @unhover.point = ->
          when @firstPoint
            e.point.actionHint()
            @unhover.point = =>
              e.point.hideActionHint()
              @unhover.point = ->


  unhover: {}


  click:
    background_elem: (e) ->
      if not @drawing
        @beginNewShape(e)
      else
        @addStraightPoint e.canvasX, e.canvasY

    point: (e) ->
      switch e.point
        when @lastPoint
          e.point.antlers.killSuccp2()
        when @firstPoint
          @drawing.points.close()
          @addStraightPoint e.point.x, e.point.y
          @drawing.points.last.antlers.importNewSuccp2 @drawing.points.first.antlers.succp2
          @drawing.points.last.antlers.lockAngle = true

          # We've closed the shape
          @endShape()
        else
          @click.background_elem.call(@, e)

  mousedown:
    all: ->
      if @currentPoint? and @snapTo45
        ui.snap.presets.every45((if @currentPoint? then @currentPoint else @lastPoint), "canvas")

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        @snapTo45 = true
        if @currentPoint? or @lastPoint?
          ui.snap.presets.every45((if @currentPoint? then @currentPoint else @lastPoint), "canvas")

  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        @snapTo45 = false
        ui.snap.toNothing()

  snapTo45: false

  startDrag:
    point: (e) ->
      if e.point is @firstPoint
        @drawing.points.close()
        @addCurvePoint e.point.x, e.point.y
      else
        @startDrag.all(e)

    all: (e) ->
      if @drawing
        @addCurvePoint e.canvasX, e.canvasY
      else
        @beginNewShape e


  continueDrag:
    all: (e, change) ->
      @updateCurvePoint(e) if @drawing


  stopDrag:
    all: (e) ->
      if @drawing.points.closed
        @currentPoint.deselect().hide()
        @endShape()
      @lastPoint = @currentPoint
      @currentPoint = null

###

  Crayon plz

###

tools.crayon = new Tool

  offsetX: 5
  offsetY: 0
  cssid: 'crayon'
  id: 'crayon'

  drawing: false

  setup: ->

  tearDown: ->

  # How many events we go between putting down a point
  # Which kind of point alternates:
  frequency: 0

  eventCounter: 0

  alternatingCounter: 2

  beginNewLine: (e) ->
    line = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY}")
    line.appendTo('#main')
    line.commit().showPoints()

    @line = line
    @currentPoint = @line.points.first

  determineControlPoint: (which) ->
    # Helper for the crayon
    switch which
      when "p2"
        [compareA, compareB, stashed] = [@lastPoint, @currentPoint, @stashed33]
      when "p3"
        [compareA, compareB, stashed] = [@currentPoint, @lastPoint, @stashed66]

    lastBaseToNewBase = new LineSegment(compareA, compareB)
    lastBaseTo33      = new LineSegment(compareA, stashed)

    lBBA =  lastBaseToNewBase.angle360()
    lB33A = lastBaseTo33.angle360()

    angleBB = lB33A - lBBA
    angleDesired = lBBA + angleBB * 2

    lenBB = lastBaseToNewBase.length
    lenDesired = lenBB / 3

    desiredHandle = new Posn(compareA)
    desiredHandle.nudge(0, -lenDesired)
    desiredHandle.rotate(angleDesired + 180, compareA)

    if isNaN desiredHandle.x
      desiredHandle.x = compareB.x
    if isNaN desiredHandle.y
      desiredHandle.y = compareB.y

    desiredHandle

  stashedBaseP3: undefined

  addPoint: (e) ->
    switch @alternatingCounter
      when 1
        @lastPoint = @currentPoint

        # Now we figure out where the last succp2 should have been
        # Twice the angle, half the length.

        if e?
          @currentPoint = new CurveTo(
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            @line)

        #ui.annotations.drawDot(@currentPoint, '#ff0000')

        @alternatingCounter = 2

        #  Time for a shitty diagram!
        #
        #           C
        #          / \
        #         /   |
        #        /     |
        #       /    /
        #      /   X
        #     / /
        #    L------V
        #
        #   L = @lastPoint
        #   C = @currentPoint
        #   X = @stashed33
        #   V = what we want
        #
        #   Line from L-C = lastBaseToNewBase
        #   Line from L-V = lastBaseTo33

        return if not @stashed33?

        @lastPoint.antlers.succp2 = @determineControlPoint('p2')
        @currentPoint.antlers.basep3 = @determineControlPoint('p3')

        @lastPoint.succ = @currentPoint

        # Now that lastPoint has both antlers,
        # flatten them to be no less than 180
        @lastPoint.antlers.flatten()
        @lastPoint.antlers.commit()
        @currentPoint.antlers.commit()

        @line.points.push @currentPoint
        @currentPoint.draw()

        @line.points.hide()
        @line.commit()

      when 2
        # Stash the 33% mark
        @stashed33 = e.canvasPosnZoomed
        @alternatingCounter = 3

      when 3
        # Stash the 66% mark
        @stashed66 = e.canvasPosnZoomed
        @alternatingCounter = 1


  # A static click means they didn't move, so don't do anything
  # We don't want stray points
  click:
    all: ->

  startDrag:
    all: (e) ->
      @beginNewLine(e)

  continueDrag:
    all: (e) ->
      #ui.annotations.drawDot(e.canvasPosnZoomed, 'rgba(0,0,0,0.2)')
      if @eventCounter is @frequency
        @addPoint(e)
        @eventCounter = 0
      else
        @eventCounter += 1


  stopDrag:
    all: ->
      #ui.selection.elements.select @line
      # (meh)
      @line.redrawHoverTargets()
      archive.addExistenceEvent(@line.rep)
      @line = undefined

###


   o
    \
     \
      \
       \
        \
         \
          \
           \
            o

###


tools.line = new Tool

  drawing: false
  cssid: 'crosshair'
  id: 'line'

  offsetX: 7
  offsetY: 7

  activateModifier: (modifier) ->
    switch modifier
      when "shift"
        op = @initialDragPosn
        if op?
          ui.snap.presets.every45(op, "canvas")

  deactivateModifier: (modifier) ->
    switch modifier
      when "shift"
        ui.snap.toNothing()

  tearDown: ->
    @drawing = false

  startDrag:
    all: (e) ->
      @beginNewLine(e)
      @initialDragPosn = e.canvasPosnZoomed


  beginNewLine: (e) ->
    p = e.canvasPosnZoomed
    @drawing = new Path(
      stroke: ui.stroke
      fill:   ui.fill
      'stroke-width': ui.uistate.get('strokeWidth')
      d: "M#{e.canvasX},#{e.canvasY} L#{e.canvasX},#{e.canvasY}")
    @drawing.appendTo('#main')
    @drawing.commit()


  continueDrag:
    all: (e) ->
      p = e.canvasPosnZoomed
      @drawing.points.last.x = p.x
      @drawing.points.last.y = p.y
      @drawing.commit()


  stopDrag:
    all: ->
      @drawing.redrawHoverTargets()
      @drawing.commit()
      ui.selection.elements.select @drawing







###

  Arbitrary Shape Tool

  A subclass of Tool that performs a simple action: draw a hard-coded shape
  from the startDrag point to the endDrag point.

  Basically this is an abstraction. It's used by the Ellipse and Rectangle tools.

###


class ArbitraryShapeTool extends Tool

  constructor: (attrs) ->
    super attrs

  drawing: false
  cssid: 'crosshair'

  offsetX: 7
  offsetY: 7

  ignoreDoubleclick: true

  started: null

  # This is what gets defined as the shape it draws.
  # It should be a string of points
  template: null

  tearDown: ->
    @drawing = false

  startDrag:
    all: (e) ->
      @started = e.canvasPosnZoomed

      @drawing = new Path
        stroke: ui.stroke.clone()
        fill: ui.fill.clone()
        'stroke-width': ui.uistate.get('strokeWidth')
        d: @template

      @drawing.virgin = @virgin()

      @drawing.hide()
      @drawing.appendTo "#main"
      @drawing.commit()


  continueDrag:
    all: (e) ->
      ftb = new Bounds(e.canvasPosnZoomed, @started)
      if e.shiftKey
        ftb = new Bounds(@started, e.canvasPosnZoomed.squareUpAgainst @started)
      if e.altKey
        ftb.centerOn(@started)
        ftb.scale(2, 2, @started)

      @drawing.show()
      @drawing.fitToBounds ftb
      @drawing.commit()

  stopDrag:
    all: ->
      @drawing.cleanUpPoints()
      archive.addExistenceEvent(@drawing.rep)

      @drawing.redrawHoverTargets()

      ui.selection.elements.select @drawing

      @drawing = false



###

  Ellipse

###

tools.ellipse = new ArbitraryShapeTool
  id: "ellipse"
  template: "M0-0.1c0.055228,0,0.1,0.045,0.1,0.1S0.055,0.1,0,0.1S-0.1,0.055-0.1,0S-0.055-0.1,0-0.1z"
  virgin: -> new Ellipse
    cx: 0.0
    cy: 0.0
    rx: 0.1
    ry: 0.1
###

  Ellipse

###

tools.rectangle = new ArbitraryShapeTool
  id: "rectangle"
  template: "M-0.1,-0.1 L0.1,-0.1 L0.1,0.1 L-0.1,0.1 L-0.1,-0.1z"
  virgin: -> new Rect
    x: -0.1
    y: -0.1
    width: 0.2
    height: 0.2

###

  Type tool

###



tools.type = new Tool

  cssid: 'type'
  id: 'type'

  typingInto: undefined

  tearDown: ->
    @typingInto = undefined

  addNode: (e) ->
    if @typingInto?
      @typingInto.displayMode()
      archive.addExistenceEvent(@typingInto.rep)
      @typingInto = undefined
    else
      ui.selection.elements.deselectAll()
      @typingInto = new Text
        x: e.canvasPosnZoomed.x
        y: e.canvasPosnZoomed.y
        fill: ui.fill
        stroke: ui.stroke

      @typingInto.appendTo('#main')
      @typingInto.selectAll()


  click:
    elem: (e) ->
      if e.elem.type is "text"
        e.elem.editableMode()
        e.elem.textEditable.focus()
      else
        @click.all.call tools.type, e

    all: (e) ->
      @addNode e

  startDrag:
    elem: (e) ->
      console.log(e.elem)
      if e.elem.type is "text"
        e.elem.editableMode()
        e.elem.textEditable.focus()


  stopDrag:
    all: (e) ->
      unless e.elem?.type is "text"
        @addNode e

###

  Rotate

###

tools.rotate = new Tool

  cssid: 'crosshair'

  id: 'rotate'

  offsetX: 7
  offsetY: 7

  setup: ->
    @$rndo = $("#r-nd-o")
    ui.transformer.onRotatingMode()
    @setCenter ui.transformer.center()
    ui.selection.elements.on 'changed', =>
      @$rndo.hide()


  tearDown: ->
    @setCenter undefined
    ui.transformer.offRotatingMode()



  lastAngle: undefined


  setCenter: (@center) ->
    return if ui.selection.elements.all.length is 0
    if @center?
      @$rndo.show().css
        left: (@center.x - 6).px()
        top: (@center.y - 6).px()
    else
      @$rndo.hide()



  click:
    all: (e) ->
      @setCenter new Posn(e.canvasX, e.canvasY)


  startDrag:
    all: (e) ->
      if @center is undefined
        @setCenter ui.transformer.center()
      @lastAngle = new Posn(e.canvasX, e.canvasY)


  continueDrag:
    all: (e) ->
      currentAngle = new Posn(e.canvasX, e.canvasY).angle360(@center)
      change = currentAngle - @lastAngle

      if not isNaN change
        ui.selection.rotate change, @center

      @lastAngle = currentAngle


  stopDrag:
    all: (e) ->
      @lastAngle = undefined
      ui.selection.elements.all.map (p) ->
        p.redrawHoverTargets()

      archive.addMapEvent("rotate", ui.selection.elements.zIndexes(), {
        angle: ui.transformer.accumA
        origin: ui.transformer.origin
      })

      # A rotation has stopped so reset the accumulated values
      ui.transformer.resetAccum()

###

  Zoom tool

###


tools.zoom = new Tool

  offsetX: 5
  offsetY: 5

  cssid: 'zoom'
  id: 'zoom'

  ignoreDoubleclick: true

  click:
    all: (e) ->
      if ui.hotkeys.modifiersDown.has "alt"
        ui.canvas.zoomOut(e.clientPosn)
      else
        ui.canvas.zoomIn(e.clientPosn)
      ui.refreshAfterZoom()

  rightClick:
    all: (e) -> ui.canvas.zoom100()

  startDrag:
    all: (e) ->
      ui.dragSelection.start(new Posn e)


  continueDrag:
    all: (e) ->
      ui.dragSelection.move(new Posn e)


  stopDrag:
    all: (e) ->
      if ui.hotkeys.modifiersDown.has "alt"
        ui.dragSelection.end( ->  ui.canvas.zoom100())
      else if e.which is 1
        ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)
      else if e.which is 3
        ui.dragSelection.end(-> ui.canvas.zoomOut())
        #ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)

      for elem in ui.elements
        elem.refreshUI()


###

  Eyedropper

###


tools.eyedropper = new Tool

  offsetX: 1
  offsetY: 15

  cssid: 'eyedropper'
  id: 'eyedropper'


  click:
    elem_hoverTarget_point: (e) ->
      ui.utilities.color.sample e.elem
      for elem in ui.selection.elements.all
        elem.eyedropper e.elem
    background: (e) ->
      for elem in ui.selection.elements.all
        elem.data.fill = ui.colors.white
        elem.data.stroke = ui.colors.null
        elem.commit()

###

  A modular frontend for the file storage service API.
  Communicates with the backend version in Meowset.

  Basically just does AJAX calls.

###

window.services = {}

class Service
  constructor: (attrs) ->
    for own i, x of attrs
      @[i] = x
    if @setup?
      setup.push => @setup()

  fileSystem:
    contents: {}
    is_dir: true
    path: "/"

  open: ->
    # Standard function
    ui.gallery.open @

  getSVGs: (ok) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/svgs"
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
      success: (response) =>
        ok(response.map((f) =>
          fl = new File().fromService(@)(f.key)
          fl.modified = f.last_modified
          fl.thumbnail = f.thumbnail
          fl
        ))

  getSaveLocations: (at, success) ->
    path = at.split("/").slice 1
    traversed = @fileSystem.contents

    # See if we already have this shit cached locally.
    # If we do, then chill.
    # If not, then chall.
    if path[0] != "" # This means the path is just the root: "/"
      for dir in path
        dir = path[0]
        if traversed[dir]?
          traversed = traversed[dir].contents
          if Object.keys(traversed).length != 0
            path = path.slice 1
          else
            break
    if path.length is 0
      # Chill
      if traversed.empty
        folders = []
        files = []
      else
        all = objectValues(traversed)
        folders = all.filter (x) -> x.is_dir
        files = all.filter (x) -> not x.is_dir
      return success(folders, files)

    else
      # Chall
      $.ajax
        url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/metadata",
        type: "GET"
        dataType: "json"
        data:
          session_token: ui.account.session_token
          path: at
          pluck: "save_locations"
          contentsonly: true
        success: (response) ->
          folders = response.filter((x) -> x.is_dir)
          files = response.filter((x) -> not x.is_dir)

          if folders.length + files.length == 0
            traversed.empty = true
          else
            for folder in folders
              traversed[folder.path.match(/\/[^\/]*$/)[0].substring(1)] =
                contents: {}
                is_dir: true
                path: "#{folder.path}"

          for file in files
            traversed[file.path.match(/\/[^\/]*$/)[0].substring(1)] =
              is_dir: false
              path: "#{file.path}"

          success(folders, files)



  get: (key, success) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/get",
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        path: key
      success: (response) ->
        success(response)


  put: (key, contents, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/put"
      type: "POST"
      dataType: "json"
      data:
        contents: contents
        session_token: ui.account.session_token
        fn: key
      success: (response) ->
        success(response)

  contents: (path, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/metadata"
      type: "GET"
      dataType: "json"
      data:
        contentsonly: true
        session_token: ui.account.session_token
        path: path
      success: (response) ->
        success(response)

  defaultName: (path, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/default-name"
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        path: path
      success: (response) ->
        success(response.name)

  putHistory: (key, contents, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/put-history"
      type: "POST"
      dataType: "json"
      data:
        contents: contents
        session_token: ui.account.session_token
        fn: key
      success: (response) ->
        success(response)


###

  Storing files in localStorage!
  SVG files are so lightweight that for now we'll just do this as a nice
  2.5mb local storage solution, since only Google has the balls to implement
  the FileSystem API.

###

services.local = new Service

  name: "local"

  # This doesn't even make calls to Meowset so it doesn't have a module name
  #
  # Therefore it also has to duplicate the root service methods
  # in its own implementation using localStorage.
  #
  # This service is sort of a bastard child, it only halfway matches
  # the Service class implentation, but we're still going to keep it
  # as such because it lets us cut a few corners as opposed to
  # writing it as a completely unique Object.

  setup: ->
    if localStorage.getItem("local-files") is null
      # This should only happen the first time they open Mondy.
      localStorage.setItem("local-files", "[]")
      localStorage.removeItem("file-content")
      localStorage.removeItem("file-metadata")
      # Set up demo files
      for title, contents of demoFiles
        f = new LocalFile("#{title}.svg").set(contents).put()


  activate: ->


  lastKey: undefined


  getSVGs: (ok = ->) ->
    # Return all the stored LocalFiles as an array of objects
    files = []

    for name in @files()
      files.push(new LocalFile name)

    ok files


  getSaveLocations: (path, ok =->) ->
    ok {}, @files().map (f) -> { path: "/#{f}" }


  get: (key, ok) ->
    # Pull out the file and if it isn't null run the success callback
    file = localStorage.getItem("local-#{key}")
    archiveData = localStorage.getItem("local-#{key}-archive")

    if file != null
      ok { contents: file, archive: archiveData }
    else
      # File not found. Probably a new file being made under this name.
      return


  put: (name = ui.file.name, contents = io.makeFile(), ok = ->) ->
    # Just provide this with the contents, no path.
    # Keeping the parameters the same so it works
    # with methods that use the other Services.

    name = name.replace(/^\//gi, '')

    # Save the contents under the name
    localStorage.setItem("local-#{name}", contents)

    # Save the history as well
    localStorage.setItem("local-#{name}-archive", archive.toString())

    # Keep track of the file
    files = @files()
    if not files.has(name)
      files.push name
    @files(files)

    ok()


  delete: (name) ->
    # Delete the localStorage item
    localStorage.removeItem("local-#{name}")
    localStorage.removeItem("local-#{name}-archive")

    # Stop tracking it
    files = @files()
    files = files.remove name
    @files(files)


  deleteAll: ->
    # WARNING
    # This deletes all locally stored files homie.
    # Use with discretion.
    @files().map (name) => @delete name


  files: (updated) ->
    # This method does two things in one:
    # If no argument is provided, it returns the currently stored files.
    # Otherwise, it updates the currently stored files with the given array.

    if updated?
      localStorage.setItem("local-files", JSON.stringify(updated))
      return updated
    else
      return JSON.parse(localStorage.getItem("local-files"))


  nextDefaultName: ->
    files = @files()
    untitleds = files.filter((f) -> f.substring(0, 9) == "untitled-")
    nums = untitleds.map((name) -> name.match(/\d+/gi)[0])
      .map((num) -> parseInt(num, 10))

    if untitleds.length is 0
      if not files.has "untitled.svg"
        return "untitled.svg"

    x = 1

    while true
      if nums.has x
        x += 1
      else
        return "untitled-#{x}.svg"





  clearAllLocalHistory: ->
    # WARNING: this is permanent
    for file in @files()
      localStorage.removeItem("local-#{file}-archive")





setup.push -> services.local.setup()

###

  Permalink file service
  Works closely with local file service

###


services.permalink = new Service

  name: "permalink"


  open: -> services.local.open()


  get: (public_key, success) ->
    $.getJSON "#{SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/get",
      { public_key: public_key },
      (response) ->
        success(
          contents: response.content
          file_name: response.file_name
          readonly: response.readonly
        )
        trackEvent "Permalinks", "Open", public_key


  put: (public_key = undefined, contents = io.makeFile(), success = (->), emails = "") ->
    thumb = io.makePNGURI(ui.elements, 400)

    data =
      file_name: ui.file.name
      svg: contents
      thumb: thumb
      emails: emails

    if public_key?
      data.public_key = public_key

    if ui.account.session_token?
      data['session_token'] = ui.account.session_token

    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/put"
      type: "POST"
      dataType: "json"
      data: data
      success: (response) ->
        if !public_key?
          new PermalinkFile(response.public_key).use()
          # If no public_key was given, we created a new permalink.
          # So redirect the browser to that new permanent url.
          switch public_key
            when ""
              trackEvent "Permalinks", "Create", response.public_key
            else
              trackEvent "Permalinks", "Save", response.public_key
        else
          console.log "saved"
        success?()

###

  Dropbox, baby

###


services.dropbox = new Service

  name: "Dropbox"

  module: "poletto"

  tease: ->
    # Show it off
    ui.menu.items.dropboxConnect.show()

  activate: ->
    ui.menu.items.dropboxConnect.hide()
    if not ui.account.services.has "dropbox"
      ui.account.services.push "dropbox"

  disable: ->
    ui.menu.items.dropboxConnect.disable()

  enable: ->
    ui.menu.items.dropboxConnect.enable()

###

  Helper geometry layer

###

annotations =

  uiMainColor: '#4982E0'

  drawLine: (a, b, stroke = @uiMainColor) ->
    return if not dom.main

    line = new Line(
      x1: a.x
      y1: a.y
      x2: b.x
      y2: b.y
      fill: 'none'
      stroke: stroke
    )

    line.commit()
    line.appendTo('svg#annotations', false)
    line

  drawDot: (p, fill = @uiMainColor, r = 3) ->
    return if not dom.main

    dot = new Circle(
      cx: p.x
      cy: p.y
      r: r
      fill: fill
      stroke: 'none'
    )

    dot.commit()
    dot.appendTo('svg#annotations', false)
    dot

  drawDots: (posns, color, r) ->
    posns.forEach (posn) =>
      @drawDot posn, color, r

  clear: ->
    $("#annotations").empty()


ui.annotations = annotations
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
###

  The logged-in account

    strings
      email:         user's email address
      session_token: secret token used to verify their logged-in session

    lists
      services: which services they have access to
                default:
                  'local'
                possibly also:
                  'dropbox'
                  (more to come)

      active:     if they should get full account features
      subscribed: if they actually have an active card on file

###

ui.account =

  email: ""
  session_token: ""

  services: ['local']

  valueOf: -> @email or "anon"

  uiAnonymous: ->
    # Hide and disable things not available to anonymous users.
    services.dropbox.tease().disable()
    ui.menu.items.shareAsLink.enable()
    ui.menu.items.downloadSVG.enable()
    ui.menu.menus.login.show()
    ui.menu.menus.register.show()

  uiLoggedIn: ->
    services.dropbox.tease().enable()
    ui.menu.items.shareAsLink.enable()
    ui.menu.items.downloadSVG.enable()
    ui.menu.menus.login.groupHide()
    ui.menu.menus.account.text(@email).groupShow()

  checkSession: ->
    # See if the user is logged in. If so, set up the UI to reflect that.
    @session_token = localStorage.getItem("session_token")

    # TODO Hackish. Why is this here?
    if @session_token
      $.ajax(
        url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/persist-session"
        type: "POST"
        dataType: "json"
        data:
          session_token: @session_token
        success: (response) =>
          if response.anon?
            @uiAnonymous()
          else
            @processLogin response
          trackEvent "User", "Persist session"

        error: =>
          @uiAnonymous()
      )

    else
      @uiAnonymous()

  login: (email, passwd) ->

    $("#login-mg input").each ->
      $(@).disable()

    $.ajax(
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/login"
      type: "POST"
      dataType: "json"
      data:
        email: email
        passwd: passwd
      success: (response) =>
        # Save the session_token for later <3
        @processLogin response

        if response.trial_remaining? > 0
          ui.menu.menus.account.openDropdown()

        $("#login-mg input").each ->
          $(@).enable()

        # Track to GA
        trackEvent "User", "Login"

      error: (data) =>
        data = JSON.parse(data.responseText)
        $("#submit-login").error(data.error)
        trackEvent "User", "Login error", data.error


      complete: ->
        $("#login-mg input").each ->
          $(@).enable()

    )

  processLogin: (response) ->

    $.extend(@, response)

    # Store the session token locally
    localStorage.setItem("session_token", @session_token)

    ui.menu.menus.login.groupHide()
    ui.menu.menus.register.groupHide()
    ui.menu.menus.account.show().text(@email)

    ui.menu.closeAllDropdowns()

    @uiLoggedIn()

    #ui.file.getNewestVersion()

    if response.services?
      for s in response.services
        services[s].activate()
    else
      # Advertise all the non-default services.
      # For now it's just Dropbox.
      services.dropbox.tease()



  logout: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/logout"
      type: "POST"
      dataType: "json"
      data:
        session_token: @session_token
      success: (response) =>
        @session_token = undefined
        localStorage.removeItem("session_token")

        # Track to GA
        trackEvent "User", "Logout"

        @uiAnonymous()

        ui.menu.menus.account.groupHide()
        ui.menu.menus.login.groupShow()
        ui.menu.menus.register.groupShow()

  checkServices: ->
    $.getJSON "#{SETTINGS.MEOWSET.ENDPOINT}/user/check-services",
      { session_token: @session_token },
      (data) ->
        if data.dropbox
          services.dropbox.activate()


  create: (name, email, passwd) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/user/register"
      type: "POST"
      dataType: "json"
      data:
        name: name
        email: email
        passwd: passwd
      success: (data) =>
        trackEvent "User", "Create", "(#{name} , #{email})"
        @login email, passwd
        ui.menu.closeAllDropdowns()
      error: (data) =>
        data = JSON.parse(data.responseText)
        $("#submit-registration").error(data.error)


setup.push ->
  ui.account.checkSession()
  ui.refreshUtilities() # Hackish spot for this


url =
  actions:
    p: (public_key) ->
      ui.canvas.hide()
      services.permalink.get(public_key, (response) ->
        ui.canvas.show()
        io.parseAndAppend(response.contents)

        permalink = new PermalinkFile(public_key)
        permalink.use()
        permalink.readonly = response.readonly

        #ui.file.define(services.permalink, public_key, response.file_name)
        ui.canvas.centerOn(ui.window.center())
      )

    url: (targetURL) ->
      ui.menu.items.openURL.openURL(targetURL)

  parse: ->
    url_parameters = document.location.search.replace(/\/$/, "")
    parameters = url_parameters.substring(1).split "&"
    for param in parameters
      param = param.split "="
      key = param[0]
      val = param[1]
      @actions[key]?(val)

setup.push -> url.parse()
###

  Managing the persistent file state we save in the browser.


  This is like a psuedo-file. It saves and shows you whatever you had open last time
  right away with localStorage. This just makes the experience feel faster and eliminates
  the amount of time people will have to look at a blank screen.

  The only time this doesn't happen is with permalinks. It's unlikely you will already
  have had the same permalink open right before clicking on one (does that make sense?)

  Since local files load instantenly, the only real lag is with files from Dropbox.
  (And Google Drive/SkyDrive in the future)

  Doesn't matter: before anyone gets clicking on their file the true file should
  have loaded even if it's from Dropbox.

###

ui.browserFile =
  save: (force = false) ->
    return if ui.afk.active and (not force) # Don't bother if the user is afk

    if not ui.file?
      new LocalFile(services.local.nextDefaultName()).use()

    return if ui.file.service is services.permalink

    # Save some metadata regarding the file and state of the UI
    localStorage.setItem("file-metadata", ui.file.toString())

    # Save everything the user has done
    localStorage.setItem("file-content", io.makeFile())
    localStorage.setItem("file-archive", archive.toString())

  load: () ->

    fileContent = localStorage.getItem("file-content")

    fileArchive = localStorage.getItem("file-archive")

    if fileContent?
      io.parseAndAppend(localStorage.getItem("file-content"))

      # Get the file metadata from localStorage, and build the most recently open file.
      fileMetadata = JSON.parse(localStorage.getItem("file-metadata")) or {}

      # Default to untitled if there's no file data saved whatsoever
      if not fileMetadata.name?
        fileMetadata.name = "untitled.svg"

      # Given the service and key, rebuild the file and use() it.
      service = fileMetadata.service.toLowerCase()
      new File().fromService(services[service])(fileMetadata.key).use()

      if fileArchive?
        archive.loadFromString(fileArchive, false)

    else
      # If for whatever reason there is no browser file saved
      # just create a new local file to work from
      new LocalFile(services.local.nextDefaultName()).use()
      ui.file.save()


# Set up an interval to save the browser file every second.
setup.push ->
  ui.browserFile.load() if !(ui.file?)

  setInterval ->
    ui.browserFile.save()
  , 1000


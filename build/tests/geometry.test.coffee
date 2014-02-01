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
CONSTANTS =
  MATCHERS:
    POINT: /[MLCSHV][\-\de\.\,\-\s]+/gi


SETTINGS =
  # Flag: are we in production?
  PRODUCTION: !(/localhost/.test document.location.host)
  MEOWSET:
    # Show UI for backend features?
    AVAILABLE: true
    # Backend endpoint
    ENDPOINT: if @PRODUCTION then "http://localhost:8000" else "http://meowset.mondrian.io"

  SVG_NAMESPACE: "http://www.w3.org/2000/svg"

  # Maths
  MATH:
    POINT_DECIMAL_PLACES: 5
    POINT_ROUND_DGAF: 1e-5

  # Cursor
  DOUBLE_CLICK_THRESHOLD: 600

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
        newlyDefined = new {
          rotate: RotateTransformation
          scale:  ScaleTransformation
        }[keyword]().parse(op)
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

    return if @zoomLevel is 1.0

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
    # Polygon or Path (same principle)
    # Draw a horizontal ray starting at this posn. If it intersects the lines made by
    # the shape an odd number of times, the posn's inside of it.
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
      # new Point(point string, owner, prec)
      # Example in PointsList.stringToAlop
      prec = @owner if @owner?
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
    @at = from.at
    @prec = from.prec
    @succ = from.succ
    @prec.succ = @
    @succ.prec = @
    @owner = from.owner
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
      alop = @stringToAlop alop

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

  stringToAlop: (points) ->
    # Match for generic points starting with anchor letters,
    # then map the list into new Point(match)

    results = []

    all_matches = points.match(CONSTANTS.MATCHERS.POINT)

    for point in all_matches
      p = new Point(point, @owner, previous)

      if p instanceof Point
        if previous?
          p.setPrec previous
        previous = p

        if (p instanceof SmoothTo) and (@owner instanceof Point)
          p.setPrec @owner

        results.push p

      else if p instanceof Array
        # There's an edge case where you can get an array of a MoveTo followed by LineTos.
        # Terrible function signature design, I know
        # TODO fix this hack garbage
        if previous?
          p[0].setPrec previous
          p.reduce (a, b) ->
            b.setPrec a

        results = results.concat p

    results


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

    print '---------------'

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

    print pointsWalking.all().length
    print pointsAlternate.all().length

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
            print "succ too close"

          if otherSamePoint.within(1e-2, otherSamePoint.prec)
            precTooClose = true
            print "prec too close"

          if !(optionA.midPoint().insideOf(current))
            # ...then we want to move forward
            desiredPoint = otherSamePoint.succ

          else if !(optionB.midPoint().insideOf(current))
            # ...then we want to move backward, so we'll have to reverse the points.
            print "REVERSING"
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
            print 'swedep'
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



class Test
  constructor: (@expect, @val, @toEqual) ->
    # Run it, and time that
    begin = new Date()
    @result = @val()
    end = new Date()
    @runtime = end.valueOf() - begin.valueOf()

    if @result.toString() == @toEqual.toString()
      @printSuccess()
    else
      @printFailure()

  print: (result, success) ->
    q("body").innerHTML += "<div class=\"#{if success then "success" else "failed"}\">#{result}</div>"

  printSuccess: ->
    @print("#{@expect} <b>success</b> in #{@runtime}ms", true)

  printFailure: ->
    @print("#{@expect} <b>failed</b> in #{@runtime}ms\n  Expected: #{@toEqual}\n  Got:      #{@result}", false)

# Setup

p1 = new Posn(10, 20)
p2 = new Posn(50, 50)
p3 = new Posn(56.375, 920.505)
p4 = new Posn(78.2, 2.4)

poly1 = new Polynomial([-8556.40625, 9786.5625, 1565.765625, -1798.09375])
poly2 = new Polynomial([-8556.40625, 9786.5625, 1565.765625, -1798.09375])
poly3 = new Polynomial([-2521.40325, 2015.7625, -2298.04175])

hugepoly = new Polynomial([
  819552855133368,
  -4059695028789612,
  9135238247204166,
  -11299205179679670,
  7817505757508070,
  -2752582173072824,
  -184979604186062.2,
  759898652221607.1,
  -250714946036920.75,
  6934793103614.088
])

blob1 = new Path(
  d: """M207.337,68.753c-39.326,19.102-65.168,95.506-47.191,106.742
        s78.652,53.933,104.495,28.09s47.191-133.708,30.337-134.832
        S207.337,68.753,207.337,68.753z"""
)
blob2 = new Path(
  d: """M346.664,158.641c-50.562-8.989-113.483-30.336-123.596-7.865
s-27.439,21.987-9.787,54.252s54.731,79.456,69.338,65.973S346.664,158.641,346.664,158.641z"""
)

ln1 = new LineSegment(new Posn(0,0), new Posn(100,100))
ln110 = new LineSegment(new Posn(0,0), new Posn(100,110))
ln2 = new LineSegment(new Posn(0,100), new Posn(100,0))
ln3 = new LineSegment(new Posn(47.354,107.08), new Posn(133.065,161.985))
ln4 = new LineSegment(new Posn(29.541,146.268), new Posn(150.459,120.072))
ln5 = new LineSegment(new Posn(315, 309), new Posn(315, 228))
ln6 = new LineSegment(new Posn(350, 170), new Posn(400, 250))
ln7 = new LineSegment(new Posn(145.5, 58), new Posn(193.375, 23.125))
ln8 = new LineSegment(new Posn(148.5, 19.625), new Posn(198.375, 58.875))

bz = new CubicBezier(new Posn(0,50), new Posn(200,150), new Posn(100, 50), new Posn(50,50))
bz1 = new CubicBezier(new Posn(400, 200), new Posn(300, 185), new Posn(265, 230), new Posn(285, 250))
bz2 = new CubicBezier(new Posn(154, 14.25), new Posn(138.25, 36.625), new Posn(230.625, 48.375), new Posn(165.875, 64))
# These two intersect twice:
bz3 = new CubicBezier(new Posn(0, 0), new Posn(66.368, 66.368), new Posn(113.769, 70.044), new Posn(183.813, 0))
bz4 = new CubicBezier(new Posn(0, 76.746), new Posn(70.043, 6.702), new Posn(117.444, 10.378), new Posn(183.813, 76.746))
# So do these two:
bz5 = new CubicBezier(new Posn(20, 91.738), new Posn(59.5, 168.738), new Posn(107, -100.762), new Posn(107, 91.738))
bz6 = new CubicBezier(new Posn(46.148, 91.882), new Posn(78.648, 174.382), new Posn(69.648, -66.618), new Posn(88.148, 49.882))

bz7 = new CubicBezier(new Posn(583.4471131233216,244), new Posn(507.81821773433853,338), new Posn(670.0103920088109,183), new Posn(618.9836028774718,267))
bz8 = new CubicBezier(new Posn(577,246), new Posn(754,248), new Posn(446,267), new Posn(594,267))

bz9 = new CubicBezier(new Posn(537, 89), new Posn(479, 126), new Posn(477, 206), new Posn(557, 166))
bz10 = new CubicBezier(new Posn(517, 168), new Posn(536, 211), new Posn(472, 241), new Posn(463, 183))

ell1 = new Ellipse(
  cx: 100,
  cy: 100,
  rx: 50,
  ry: 60)

pth1 = new Path(
  stroke: '#F179AF'
  fill: 'none'
  d: "M0,0C80-80,200-85,300,0S165,125 165,130L0,0")


# Tests

new Test('Posn reflection',
  (-> p1.reflect(p2)), new Posn(90, 80))

new Test('Posn reflection',
  (-> p2.reflect(p1)), new Posn(-30, -10))

new Test('Posn reflection',
  (-> p1.reflect(p1)), p1)

new Test('Posn linear interpolation',
  (-> p2.lerp(p3, 0.5)), new Posn(53.1875, 485.2525))

new Test('Posn linear interpolation (lerp)',
  (-> p1.lerp(p2, 0.8)), new Posn(42, 44))

new Test('Posn add to Posn',
  (-> p1.add(p2)), new Posn(60, 70))

new Test('Posn add to Posn',
  (-> p2.add(p1)), new Posn(60, 70))

new Test('Posn add to Posn',
  (-> p2.add(p3)), new Posn(106.375, 970.505))

#  new Test('Push Posn after Posn into PointsList',
#    (-> new PointsList([p1,p2,p4]).push(p3, p4)), new PointsList([p1,p2,p3,p4]))

new Test('Push Posn into end of PointsList',
  (-> new PointsList([p1,p2,p4]).push(p3)), new PointsList([p1,p2,p4,p3]))

new Test('Validate links in PointsList after push',
  (-> new PointsList([p1,p2,p4]).push(p3).firstSegment.validateLinks()), true)

new Test('PointsList.toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).toString()), "M10,10 L45,60 C100,120 300,350 90,80")

new Test('PointsList.relative().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60)]).relative().toString()), "M10,10 l35,50")

new Test('PointsList.relative().absolute().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60)]).relative().absolute().toString()), "M10,10 L45,60")

new Test('PointsList.relative().toString()',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().toString()), "M10,10 l35,50 c55,60 255,290 45,20")

new Test('PointsList.relative().absolute() consistency',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().absolute().toString()), "M10,10 L45,60 C100,120 300,350 90,80")

new Test('PointsList.relative().absolute().relative() consistency',
  (-> new PointsList([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)]).relative().absolute().relative().toString()), "M10,10 l35,50 c55,60 255,290 45,20")

pointsSegment = new PointsSegment([new MoveTo(10,10), new LineTo(45, 60), new CurveTo(100,120,300,350,90,80)])

new Test('LineTo.toLineSegment',
  (-> pointsSegment.moveMoveTo(pointsSegment.points[2])), '')

new Test('new Path with mix of absolute and relative turns them absolute',
  (-> new Path(d: 'M10,10l30,40C50,60,70,80,90,100L40,40l50,50').points),
  'M10,10 L40,50 C50,60 70,80 90,100 L40,40 L90,90')

new Test('Cubic polynomial roots',
  (-> poly1.roots()), [1.143019385425934,-0.4284039167874206,0.42915473278220573])

new Test('Cubic Polynomial eval(3)',
  (-> poly2.eval(3)), -140044.703125)

new Test('Cubic Polynomial roots()',
  (-> poly2.roots()), [1.143019385425934, -0.4284039167874206, 0.42915473278220573])

new Test('Cubic Polynomial derivative()',
  (-> poly2.derivative().coefs), [1565.765625, 19573.125, -25669.21875])

new Test('Cubic Polynomial add()',
  (-> poly2.add(poly3).coefs), [-4096.1355, 3581.528125, 7265.159250000001, -8556.40625])

new Test('Cubic Polynomial bisection()',
  (-> poly2.bisection(0, 1)), 0.4291543960571289)

new Test('Cubic Polynomial rootsInterval()',
  (-> poly2.rootsInterval(0, 1)), [0.42915499960917775])

new Test('Huge 10-coefficient Polynomial rootsInterval()',
  (-> hugepoly.rootsInterval(0, 1)), [0.030439317609131572, 0.4865324847206747, 0.9484604318106424])

new Test('Cubic Bezier intersects LineSegment',
  (-> bz.intersectionWithLineSegment(ln1)), [new Posn(89.20468634936002,89.20468634935999),new Posn(50.00000000000004,50)])

new Test('Cubic Bezier intersects LineSegment',
  (-> bz2.intersectionWithLineSegment(ln7)), [new Posn(172.4987019088338,38.33253829617591)])

new Test('Cubic Bezier xRange',
  (-> bz2.xRange()), new Range(152.169, 189.1624))

new Test('Cubic Bezier yRange',
  (-> bz2.yRange()), new Range(14.25, 64))

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz3.intersection(bz4)), [new Posn(47.90415473177786,38.43978101182949), new Posn(135.908264922779,38.30620344719945)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz5.intersection(bz6)), [new Posn(49.00242378510562,98.5357189974139), new Posn(72.06070160020182,60.998066741193696), new Posn(85.49725443971622,34.62459876819878)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz4.intersection(bz6)), [new Posn(76.26664017448732,27.28211939958595), new Posn(83.63548811847966,26.07062056075148)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz7.intersection(bz8)), [new Posn(581.7959971383461,246.0599451520868), new Posn(611.5468559995447,246.8269484357895),
                               new Posn(628.4619186189253,248.10341235722106), new Posn(626.8506058391803,252.40738666580168),
                               new Posn(594.6339715885225,257.48879390700273), new Posn(570.4713158190336,260.85017444139413),
                               new Posn(566.5128682640187,266.6452081770431),new Posn(580.4224295094082,266.93524733161775)])

new Test('Cubic Bezier intersection with Cubic Bezier',
  (-> bz9.intersection(bz10)), [new Posn(519.8386947286634,176.92274339432637)])

new Test('Cubic Bezier findPercentageOfPoint',
  (-> bz4.findPercentageOfPoint(new Posn(76.2666,27.2822))), 0.4012451171875)

new Test('Cubic Bezier splitAt(0.5)',
  (-> bz4.splitAt(0.5)),
  [new CubicBezier(new Posn(0,76.746), new Posn(35.0215,41.724), new Posn(64.38250000000001,25.131999999999998), new Posn(93.28425000000001,25.591499999999996)),
   new CubicBezier(new Posn(93.28425000000001,25.591499999999996), new Posn(122.186,26.051), new Posn(150.6285,43.562), new Posn(183.813,76.746))])

new Test('Cubic Bezier split at array of 8 points',
  (-> bz7.splitAt([new Posn(581.796,246.06), new Posn(611.5469,246.8269), new Posn(628.462,248.1034), new Posn(626.8506,252.4073),
    new Posn(594.6339,257.4888), new Posn(570.4713,260.8502), new Posn(566.5128,266.6452), new Posn(580.4224,266.9353)])),
 [new CubicBezier(new Posn(583.4471131233216,244), new Posn(583.4471131233216,244), new Posn(583.4471131233216,244), new Posn(580.4224,266.9353)),
  new CubicBezier(new Posn(580.4224,266.9353), new Posn(580.4224,266.9353), new Posn(580.4224,266.9353), new Posn(581.796,246.06)),
  new CubicBezier(new Posn(581.796,246.06), new Posn(577.1272361534001,251.86236572265625), new Posn(573.3991175174485,256.6811900511384), new Posn(570.4713,260.8502)),
  new CubicBezier(new Posn(570.4713,260.8502), new Posn(568.9269994920714,262.951033418894), new Posn(567.6176030414922,264.80763180728394), new Posn(566.5128,266.6452)),
  new CubicBezier(new Posn(566.5128,266.6452), new Posn(552.8234755300266,287.00990433663344), new Posn(573.4200716299288,271.8794306807597), new Posn(594.6339,257.4888)),
  new CubicBezier(new Posn(594.6339,257.4888), new Posn(600.388768892232,253.66825105981948), new Posn(606.1884500827612,249.90638989498956), new Posn(611.5469,246.8269)),
  new CubicBezier(new Posn(611.5469,246.8269), new Posn(623.1194403147066,240.1897686797748), new Posn(631.4839224387921,237.6295916160095), new Posn(628.462,248.1034)),
  new CubicBezier(new Posn(628.462,248.1034), new Posn(628.1275684678864,249.26742641511547), new Posn(627.626792524753,250.63164231257952), new Posn(626.8506,252.4073)),
  new CubicBezier(new Posn(626.8506,252.4073), new Posn(625.3425898571114,255.92451126762697), new Posn(622.7412270743075,260.8142211589726), new Posn(618.9836028774718,267))])


new Test('Cubic Bezier splitAt(0.5)[0].splitAt(0.5)',
  (-> bz4.splitAt(0.5)[0].splitAt(0.5)),
  [new CubicBezier(new Posn(0,76.746), new Posn(17.51075,59.235), new Posn(33.606375,46.3315), new Posn(48.937031250000004,37.863187499999995)),
   new CubicBezier(new Posn(48.937031250000004,37.863187499999995), new Posn(64.26768750000001,29.394875), new Posn(78.83337500000002,25.361749999999997), new Posn(93.28425000000001,25.591499999999996))])

new Test('LineSegment intersects LineSegment',
  (-> ln1.intersection(ln2)), [new Posn(50,50)])

new Test('LineSegment intersects LineSegment',
  (-> ln3.intersection(ln4)), [new Posn(88.56712407541042,133.4804220853847)])

new Test('Path.lineSegments()',
  (-> pth1.lineSegments()), [
    new CubicBezier(new Posn(0,0), new Posn(80, -80), new Posn(200, -85), new Posn(300, 0))
    new CubicBezier(new Posn(300, 0), new Posn(400, 85), new Posn(165, 125), new Posn(165, 130))
    new LineSegment(new Posn(165, 130), new Posn(0,0))
    new LineSegment(new Posn(0,0), new Posn(0,0))
  ])

new Test('Path.lineSegments().map(bounds)',
  (-> pth1.lineSegments().map((x) -> x.bounds())),
  [new Bounds(0, -61.875, 300, 61.875), new Bounds(165, 0, 159.77671875, 130), new Bounds(0, 0, 165, 130), new Bounds(0, 0, 0, 0)])



new Test('Path.bounds()',
  (-> pth1.bounds()),
  [{"x":0,"y":-61.875,"width":324.77671875,"height":191.875,"x2":324.77671875,"y2":130,"xr":{"min":0,"max":324.77671875},"yr":{"min":-61.875,"max":130}}])


new Test('Ellipse primitive coords',
  (-> [ell1.top().x, ell1.top().y, ell1.right().x, ell1.right().y, ell1.bottom().x, ell1.bottom().y, ell1.left().x, ell1.left().y]), [100, 40, 150, 100, 100, 160, 50, 100])

print blob1.points.reverse().toString()





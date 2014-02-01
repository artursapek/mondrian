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


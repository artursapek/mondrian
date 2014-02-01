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

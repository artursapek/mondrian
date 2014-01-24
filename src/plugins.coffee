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


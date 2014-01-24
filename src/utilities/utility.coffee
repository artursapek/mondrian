
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



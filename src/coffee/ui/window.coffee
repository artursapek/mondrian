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

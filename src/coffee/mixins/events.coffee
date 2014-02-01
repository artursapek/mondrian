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


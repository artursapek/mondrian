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






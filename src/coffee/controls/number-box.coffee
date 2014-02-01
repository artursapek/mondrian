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



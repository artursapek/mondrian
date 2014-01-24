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


###

  Z-Index event

  Shift elements up or down in the z-axis

###



class ZIndexEvent extends Event
  constructor: (@indexesBefore, @indexesAfter, @direction) ->

    mf = (e) -> e.moveForward()
    mb = (e) -> e.moveBack()
    mff = (e) -> e.bringToFront()
    mbb = (e) -> e.sendToBack()

    console.log @direction

    switch @direction
      when "mf"
        @_do = mf
        @_undo = mb
      when "mb"
        @_do = mb
        @_undo = mf
      when "mff"
        @_do = mff
        @_undo = mbb
      when "mbb"
        @_do = mbb
        @_undo = mff

  do: ->
    for index in @indexesBefore
      @_do(queryElemByZIndex(index))
    ui.elements.sortByZIndex()

  undo: ->
    for index in @indexesAfter
      @_undo(queryElemByZIndex(index))
    ui.elements.sortByZIndex()

  toJSON: ->
    t: "z"
    ib: @indexesBefore
    ia: @indexesAfter
    d: @direction



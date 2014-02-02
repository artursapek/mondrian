###

  Type tool

###



tools.type = new Tool

  cssid: 'type'
  id: 'type'

  hotkey: 'T'

  typingInto: undefined

  tearDown: ->
    @typingInto = undefined

  addNode: (e) ->
    if @typingInto?
      @typingInto.displayMode()
      archive.addExistenceEvent(@typingInto.rep)
      @typingInto = undefined
    else
      ui.selection.elements.deselectAll()
      @typingInto = new Text
        x: e.canvasPosnZoomed.x
        y: e.canvasPosnZoomed.y
        fill: ui.fill
        stroke: ui.stroke

      @typingInto.appendTo('#main')
      @typingInto.selectAll()


  click:
    elem: (e) ->
      if e.elem.type is "text"
        e.elem.editableMode()
        e.elem.textEditable.focus()
      else
        @click.all.call tools.type, e

    all: (e) ->
      @addNode e

  startDrag:
    elem: (e) ->
      console.log(e.elem)
      if e.elem.type is "text"
        e.elem.editableMode()
        e.elem.textEditable.focus()


  stopDrag:
    all: (e) ->
      unless e.elem?.type is "text"
        @addNode e


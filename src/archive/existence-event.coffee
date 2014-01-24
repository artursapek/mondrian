###

  ExistenceEvent

  Created when a new element is created, or an element is deleted.
  Create and deletes elements in either direction for do/undo.
  Capable of handling many elements in one event.

###

class ExistenceEvent extends Event
  constructor: (elem) ->
    # Given elem, which can be either
    #
    #   int or array of ints:
    #     we're deleting the elem(s) at the z-index(s)
    #
    #   an SVG element or array of SVG elements:
    #     we're creating the element(s) at the highest z-index
    #     IN THE ORDER IN WHICH THEY APPEAR
    #
    # IMPORTANT: This should be called AFTER the element has actually been created


    # What we want to end up with is an object that looks like this:
    # {
    #   4: "<path d=\"....\"></path>"
    #   7: "<ellipse cx=\"...\"></ellipse>"
    # }
    #
    # And we need to save a @mode ("create" or "delete") that says which should
    # happen on DO. The opposite happens on UNDO. They are opposites after all.

    @args = {}

    if (elem instanceof Object) and not (elem instanceof Array)
      # If it's an object, it might just be a set of args
      # from a serialized copy of this event, so let's check
      # if it is.
      keys = Object.keys(elem)
      numberKeys = keys.filter (k) -> k.match(/^[\d]*$/gi) isnt null
      if keys.length is numberKeys.length
        # All the keys are just strings of digits,
        # so this is a previously serialized version of this event.
        @args = elem
        return @

    # Check if elem is a number
    if typeof elem is "number"
      # Get the element at that z-index. We're deleting it.
      e = queryElemByZIndex(elem)?.repToString()
      if e?
        @args[elem] = @cleanUpStringElem e
        @mode = "delete"
      else
        ui.selection.elements.all.map (e) -> e.delete()
        return

    else if not (elem instanceof Array)
      # Must be a string or DOM element now

      # If it's a DOM element, serialize it to a string
      if isSVGElement elem
        elem = new XMLSerializer().serializeToString elem

      # We're creating it, at the newest z-index.
      # Since we're just creating one this is simple.
      @args[ui.elements.length - 1] = @cleanUpStringElem elem
      @mode = "create"

    # Otherwise it must be an array, so do the same thing as above but with for-loops
    else
      # All the same checks
      if typeof elem[0] is "number"
        # Add many zindexes and query the element at that index every time
        for ind in elem
          e = queryElemByZIndex(elem)?.repToString()
          if e?
            @args[ind] = @cleanUpStringElem e
            @mode = "delete"
          else
            ui.selection.elements.all.map (e) -> e.delete()
            return

        @mode = "delete"

      else
        # Must be strings or DOM elements now

        # If it's DOM elements, turn them all into strings
        if isSVGElement elem[0]
          onCanvasAlready = !!elem[0].parentNode
          serializer = new XMLSerializer()
          elem = elem.map (e) -> serializer.serializeToString e

        # Increment new z-indexes starting at the first available one
        # Add the elements to args in the order in which they appear,
        # under the incrementing z-indexes

        # If they're already on the canvas
        newIndex = ui.elements.length

        if onCanvasAlready
          newIndex -= elem.length

        for e in elem
          @args[newIndex] = @cleanUpStringElem e
          ++ newIndex
        @mode = "create"


  cleanUpStringElem: (s) ->
    # Get rid of that shit we don't like
    s = s.replace(/uuid\=\"\w*\"/gi, "")
    s


  draw: ->
    # For each element in args, parse it and append it
    for own index, elem of @args
      index = parseInt index, 10
      parsed = io.parseElement($(elem))
      parsed.appendTo("#main")
      if not archive.simulating
        ui.selection.elements.deselectAll()
        ui.selection.elements.select [parsed]
      zi = parsed.zIndex()
      # Then adjust its z-index
      if zi isnt index
        if zi > index
          for i in [1..(zi - index)]
            parsed.moveBack()
        else if zi < index
          # This should never happen but why not
          for i in [1..(index - zi)]
            parsed.moveForward()

  delete: ->
    # Build an object of which elements we want to delete before
    # we start deleting them,
    # because this fucks with the z-indexes
    plan = {}
    for own index, elem of @args
      index = parseInt index, 10
      plan[index] = queryElemByZIndex(index)

    for elem in objectValues plan
      elem.delete()

    if not archive.simulating
      ui.selection.elements.validate()

  undo: ->
    if @mode is "delete" then @draw() else @delete()

  do: ->
    if @mode is "delete" then @delete() else @draw()

  toJSON: ->
    # t = type, "e:" = existence:
    #   "d" = delete, "c" = create
    # i = z-index to create or delete at
    # e = elem data
    t: "e:#{ { "delete": "d", "create": "c" }[@mode] }"
    a: @args




###

  Manages elements being selected

  API:

  All selected elements:
  ui.selection.elements.all

  All selected points:
  ui.selection.points.all

  Both ui.selection.elements and ui.selection.points
  have the following methods:

  select(elems)
  selectMore(elems)
  selectAll
  deselect(elems)
  deselectAll

###

ui.selection =

  elements:

    all: []
      # Selected elements


    clone: -> @all.map (elem) -> elem.clone()


    empty: -> @all.length == 0


    exists: -> not @empty()


    select: (elems) ->
      # I/P: elem or list of elems
      # Select only elems

      ui.selection.points.deselectAll()

      if elems instanceof Array
        @all = elems
      else
        @all = [elems]

      @trigger 'change'


    selectMore: (elems) ->
      # I/P: elem, or list of elems
      # Adds elem(s) to the selection

      ui.selection.points.deselectAll()

      if elems instanceof Array
        for elem in elems
          @all.ensure elem
      else
        @all.ensure elems

      @trigger 'change'


    selectAll: ->
      # No I/O
      # Select all elements

      ui.selection.points.deselectAll()

      @all = ui.elements
      @trigger 'change'


    selectWithinBounds: (bounds) ->
      # I/P: Bounds
      # Select all elements within given Bounds

      ui.selection.points.deselectAll()

      rect = bounds.toRect()
      @all = ui.elements.filter (elem) ->
        elem.overlaps rect
      @trigger 'change'


    deselect: (elems) ->
      # I/P: elem or list of elems
      # Deselect given elem(s)

      @all.remove elems
      @trigger 'change'


    deselectAll: ->
      # No I/O
      # Deselects all elements

      return if @all.length is 0

      @all = []
      @trigger 'change'


    each: (func) ->
      @all.forEach func


    map: (func) ->
      @all.map func


    filter: (func) ->
      @all.filter func


    zIndexes: ->
      # O/P: a list of the z-indexes of the selected elements
      # ex:  [2, 5, 7]

      (e.zIndex() for e in @all)


    ofType: (type) ->
      # I/P: string of element's nodename
      # ex:  'path'

      # O/P: a list of the selected elements of a certain type
      # ex:  [Path, Path, Path]

      @filter (e) -> e.type is type


    validate: ->
      # No I/O
      # Make sure every selected elem exists in the UI

      @all = @filter (elem) ->
        ui.elements.has elem
      @trigger 'change'


    # Exporting

    export: (opts) ->
      return "" if @empty()

      opts = $.extend(
        trim: false
      , opts)

      svg = new SVG(@clone())

      if opts.trim
        svg.trim()

      svg.toString()


    exportAsDataURI: ->
      "data:image/svg+xml;base64,#{btoa @export()}"


    exportAsPNG: (opts) ->
      new PNG @export(opts)

    asDataURI: ->

  points:

    all: []
      # Selected points


    empty: -> @all.length == 0


    exists: -> not @empty()


    select: (points) ->
      # I/P: Point or list of Points
      # Selects points, deslects any previously selected points

      ui.selection.elements.deselectAll()

      if points instanceof Array
        @all = points
      else
        @all = [points]

      @all.forEach (p) -> p.select()

      @trigger 'change'

    selectMore: (points) ->
      # I/P: Point or list of Points
      # Selects points

      ui.selection.elements.deselectAll()

      if points instanceof Array
        points.forEach (point) =>
          @all.ensure point
          point.select()
      else
        @all.ensure points
        points.select()


      @trigger 'change'


    deselect: (points) ->
      points.forEach (point) ->
        point.deselect()
      @all.remove points
      @trigger 'change'

    deselectAll: ->
      return if @all.length is 0

      @all.forEach (point) ->
        point.deselect()
      @all = []

      @trigger 'change'

    zIndexes: ->
      # O/P: Object where keys are elem zIndexes
      #      and values are lists of point indexes
      # ex: { 3: [5, 6], 7: [1], 22: [29] }
      zIndexes = {}
      for point in @all
        zi = point.owner.zIndex()
        zIndexes[zi] ?= []
        zIndexes[zi].push point.at
      zIndexes


    show: -> @all.map (p) -> p.show


    hide: -> @all.map (p) -> p.hide true # Force it


    each: (func) ->
      @all.forEach func


    filter: (func) ->
      @all.filter func


    validate: ->
      @all = @filter (pt) ->
        ui.elements.has pt.owner

      @trigger 'changed'


  refresh: ->
    @elements.validate()


# Give both an event register
$.extend ui.selection.elements, mixins.events
$.extend ui.selection.points, mixins.events

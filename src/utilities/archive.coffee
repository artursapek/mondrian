
ui.utilities.history = new Utility

  setup: ->
    @$rep = $("#archive-ut")
    @rep = @$rep[0]
    @$container = $("#archive-thumbs")
    @container = @$container[0]
    @$controls = $("#archive-controls")
    @controls = @$controls[0]

    @stepsSlider = new Slider
      rep: $("#archive-steps-slider")[0]
      commit: (val) =>
      valueTipFormatter: (val) =>
        "#{Math.round(@maxSteps * val) + 1}"
      onRelease: (val) =>
        @build Math.round(@maxSteps * val) + 1
      inverse: true

  thumbsCache: {}

  deleteThumbsCached: (after) ->
    toDelete = []
    for own key, thumb of @thumbsCache
      if parseInt(key, 10) > after
        toDelete.push key
    for key in toDelete
      delete @thumbsCache[key]
    @

  shouldBeOpen: -> false

  open: ->
    @show()

    # Set this to just return true to keep it open
    @shouldBeOpen = -> true

    # Build it async so the window pops open and shows
    # the loading progress while it's compiling the thumbnails
    async =>
      @build()

  close: ->
    @$container.empty()
    @shouldBeOpen = -> false
    @hide()

  toggle: ->
    if @visible then @close() else @open()


  build: (@every) ->
    if archive.events.length < 3
      @$controls.hide()
      @every = 1
      return @$container.html('<div empty>Make changes to this file to get a visual history of it.</div>')

    @$controls.show()

    # Calculate max value for steps slider
    @maxSteps = Math.round(archive.events.length / 4)

    if not @every?
      @every = Math.round(@maxSteps / 2)
      @stepsSlider.write(0.5)

    # Remember where we were
    @$container.html('<div empty>Processing <br> file history... <br> <span percentage></span></div>')
    async =>
      @buildThumbs @every


  buildThumbs: (@every, startingAt = 0) ->

    # If we're redrawing the entire thumbs list
    # clear whatever was in there before be it old thumbs
    # or the empty message
    @$container.empty() if startingAt < 2

    cp = archive.currentPosition()
    cs = ui.selection.elements.zIndexes()

    ui.canvas.petrify()

    # Put the archive in simulating mode to omit
    # unnecessary UI actions
    archive.simulating = true

    # Go to where we want to start going up from
    archive.goToEvent startingAt

    @thumbs = []

    @_buildRecursive archive.currentPosition(), @every, =>

      # Go back to where we started from
      archive.goToEvent cp

      archive.simulating = false

      ui.canvas.depetrify()

      ui.selection.elements.deselectAll()
      for zi in cs
        ui.selection.elements.selectMore(queryElemByZIndex(zi))

      @$container.empty() if startingAt is 0

      @thumbs.map ($thumb) =>
        @$container.prepend $thumb

      @refreshThumbs(archive.currentPosition())


  _buildRecursive: (i, @every, done) ->
    percentage = Math.min(Math.round((i / archive.events.length) * 100), 100)
    @$container.find('[percentage]').text("#{percentage}%")

    archive.goToEvent i

    if @thumbsCache[i]?
      src = @thumbsCache[i]

    else
      contents = io.makeFile()
      src = io.makePNGURI(ui.elements, 150)
      @thumbsCache[i] = src

    img = new Image()
    img.src = src

    $thumb = $("<div class=\"archive-thumb\" position=\"#{i}\"></div>")
    $thumb.prepend img
    $thumb.off("click").on("click", ->
      $self = $ @
      i = parseInt($self.attr("position"), 10)
      archive.goToEvent i
      ui.utilities.history.refreshThumbs.call($thumb, i))

    @thumbs.push $thumb
    async =>
      if i < archive.events.length - 1
        @_buildRecursive(Math.min(i + @every, archive.events.length - 1), @every, done)
      else
        done()


  refreshThumbs: (i) ->
    # Go to this event's index, and update all the other
    $(".archive-thumb").removeClass("future")
    $(".archive-thumb").each ->
      $self = $ @
      if parseInt($self.attr("position"), 10) > i
        $self.addClass "future"




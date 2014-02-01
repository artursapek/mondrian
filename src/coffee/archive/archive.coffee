###


  archive

  Undo/redos

  Manages a stack of Events that describe exactly how the file was put together.
  The Archive is designed to describe the calculations needed to reconstruct the file
  step by step without actually saving the results of any of those calculations.

  It merely retains the bare minimum information to carry that calculation out again.

  For example, if we nudged a certain shape, we won't be saving the old and new point values,
  which could look like a big wall of characters like "M 434.37889,527.30393 C 434.37378,524.01..."
  Instead we just say "move shape 3 over 23 pixels and up 5 pixels."

  Since that procedure is 100% reproducable we can save just that information and always be able
  to do it again.


  This design is much faster and more efficient and allows us to save the entire history for a file on
  S3 and pull it back down regardless of where and when the file is opened again.

  The trade-off is we need to have lots of different Event subclasses that do different things, and
  practically operation in the program needs to be custom-fitted to an Event call.

  Again, doing things this way instead of a simpler one-size-fits-all solution gives us more control
  over what is happening and only store the bare minimum details we need in order to offer a
  full start-to-finish file history.


  Events are serialized in an extremely minimal way. For example, here is a MapEvent that describes a nudge:

  {"t":"m:n","i":[5],"a":{"x":0,"y":-10}}

  What this is saying, in order of appearance is:
    - The type of this event is "map: nudge"
    - We're applying this event to the element at the z-index 5
    - The arguments for the nudge operation are x = 0, y = -10

  That's just an example of how aggressively minimal this system is.


  History is saved as pure JSON on S3 under this scheme:

    development: s3.amazonaws.com/mondy_archives_dev/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json
    prodution:   s3.amazonaws.com/mondy_archives/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json

  "Waboom"


###


window.archive =

  # docready setup, just start with a base-case empty fake event

  setup: ->
    @events = [{ do: (->), undo: (->), position: 0, current: true }]


  # Core UI endpoints into the archive: undo and redo

  undo: ->
    @goToEvent(@currentPosition() - 1)

  redo: ->
    @goToEvent(@currentPosition() + 1)


  # A couple more goto shortcuts

  goToEnd: ->
    @goToEvent @events.length - 1

  goToBeginning: ->
    @goToEvent 0


  eventsUpToCurrent: ->
    # Get the events with anything after the current event sliced off
    @events.slice 0, @currentPosition() + 1


  currentEvent: ->
    # Get the current event
    ce = @events.filter((e) -> e.current)
    if ce?
      return ce[0]
    else
      return null


  currentPosition: ->
    # Get the current event's position
    ce = @currentEvent()
    if ce?
      return ce.position
    else
      return -1


  # A couple boolean checks

  currentlyAtEnd: ->
    @currentPosition() is @events.length - 1

  currentlyAtBeginning: ->
    @currentPosition() is 0


  # Happens every time a new event is created, meaning every time a user does anything

  addEvent: (event) ->
    # Cut off the events after the current event
    # and push the new event to the end
    @events = @eventsUpToCurrent() if @events.length

    # Clear the thumbnails cached in the visual history utility
    ui.utilities.history.deleteThumbsCached(@currentPosition())

    # Give it the proper position number
    event.position = @events.length

    # The current event is no longer current!
    @currentEvent()?.current = false

    # We have a new king in town
    event.current = true
    @events.push event

    # Is the visual history utility open?
    # Automatically update it if it is.
    uh = ui.utilities.history
    # If it falls as an event that is included
    # given the history utility's thumb frequency,
    # add it in.
    if event.position % uh.every is 0
      uh.buildThumbs(uh.every, event.position)

  # Each Event subclass gets its own add method

  addMapEvent: (fun, elems, data) ->
    @addEvent(new MapEvent(fun, elems, data))

  addExistenceEvent: (elem) ->
    @addEvent(new ExistenceEvent(elem))

  addPointExistenceEvent: (elem, point, at) ->
    @addEvent(new PointExistenceEvent(elem, point, at))

  addAttrEvent: (indexes, attr, value) ->
    return if indexes.length == 0
    @addEvent(new AttrEvent(indexes, attr, value))

  addZIndexEvent: (indexesBefore, indexesAfter, direction) ->
    return if indexesBefore.length + indexesAfter == 0
    @addEvent(new ZIndexEvent(indexesBefore, indexesAfter, direction))


  goToEvent: (ep) ->
    # Go to a specific event and execute all the events on the way there.
    #
    # I/P:
    #   ep: event position, an int

    # Old event position, where we just were
    oep = @currentPosition()

    # Mark the previously current event as not current
    currentEvent = @currentEvent()

    if currentEvent
      currentEvent.current = false

    # Execute all the events between the old event and the new event
    # First determine which direction we're going in: backwards of forwards

    diff = Math.abs(ep - oep)

    # Upper and lower bounds - don't let ep
    # exceed what we have available in @events

    if ep > (@events.length - 1)
      # We can't go after the last event
      ep = @events.length - 1
      @events[ep].current = true

    if ep < 0
      # We can't go before the first event
      ep = 0
      @events[0].current = true

    else
      # Otherwise we're good. This should usually be the case
      @events[ep].current = true


    if ep > oep
      # Going forward, execute prereqs from old event + 1 to new event
      for position in [oep + 1 .. ep]
        @events[position]?.do()
    else if ep < oep
      # Going backward
      for position in [oep .. ep + 1]
        @events[position]?.undo()
    # Otherwise we're not moving so don't do anything

    if not @simulating
      ui.selection.refresh()

    #@saveDiffState()


  runThrough: (speed = 30, i = 0) ->
    @goToEvent(i)
    if i < @events.length
      setTimeout =>
        @runThrough(speed, i + 1)
      , speed


  diffState: ->
    diff = {}
    dom.$main.children().each (ind, shape) ->
      diff[ind] = {}
      for attr in shape.attributes
        diff[ind][attr.name] = attr.value
    diff


  saveDiffState: ->
    @lastDiffState = @diffState()
    @atMostRecentEvent = io.makeFile()


  fileAt: (ep) ->
    cp = @currentPosition()
    @goToEvent ep
    file = io.makeFile()
    @goToEvent cp
    file


  toJSON: ->
    if @events.length > 1
      return {
        f: hex_md5(io.makeFile())
        e: @events.slice(1)
        p: @currentPosition()
      }
    else
      return {}


  toString: ->
    JSON.stringify @toJSON()


  loadFromString: (saved, checkMD5 = true) ->
    # Super hackish right now, I'm tired.
    saved = JSON.parse saved

    if Object.keys(saved).length is 0
      # Return empty if we just have an empty object
      return @setup()

    if checkMD5
      if saved.f != hex_md5(ui.file.contents)
        # Return empty if the file md5 hashes don't line up,
        # meaning this history is invalid for this file
        console.log "File contents md5 mismatch"
        return @setup()

    events = saved.e
    parsedEvents = events.map (x) -> new Event().fromJSON(x)
    i = 1
    parsedEvents.map (x) ->
      x.position = i
      i += 1
    # Rebuild the initial empty event
    @setup()
    # Add in the parsed events
    @events = @events.concat parsedEvents

    # By default the 0 index event is current. Disable this
    @events[0].current = false

    # Set the correct current event
    @events[parseInt(saved.p, 10)]?.current = true

  put: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/baddeley/put"
      type: "POST"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        file_hash: hex_md5(ui.file.contents)
        archive: archive.toString()
      success: (data) ->

  get: ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/baddeley/get",
      data:
        session_token: ui.account.session_token
        file_hash: hex_md5(ui.file.contents)
      dataType: "json"
      success: (data) =>
        @loadFromString(data.archive)



setup.push ->
  if not ui.file?
    archive.setup()


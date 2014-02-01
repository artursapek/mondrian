###

  Mondrian.io hotkeys management

  This has to be way more fucking complicated than it should.
  Problems:
    • Holding down CMD on Mac mutes all successive keyups.
    • Pushing down key A and key B, then releasing key B, ceases to register key A continuing to be pressed
      so this uses a simulated keypress interval to get around that by storing all keys that are pressed
      and while there are any, executing them all on a 100 ms interval. It feels native, but isn't.

###


ui.hotkeys =

  # Hotkeys is disabled when the user is focused on a quarantined
  # default-behavior area.

  sets:
    # Here we can store various sets of hotkeys, and switch between
    # which we're using at a particular time. The main set is app,
    # and it's selected by default.

    # The structure of a set:
    #  context: give any context and it will be @ (this) in the function bodies
    #  down:    functions to call when keystrokes are pushed down
    #  up:      functions to call when keys are released

    root:
      context: ui
      down:
        'cmd-S': (e) ->
          e.preventDefault() # Save
          @file.save()
        'cmd-N': (e) ->
          e.preventDefault() # New
          console.log "new"
        'cmd-O': (e) ->
          e.preventDefault()
          if @file.service?
            @file.service.open()

      up: {}

    app:
      context: ui
      ignoreAllOthers: false
      down:
        # Tool hotkeys
        'V' : (e) -> @switchToTool tools.cursor
        'P' : (e) -> @switchToTool tools.pen
        'C' : (e) -> @switchToTool tools.crayon
        '\\': (e) -> @switchToTool tools.line
        'L' : (e) -> @switchToTool tools.ellipse
        'T' : (e) -> @switchToTool tools.type
        'M' : (e) -> @switchToTool tools.rectangle
        'R' : (e) -> @switchToTool tools.rotate
        'Z' : (e) -> @switchToTool tools.zoom
        'I' : (e) -> @switchToTool tools.eyedropper

        # Start up the paw
        'space': (e) ->
          e.preventDefault()
          @switchToTool tools.paw

        'shift-X': ->
          f = ui.fill.clone()
          ui.fill.absorb ui.stroke
          ui.stroke.absorb f

        # Text resizing

        'cmd-.': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] += 1
            t.commit()
          ui.transformer.refresh()

        'cmd-shift-.': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] += 10
            t.commit()
          ui.transformer.refresh()

        'cmd-,': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] -= 1
            t.commit()
          ui.transformer.refresh()

        'cmd-shift-,': (e) ->
          e.preventDefault()
          ui.selection.elements.ofType('text').map (t) ->
            t.data['font-size'] -= 10
            t.commit()
          ui.transformer.refresh()


        'cmd-F': (e) ->
          e.preventDefault()

        'U': (e) ->
          e.preventDefault()
          pathfinder.merge(@selection.elements.all)

        # Ignore certain browser defaults
        'cmd-D': (e) -> e.preventDefault() # Bookmark

        'cmd-S': (e) ->
          e.preventDefault() # Save
          ui.file.save()

        'ctrl-L': -> ui.annotations.clear()

        # Nudge
        'leftArrow':        -> @selection.nudge -1,  0  # Left 1px
        'rightArrow':       -> @selection.nudge 1,   0  # Right 1px
        'upArrow':          -> @selection.nudge 0,   1  # Up 1px
        'downArrow':        -> @selection.nudge 0,  -1  # Down 1px
        'shift-leftArrow':  -> @selection.nudge -10, 0  # Left 10px
        'shift-rightArrow': -> @selection.nudge 10,  0  # Right 10px
        'shift-upArrow':    -> @selection.nudge 0,  10  # Up 10px
        'shift-downArrow':  -> @selection.nudge 0, -10  # Down 10px

      up:
        'space': -> @switchToLastTool()
        '+': -> @refreshAfterZoom()
        '-': -> @refreshAfterZoom()


  use: (set) ->
    if typeof set is "string"
      @using = @sets[set]
    else if typeof set is "object"
      @using = set

    for own key, val of @sets.root.down
      @using.down[key] = val if not @using.down[key]?

    @enable()

  reset: ->
    @lastKeystroke = ''
    @modifiersDown = []
    @keysDown = []

  disable: ->
    if @using is @sets.app
      @disabled = true
    @

  enable: ->
    @disabled = false
    # Hackish
    @cmdDown = false
    @

  modifiersDown: []

  # Modifier key functions
  #
  # When the user pushes Alt, Shift, or Cmd, depending
  # on what they're doing, we might want
  # to change something.
  #
  # Example: when dragging a shape, hitting Shift
  # makes it start snapping to the closest 45°


  registerModifier: (modifier) ->
    if not @modifiersDown.has modifier
      @modifiersDown.push modifier
      ui.uistate.get('tool').activateModifier modifier

  registerModifierUp: (modifier) ->
    if @modifiersDown.has modifier
      @modifiersDown = @modifiersDown.remove modifier
      ui.uistate.get('tool').deactivateModifier modifier


  keysDown: []

  cmdDown: false

  simulatedKeypressInterval: null

  beginSimulatedKeypressTimeout: null

  keypressIntervals: []

  lastKeystroke: ''

  lastEvent: {}


  ###
    Strategy:

    Basically, don't persist keystrokes repeatedly if CMD is down. While CMD is down,
    anything else that happens just happens once and that's it.

    So CMD + A + C will select all and copy once, even is C is held down forever.
    Holding down Shift + LefArrow however will repeatedly nudge the selection left 10px.

    So we save all modifiers being held down, and loop all keys unless CMD is down.
  ###

  setup: ->
    @use "app"

    ui.window.on 'focus', =>
      @modifiersDown = []
      @keysDown = []

    $(document).on('keydown', (e) =>

      if isDefaultQuarantined(e.target)
        if not e.target.hasAttribute("h")
          return true

      # Reset the away from keyboard timer - they're clearly here
      ui.afk.reset()

      # Stop immediately if hotkeys are disabled
      return true if @disabled

      # Parse the keystroke into a string we can read/map to a function
      keystroke = @parseKeystroke(e)

      # Stop if we haven't recognized this keystroke via parseKeystroke
      return false if keystroke is null

      # Save this event for
      @lastEvent = e

      if not e.metaKey
        @cmdDown = false
        @registerModifierUp "cmd"
      else
        @registerModifier "cmd"

      # Cmd has been pushed
      if keystroke is 'cmd'
        if not @cmdDown
          @cmdDown = true # Custom tracking for cmd
          @registerModifier "cmd"
        return

      else if keystroke in ['shift', 'alt', 'ctrl']
        @registerModifier keystroke

        # Stop registering previously registered keystrokes without this as a modifier.
        for key in @keysDown
          @using.up?[@fullKeystroke(key, "")]?.call(@using.context, e)
        return

      else
        if not @keysDown.has keystroke
          newStroke = true
          @keysDown.push keystroke
        else
          newStroke = false

      # By now, the keystroke should only be a letter or number.

      # Default to app hotkeys if for some reason
      # we have no @using hotkeys object
      if not @using?
        @use "app"

      fullKeystroke = @fullKeystroke(keystroke)
      #console.log "FULL: #{fullKeystroke}"

      e.preventDefault() if fullKeystroke is "cmd-O"

      if @using.down?[fullKeystroke]? or @using.up?[fullKeystroke]?

        if @keypressIntervals.length is 0

          # There should be no interval going.
          @simulatedKeypress()
          @keypressIntervals = []

          # Don't start an interval when CMD is down
          if @cmdDown
            return

          # Just fill it with some bullshit so it doesnt pass the check
          # above for length == 0 while a beginSimulatedKeypress timeout
          # is pending.
          @keypressIntervals = [0]

          if @beginSimulatedKeypressTimeout?
            clearTimeout @beginSimulatedKeypressTimeout

          @beginSimulatedKeypressTimeout = setTimeout(=>
            @keypressIntervals.push setInterval((=> @simulatedKeypress()), 100)
          , 350)
        else if @keypressIntervals.length > 0
          ###
            Allow new single key presses while the interval is getting set up.
            (This becomes obvious when you try nudging an element diagonally
            with upArrow + leftArrow, for example)
          ###
          @simulatedKeypress() if newStroke

          return false # Putting this here. Might break shit later. Seems to fix bugs for now.

        else
          return false # Ignore the entire keypress if we are already simulating the keystroke
      else
        if @using.ignoreAllOthers
          return false
        else
          if @using.blacklist? and @using.blacklist != null
            chars = @using.blacklist
            character = fullKeystroke

            if character.match(chars)
              if @using.inheritFromApp.has character
                @sets.app.down[character].call(ui)
                @using.context.$rep.blur()
                @use "app"
              return false
            else
              return true


    ).on('keyup', (e) =>
      return true if @disabled

      keystroke = @parseKeystroke(e)

      if @keysDown.length is 1
        @clearAllIntervals()

      return false if keystroke is null

      @using.up?[keystroke]?.call(@using.context, e)

      if @modifiersDown.length > 0
        @using.up?[@fullKeystroke(keystroke)]?.call(@using.context, e)

      # if is modifier, call up for every key down and this modifier

      if @isModifier(keystroke)
        for key in @keysDown
          @using.up?[@fullKeystroke(key, keystroke)]?.call(@using.context, e)


      @using.up?.always?.call(@using.context, @lastEvent)

      if keystroke is 'cmd' # CMD has been released!
        @modifiersDown = @modifiersDown.remove 'cmd'
        ui.uistate.get('tool').deactivateModifier 'cmd'
        @keysDown = []
        @cmdDown = false

        for own hotkey, action of @using.up
          action.call(@using.context, e) if hotkey.mentions "cmd"

        @lastKeystroke = '' # Let me redo CMD strokes completely please
        return @maintainInterval()

      else if keystroke in ['shift', 'alt', 'ctrl']
        @modifiersDown = @modifiersDown.remove keystroke
        ui.uistate.get('tool').deactivateModifier keystroke
        return @maintainInterval()
      else
        @keysDown = @keysDown.remove keystroke
        return @maintainInterval()
    )


  clearAllIntervals: ->
    for id in @keypressIntervals
      clearInterval id
    @keypressIntervals = []


  simulatedKeypress: ->
    ###
      Since we delay the simulated keypress interval, often a key will be pushed and released before the interval starts,
      and the interval will start after and continue running in the background.

      If it's running invalidly, it won't be obvious because no keys will be down so nothing
      will happen, but we don't want an empty loop running in the background for god knows
      how long and eating up resources.

      This prevents that from happening by ALWAYS checking that this simulated press is valid
      and KILLING IT IMMEDIATELY if not.
    ###


    @maintainInterval()

    #console.log @keysDown.join(", ")

    # Assuming it is still valid, carry on and execute all hotkeys requested.

    return if @keysDown.length is 0 # If it's just modifiers, don't bother doing any more work.

    for key in @keysDown
      fullKeystroke = @fullKeystroke(key)

      if @cmdDown
        if @lastKeystroke is fullKeystroke
          # Don't honor the same keystroke twice in a row with CMD
          4
          #return

      if @using.down?[fullKeystroke]?
        @using.down?[fullKeystroke].call(@using.context, @lastEvent)
        @lastKeystroke = fullKeystroke

      @using.down?.always?.call(@using.context, @lastEvent)


  maintainInterval: -> # Kills the simulated keypress interval when appropriate.
    if @keysDown.length is 0
      @clearAllIntervals()


  isModifier: (key) ->
    switch key
      when "shift", "cmd", "alt"
        return true
      else
        return false



  parseKeystroke: (e) ->

    modifiers =
      8: 'backspace'
      16: 'shift'
      17: 'ctrl'
      18: 'alt'
      91: 'cmd'
      92: 'cmd'
      224: 'cmd'

    if modifiers[e.which]?
      return modifiers[e.which]

    accepted = [
      new Range(9, 9) # Enter
      new Range(13, 13) # Enter
      new Range(65, 90) # a-z
      new Range(32, 32) # Space
      new Range(37, 40) # Arrow keys
      new Range(48, 57) # 0-9
      new Range(187, 190) # - + .
      new Range(219, 222) # [ ] \ '
    ]

    # If e.which isn't in any of the ranges, stop here.
    return null if accepted.map((x) -> x.containsInclusive e.which).filter((x) -> x is true).length is 0

    # Certain keycodes we rename to be more clear
    remaps =
      13: 'enter'
      32: 'space'
      37: 'leftArrow'
      38: 'upArrow'
      39: 'rightArrow'
      40: 'downArrow'
      187: '+'
      188: ','
      189: '-'
      190: '.'
      219: '['
      220: '\\'
      221: ']'
      222: "'"

    keystroke = remaps[e.which] || String.fromCharCode(e.which)

    return keystroke

  fullKeystroke: (key, mods = @modifiersPrefix()) ->
    "#{mods}#{if mods.length > 0 then '-' else ''}#{key}"


  ###
    Returns a string line 'cmd-shift-' or 'alt-cmd-shift-' or 'shift-'
    Always in ALPHABETICAL order. Modifier prefix order must match that of hotkey of the hotkey won't work.
    This is done so we can compare single strings and not arrays or strings, which is faster.
  ###

  modifiersPrefix: ->
    mods = @modifiersDown.sort().join('-')
    if /Win/.test navigator.platform
      mods = mods.replace('ctrl', 'cmd')
    mods



setup.push -> ui.hotkeys.setup()


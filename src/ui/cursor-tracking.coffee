###

  Cursor event overriding :D

  This shit tracks exactly what the cursor is doing and implements some
  custom cursor functions like dragging, which are dispatched via the ui object.

###

ui.cursor =


  reset: ->

    @down = false
    @wasDownLast = false
    @downOn = undefined

    @dragging = false
    @draggingJustBegan = false

    @currentPosn = undefined
    @lastPosn = undefined
    @lastEvent = undefined

    @lastDown = undefined
    @lastDownTarget = undefined

    @lastUp = undefined
    @lastUpTarget = undefined

    @inHoverState = undefined
    @lastHoverState = undefined

    @resetOnNext = false

    @doubleclickArmed = false

    true

  snapChangeAccum:
    x: 0
    y: 0

  resetSnapChangeAccumX: ->
    @snapChangeAccum.x = 0

  resetSnapChangeAccumY: ->
    @snapChangeAccum.y = 0

  dragAccum: () ->
    s = @lastPosn.subtract @lastDown

    x: s.x
    y: s.y

  armDoubleClick: ->
    @doubleclickArmed = true
    setTimeout =>
      @doubleclickArmed = false
    , SETTINGS.DOUBLE_CLICK_THRESHOLD

  setup: ->
    # Here we bind functions to all mouse events that override the default browser behavior for these
    # and track them on a low level so we can do custom interactions with the tools and ui.
    #
    # Each important event does an isDefaultQuarantined check, which asks if the element has the
    # [quarantine] attribute or if one of its parents does. If so, we stop the cursor override
    # and let the browser continue with the default behavior.

    @reset()


    @_click = (e) =>

      # Quarantine check, and return if so
      if isDefaultQuarantined(e.target)
        return true
      else
        e.stopPropagation()

    @_mousedown = (e) =>

      ui.afk.reset()

      # Quarantine check, and return if so
      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        @reset()


        return true
      else
        e.stopPropagation()

        # If the user was in an input field and we're not going back to
        # app-override interaction, blur the focus from that field
        $('input:focus').blur()
        $('[contenteditable]').blur()

        # Also blur any text elements they may have been editing

        # We're back in the app-override level, so fire those hotkeys back up!
        ui.hotkeys.use("app")

        # Prevent the text selection cursor when dragging
        e.originalEvent.preventDefault()

        # Send the event to ui, which will dispatch it to the appropriate places
        ui.mousedown(e, e.target)

        # Set tracking variables
        @down = true
        @lastDown = new Posn(e)
        @downOn = e.target
        @lastDownTarget = e.target

    @_mouseup = (e) =>

      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        ui.dragSelection.end((->), true)
        return true
      else
        ui.hotkeys.use("app")

        ui.mouseup(e, e.target)
        # End dragging sequence if it was occurring
        if @dragging and not @draggingJustBegan
          ui.stopDrag(e, @lastDownTarget)
        else
          if @doubleclickArmed
            @doubleclickArmed = false
            ui.doubleclick(@lastEvent, @lastDownTarget)
            if isDefaultQuarantined(e.target)
              ui.hotkeys.disable() if not allowsHotkeys(e.target)
              ui.dragSelection.end((->), true)
          else
            # It's a static click, meaning the cursor didn't move
            # between mousedown and mouseup so no drag occurred.
            ui.click(e, e.target)
            # HACK
            if e.target.nodeName is "text"
              @armDoubleClick()

        @dragging = false
        @down = false
        @lastUp = new Posn(e)
        @lastUpTarget = e.target
        @draggingJustBegan = false

    @_mousemove = (e) =>

      @doubleclickArmed = false

      ui.afk.reset()
      @lastPosn = @currentPosn
      @currentPosn = new Posn(e)

      if isDefaultQuarantined(e.target)
        ui.hotkeys.disable() if not allowsHotkeys(e.target)
        return true
      else
        if true
          ui.mousemove(e, e.target)
          e.preventDefault()

          # Set some tracking variables
          @wasDownLast = @down
          @lastEvent = e
          @currentPosn = new Posn(e)

          # Initiate dragging, or continue it if it's been initiated.
          if @down
            if not @dragging # First detection of a drag
              ui.startDrag(@lastEvent, @lastDownTarget)
              @dragging = @draggingJustBegan = true
            else
              ui.continueDrag(e, @lastDownTarget)
              @draggingJustBegan = false

    @_mouseover = (e) =>
      # Just some simple hover actions, as long as we're not dragging something.
      # (We don't want to indicate actions that can't be taken - you can't click on
      # something if you're already holding something down and dragging it)
      return if @dragging

      @lastHoverState = @inHoverState
      @inHoverState = e.target

      # Unhover from the last element we hovered on
      if @lastHoverState?
        ui.unhover(e, @lastHoverState)

      # And hover on the new one! Simple shit.
      ui.hover(e, @inHoverState)

    $('body')
      .click (e) =>
        @_click(e)
      .mousemove (e) =>
        @_mousemove(e)
      .mousedown (e) =>
        @_mousedown(e)
      .mouseup (e) =>
        @_mouseup(e)
      .mouseover (e) =>
        @_mouseover(e)



    # O-K: we're done latching onto the mouse events.

    # Lastly, reset the cursor to somewhere off the screen if they switch tabs and come back
    ui.window.on 'focus', =>
      @currentPosn = new Posn(-100, -100)


setup.push -> ui.cursor.setup()

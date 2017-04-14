import setup from 'script/setup';

/*

  Cursor event overriding :D

  This shit tracks exactly what the cursor is doing and implements some
  custom cursor functions like dragging, which are dispatched via the ui object.

*/

ui.cursor = {


  reset() {

    this.down = false;
    this.wasDownLast = false;
    this.downOn = undefined;

    this.dragging = false;
    this.draggingJustBegan = false;

    this.currentPosn = undefined;
    this.lastPosn = undefined;
    this.lastEvent = undefined;

    this.lastDown = undefined;
    this.lastDownTarget = undefined;

    this.lastUp = undefined;
    this.lastUpTarget = undefined;

    this.inHoverState = undefined;
    this.lastHoverState = undefined;

    this.resetOnNext = false;

    this.doubleclickArmed = false;

    return true;
  },

  snapChangeAccum: {
    x: 0,
    y: 0
  },

  resetSnapChangeAccumX() {
    return this.snapChangeAccum.x = 0;
  },

  resetSnapChangeAccumY() {
    return this.snapChangeAccum.y = 0;
  },

  dragAccum() {
    let s = this.lastPosn.subtract(this.lastDown);

    return {
      x: s.x,
      y: s.y
    };
  },

  armDoubleClick() {
    this.doubleclickArmed = true;
    return setTimeout(() => {
      return this.doubleclickArmed = false;
    }
    , SETTINGS.DOUBLE_CLICK_THRESHOLD);
  },

  setup() {
    // Here we bind functions to all mouse events that override the default browser behavior for these
    // and track them on a low level so we can do custom interactions with the tools and ui.
    //
    // Each important event does an isDefaultQuarantined check, which asks if the element has the
    // [quarantine] attribute or if one of its parents does. If so, we stop the cursor override
    // and let the browser continue with the default behavior.

    this.reset();


    this._click = e => {

      // Quarantine check, and return if so
      if (isDefaultQuarantined(e.target)) {
        return true;
      } else {
        return e.stopPropagation();
      }
    };

    this._mousedown = e => {

      ui.afk.reset();

      // Quarantine check, and return if so
      if (isDefaultQuarantined(e.target)) {
        if (!allowsHotkeys(e.target)) { ui.hotkeys.disable(); }
        this.reset();


        return true;
      } else {
        e.stopPropagation();

        // If the user was in an input field and we're not going back to
        // app-override interaction, blur the focus from that field
        $('input:focus').blur();
        $('[contenteditable]').blur();

        // Also blur any text elements they may have been editing

        // We're back in the app-override level, so fire those hotkeys back up!
        ui.hotkeys.use("app");

        // Prevent the text selection cursor when dragging
        e.originalEvent.preventDefault();

        // Send the event to ui, which will dispatch it to the appropriate places
        ui.mousedown(e, e.target);

        // Set tracking variables
        this.down = true;
        this.lastDown = new Posn(e);
        this.downOn = e.target;
        return this.lastDownTarget = e.target;
      }
    };

    this._mouseup = e => {

      if (isDefaultQuarantined(e.target)) {
        if (!allowsHotkeys(e.target)) { ui.hotkeys.disable(); }
        ui.dragSelection.end((function() {}), true);
        return true;
      } else {
        ui.hotkeys.use("app");

        ui.mouseup(e, e.target);
        // End dragging sequence if it was occurring
        if (this.dragging && !this.draggingJustBegan) {
          ui.stopDrag(e, this.lastDownTarget);
        } else {
          if (this.doubleclickArmed) {
            this.doubleclickArmed = false;
            ui.doubleclick(this.lastEvent, this.lastDownTarget);
            if (isDefaultQuarantined(e.target)) {
              if (!allowsHotkeys(e.target)) { ui.hotkeys.disable(); }
              ui.dragSelection.end((function() {}), true);
            }
          } else {
            // It's a static click, meaning the cursor didn't move
            // between mousedown and mouseup so no drag occurred.
            ui.click(e, e.target);
            // HACK
            if (e.target.nodeName === "text") {
              this.armDoubleClick();
            }
          }
        }

        this.dragging = false;
        this.down = false;
        this.lastUp = new Posn(e);
        this.lastUpTarget = e.target;
        return this.draggingJustBegan = false;
      }
    };

    this._mousemove = e => {

      this.doubleclickArmed = false;

      ui.afk.reset();
      this.lastPosn = this.currentPosn;
      this.currentPosn = new Posn(e);

      if (isDefaultQuarantined(e.target)) {
        if (!allowsHotkeys(e.target)) { ui.hotkeys.disable(); }
        return true;
      } else {
        if (true) {
          ui.mousemove(e, e.target);
          e.preventDefault();

          // Set some tracking variables
          this.wasDownLast = this.down;
          this.lastEvent = e;
          this.currentPosn = new Posn(e);

          // Initiate dragging, or continue it if it's been initiated.
          if (this.down) {
            if (this.dragging) {
              ui.continueDrag(e, this.lastDownTarget);
              return this.draggingJustBegan = false;
            // Allow for slight movement without triggering drag
            } else if (this.currentPosn.distanceFrom(this.lastDown) > SETTINGS.DRAG_THRESHOLD) {
              ui.startDrag(this.lastEvent, this.lastDownTarget);
              return this.dragging = (this.draggingJustBegan = true);
            }
          }
        }
      }
    };

    this._mouseover = e => {
      // Just some simple hover actions, as long as we're not dragging something.
      // (We don't want to indicate actions that can't be taken - you can't click on
      // something if you're already holding something down and dragging it)
      if (this.dragging) { return; }

      this.lastHoverState = this.inHoverState;
      this.inHoverState = e.target;

      // Unhover from the last element we hovered on
      if (this.lastHoverState != null) {
        ui.unhover(e, this.lastHoverState);
      }

      // And hover on the new one! Simple shit.
      return ui.hover(e, this.inHoverState);
    };

    $('body')
      .click(e => {
        return this._click(e);
    }).mousemove(e => {
        return this._mousemove(e);
      }).mousedown(e => {
        return this._mousedown(e);
      }).mouseup(e => {
        return this._mouseup(e);
      }).mouseover(e => {
        return this._mouseover(e);
      }).on('contextmenu', e => {
        // Handling right-clicking in @_mouse* handlers
        return e.preventDefault();
    });



    // O-K: we're done latching onto the mouse events.

    // Lastly, reset the cursor to somewhere off the screen if they switch tabs and come back
    return ui.window.on('focus', () => {
      return this.currentPosn = new Posn(-100, -100);
    });
  }
};


setup.push(() => ui.cursor.setup());

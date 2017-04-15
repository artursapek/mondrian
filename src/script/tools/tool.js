import ui from 'script/ui/ui';
import Posn from 'script/geometry/posn';
/*

  Tools class and organization object.
  Higher-level tool event method dispatcher and event augmentation.
  Includes template for all possible methods.

*/

export default class Tool {
  static initClass() {
  
    this.prototype.followingAngle = false;
  }

  constructor(attrs) {
    for (let i in attrs) {
      let x = attrs[i];
      this[i] = x;
    }

    if (this.hotkey != null) {
      ui.hotkeys.sets.app.down[this.hotkey] = e => {
        e.preventDefault();
        ui.switchToTool(this);
        return ui.tooltips.hideVisible();
      };
    }
  }

  tearDown() {}

  setup() {}

  activateModifier(modifier) {}

  deactivateModifier(modifier) {}

  typeOf(target) {
    // Depending on what is being clicked on/hovered over/dragged,
    // tools will do different things. This method performs various tests
    // on event.target. Return what is being clicked on as a string.

    if (isSVGElementInMain(target)) {
      return "elem";
    } else if (isBezierControlHandle(target)) {
      return "antlerPoint";
    } else if (isPointHandle(target)) {
      return "point";
    } else if (isTransformerHandle(target)) {
      return "transformerHandle";
    } else if (isHoverTarget(target)) {
      return "hoverTarget";
    } else {
      return "background";
    }
  }



  buildEvent(e) {
    // Viewport coordinates are those of the actual white board we are drawing on,
    // the canvas.
    //
    // I/P: e: event object
    // O/P: e: augmented event object

    e.clientPosn = new Posn(e.clientX, e.clientY);

    e.canvasX = (e.clientX - ui.canvas.normal.x) / ui.canvas.zoom;
    e.canvasY = (e.clientY - ui.canvas.normal.y) / ui.canvas.zoom;

    e.canvasPosn = ui.canvas.clientToCanvas(e.clientPosn);
    e.canvasPosnZoomed = ui.canvas.clientToCanvasZoomed(e.clientPosn);

    if (ui.grid.visible()) {
      e = ui.snap.supplementForGrid(e);
    }
    if (ui.snap.supplementEvent != null) {
      e = ui.snap.supplementEvent(e);
    }

    e.modifierKeys = e.shiftKey || e.metaKey || e.ctrlKey || e.altKey;

    // Amt the cursor has moved on this event
    if (ui.cursor.lastPosn != null) {
      e.changeX = e.clientX - ui.cursor.lastPosn.x;
      e.changeY = -(e.clientY - ui.cursor.lastPosn.y);

      e.changeX /= ui.canvas.zoom;
      e.changeY /= ui.canvas.zoom;

      e.changeXSnapped = e.changeX + ui.cursor.snapChangeAccum.x;
      e.changeYSnapped = e.changeY + ui.cursor.snapChangeAccum.y;
    }

    e.typeOfTarget = this.typeOf(e.target);

    // Now we query the appropriate JS object representations of the target,
    // and potentially its relatives. Store this in the event object as well.
    switch (e.typeOfTarget) {
      case "elem":
        e.elem = ui.queryElement(e.target); // Monsvg object
        break;

      case "point":
        e.elem = queryElemByUUID(e.target.getAttribute("owner")); // Monsvg object
        e.point = e.elem.points.at(e.target.getAttribute("at")); // Point object
        break;

      case "antlerPoint":
        e.elem = queryElemByUUID(e.target.getAttribute("owner")); // Monsvg object
        e.point = e.elem.queryAntlerPoint(e.target); // Point object
        break;

      case "hoverTarget":
        e.elem = queryElemByUUID(e.target.getAttribute("owner")); // Monsvg object
        e.pointA = e.elem.points.at(parseInt(e.target.getAttribute('a'))); // Point object
        e.pointB = e.elem.points.at(parseInt(e.target.getAttribute('b'))); // Point object
        e.hoverTarget = e.pointB.hoverTarget; // HoverTarget object
        break;
    }

    // By now, the event object should have a typeOfTarget attribute
    // and the appropriate JS object(s) embedded in it for the tool
    // to interface with the objects on the screen appropriately.
    //
    // From now on, ONLY (clientX, clientY) or (canvasX, canvasY)
    // should ever be used in tool methods. OK MOTHERFUCKERS? LETS KEEP THIS STANDARD.
    //
    // So let's return the new event now.

    return e;
  }


  dispatch(e, eventType) {
    // Sends a mouse event to the appropriate tool method.
    // I/P: e: event object
    //      eventType: "hover", "unhover", "click", "startDrag", "continueDrag", "stopDrag"
    //                 Basically, a string describing the actual behavior of the mouse.
    //                 Brought in from ui/cursor_tracking.coffee
    // O/P: Nothing, simply calls the appropriate method.

    // If we're unhovering, this is a special case where we actually target the LAST hover target,
    // not the current one. We need to set this before we run @buildEvent

    // First let's get the additional info we need to carry this out no matter what.
    e = this.buildEvent(e);

    // A note about how methods should be organized:
    // The method should be named after the event.typeOfTarget (output from tool.typeOf)
    // and it should live in an object named after the eventType given this by ui/ui.coffee
    // The eventType will be one of the strings listed in the I/P section for this method above.
    //
    // So hovering over a point with the cursor will call tools.cursor.hover.point(e)

    let args = [e];

    if (eventType === 'startDrag') {
      for (let modifier of Array.from(ui.hotkeys.modifiersDown)) {
        this.activateModifier(modifier);
      }
      this.draggingType = e.typeOfTarget;
    }

    if ((eventType === "doubleclick") && this.ignoreDoubleclick) {
      eventType = "click";
    }

    if (this[eventType] != null) {
      // If a method explicitly for this target type exists, run it. This is the most common case.
      if (this[eventType][e.typeOfTarget] != null) {
        return (this[eventType][e.typeOfTarget] != null ? this[eventType][e.typeOfTarget].apply(this, args) : undefined);
      }

      // If it doesn't, check for events that apply to multiple target types.
      // Multi-target keys should be named by separating the targets with underscores.
      // For example, hovering over a point might trigger hover.point_elem or hover.hoverTarget_elem_point
      for (let key of Object.keys(this[eventType] || {})) {
        let value = this[eventType][key];
        if (key.mentions(e.typeOfTarget)) {
          return value.apply(this, args);
        }
      }

      // If there are none that mention it, check for an "all" event.
      // This should seldom be in use.
      if (this[eventType].all != null) {
        return this[eventType].all.apply(this, args);
      }
    }
  }

      // By now, we clearly don't care about this event/target combo. So do nothing.


  recalculateLastDrag() {
    if (ui.cursor.dragging) {
      return ui.cursor._mousemove(ui.cursor.lastEvent);
    }
  }
}
Tool.initClass();


let noop = {
  background(e) {},
  elem(e) {},
  point(e) {},
  antlerPoint(e) {},
  toolPlaceholder(e) {},
  hoverTarget(e) {}
};

Tool.prototype.hover        = noop;
Tool.prototype.unhover      = noop;
Tool.prototype.click        = noop;
Tool.prototype.rightClick   = noop;
Tool.prototype.mousedown    = noop;
Tool.prototype.mouseup      = noop;
Tool.prototype.startDrag    = noop;
Tool.prototype.continueDrag = noop;
Tool.prototype.stopDrag     = noop;


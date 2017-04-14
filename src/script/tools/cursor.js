/*

  Cursor tool

  Default tool that performs selection and transformation.


      *
      *   #
      *      #
      *         #
      *            #
      *               #
      *      #  #  #  #  #
      *   #
      *#
      *

*/

tools.cursor = new Tool({

  // Cursor image action point coordinates
  offsetX: 1,
  offsetY: 1,

  // CSS "tool" attribute given to the body when this tool is selected
  // to have its custom cursor show up.
  cssid: 'cursor',
  id: 'cursor',

  hotkey: 'V',

  tearDown() {
    return (() => {
      let result = [];
      for (let elem of Array.from(ui.elements)) {
        let item;
        if (!ui.selection.elements.all.has(elem)) {
          item = elem.hidePoints();
        }
        result.push(item);
      }
      return result;
    })();
  },

  initialDragPosn: undefined,

  activateModifier(modifier) {
    switch (modifier) {
      case "shift":
        switch (this.draggingType) {
          case "elem": case "hoverTarget": case "point":
            let op = this.initialDragPosn;
            if (op != null) {
              ui.snap.presets.every45(op);
            }

            // Recalculate the last drag event, so it snaps
            // as soon as Shift is pushed.
            return this.recalculateLastDrag();
        }
        break;
      case "alt":
        switch (this.draggingType) {
          case "elem":
            return 3;
        }
        break;
    }
  },
            //@duplicateElemModeOn()


  deactivateModifier(modifier) {
    switch (modifier) {
      case "shift":
        switch (this.draggingType) {
          case "elem": case "hoverTarget":
            ui.snap.toNothing();
            return this.recalculateLastDrag();
        }
        break;
      case "alt":
        switch (this.draggingType) {
          case "elem":
            return 3;
        }
        break;
    }
  },
            //@duplicateElemModeOff()


  hover: {
    background(e) {
      for (let elem of Array.from(ui.elements)) {
        if (typeof elem.hidePoints === 'function') {
          elem.hidePoints();
        }
      }
      return ui.unhighlightHoverTargets();
    },
    elem(e) {
      return e.elem.hover();

      /*
      if not ui.selection.elements.all.has e.elem
        e.elem.hover()

        if e.elem.group?
          e.elem.group.map (elem) -> elem.showPoints()

      ui.unhighlightHoverTargets()
      */
    },

    point(e) {
      if (!ui.selection.elements.all.has(e.elem)) {
        e.elem.unhoverPoints();
        e.elem.showPoints();
        return ui.unhighlightHoverTargets();
      }
    },

    antlerPoint(e) {},

    hoverTarget(e) {
      if (!ui.selection.elements.all.has(e.elem)) {
        e.elem.unhoverPoints();
        e.elem.showPoints();
        return e.hoverTarget.highlight();
      }
    }
  },

  unhover: {
    background(e) {},
    elem(e) {
      return e.elem.unhover();
    },

    point(e) {
      return e.elem.hidePoints();
    },

    antlerPoint(e) {},

    hoverTarget(e) {
      if (e.currentHover !== e.elem.rep) {
        e.elem.unhoverPoints();
        e.elem.hidePoints();
      }
      return e.hoverTarget.unhighlight();
    }
  },

  click: {
    background(e) {
      if (!e.modifierKeys) {
        ui.selection.elements.deselectAll();
      }
      return ui.selection.points.deselectAll();
    },
    elem(e) {
      // Is this shit selected already?
      let { elem } = e;
      let selected = ui.selection.elements.all.has(elem);
      ui.selection.points.deselectAll();

      // If the shift key is down, this is a toggle operation.
      // Whether or not the element is already selected, do the opposite.
      // It's also additive/subtractive from the current selection
      // which might include many elements.
      if (e.shiftKey) {
        if (selected) {
          ui.selection.elements.deselect(elem);
          elem.showPoints();
          elem.hover();
        } else {
          if (elem.group != null) {
            ui.selectMore(elem.group.elements);
          } else {
            ui.selection.elements.selectMore(elem);
            elem.unhover();
            elem.removePoints();
          }
        }
      } else {
        if (!selected) {
          if (elem.group != null) {
            ui.selection.elements.select(elem.group.elements);
            elem.group.map(elem => elem.removePoints());
          } else {
            ui.selection.elements.select(elem);
            elem.unhover();
            elem.removePoints();
          }
        }
      }

      return ui.unhighlightHoverTargets();
    },

    point(e) {
      if (e.shiftKey) {
        return ui.selection.points.selectMore(e.point);
      } else {
        return ui.selection.points.select(e.point);
      }
    },

    antlerPoint(e) {},

    hoverTarget(e) {
      ui.selection.points.selectMore(e.hoverTarget.a);
      return ui.selection.points.selectMore(e.hoverTarget.b);
    }
  },

  doubleclick: {
    elem(e) {
      trackEvent("Text", "Doubleclick edit");
      if (e.elem instanceof Text) {
        return e.elem.selectAll();
      }
    }
  },


  startDrag: {

    // This happens once at the beginning of every time the user drags something.
    background(e) {
      return ui.dragSelection.start(new Posn(e));
    },
    elem(e) {

      e.elem.unhover();

      // If we're dragging an elem, deselect any selected points.
      ui.selection.points.deselectAll();

      // Also hide any hover targets that may be visible.
      ui.unhighlightHoverTargets();

      // Is the element selected already? If so, we're going to be dragging
      // the entire selection that it's a part of.
      //
      // If not, select this element and anything it may be grouped with.
      if (!ui.selection.elements.all.has(e.elem)) {
        if (e.elem.group != null) {
          ui.selection.elements.select(e.elem.group.elements);
        } else {
          ui.selection.elements.select(e.elem);
        }
      }

      // Remove the select elements' points entirely
      // so we don't accidentally start dragging those.
      for (let elem of Array.from(ui.selection.elements.all)) {
        elem.removePoints();
      }

      ui.selection.elements.all.map(elem => elem.commit());
      return this.guidePointA = ui.transformer.center();
    },

    antlerPoint(e) {},

    point(e) {
      if (e.point.antlers != null) {
        e.point.antlers.show();
      }
      e.point.owner.removeHoverTargets();
      ui.selection.points.select(e.point);

      if (ui.selection.elements.all.has(e.elem && ui.hotkeys.modifiersDown.has("alt"))) {
          return e.elem.clone().appendTo('#main');
        }
    },

    transformerHandle(e) {},

    hoverTarget(e) {
      if (!ui.selection.elements.all.has(e.elem)) {
        e.hoverTarget.active();

        ui.selection.elements.deselectAll();
        ui.selection.points.deselectAll();

        return this.guidePointA = ui.transformer.center();
      }
    }
  },

  snapChange: {
    x: 0,
    y: 0
  },

  changeAccum: {
    x: 0,
    y: 0
  },

  continueDrag: {
    background(e) {
      return ui.dragSelection.move(new Posn(e.clientX, e.clientY));
    },
    elem(e) {
      // Hide point UI elements
      e.elem.removePoints();

      // If there is an accum from last snap to undo, do that first
      let ac = this.snapChange;
      if ((ac.x !== 0) && (ac.y !== 0)) {
        // Only bother if there is something to do
        ui.selection.nudge(-ac.x, -ac.y);
      }
      // Move the shape in its "true" position
      ui.selection.nudge(e.changeX + this.changeAccum.x, e.changeY + this.changeAccum.y, false);

      // resnap

      if (ui.grid.visible()) {
        let { bl } = ui.transformer;
        let nbl = ui.snap.snapPointToGrid(bl.clone());

        this.snapChange = {
          x: nbl.x - bl.x,
          y: bl.y - nbl.y
        };

        if (this.snapChange.x === -e.changeX) {
          this.changeAccum.x += e.changeX;
        } else {
          this.changeAccum.x = 0;
        }

        if (this.snapChange.y === -e.changeY) {
          this.changeAccum.y += e.changeY;
        } else {
          this.changeAccum.y = 0;
        }

        return ui.selection.nudge(this.snapChange.x, this.snapChange.y, false);
      }
    },


    point(e) {
      if (ui.selection.elements.all.has(e.elem)) {
        return this.continueDrag.elem(e);
      }

      e.point.nudge(e.changeX, e.changeY);
      if (e.point.antlers != null) {
        e.point.antlers.refresh();
      }

      // We're moving a single point individually,
      // ruining any potential virginal integrity
      e.elem.woohoo();

      return e.elem.commit();
    },

    antlerPoint(e) {
      e.point.nudge(e.changeX, e.changeY);
      return e.elem.commit();
    },

    transformerHandle(e) {
      return ui.transformer.drag(e);
    },

    hoverTarget(e) {
      if (ui.selection.elements.all.has(e.elem)) {
        return this.continueDrag.elem.call(tools.cursor, e);
      } else {
        return e.hoverTarget.nudge(e.changeX, e.changeY);
      }
    }
  },


  stopDrag: {
    background(e) {
      return ui.dragSelection.end(b => ui.selection.elements.selectWithinBounds(b));
    },

    elem(e) {
      for (let elem of Array.from(ui.selection.elements.all)) {
        elem.redrawHoverTargets();
        elem.commit();
      }

      // Save this event
      let nudge = new Posn(e).subtract(ui.cursor.lastDown);
      nudge.setZoom(ui.canvas.zoom);

      if (this.duping) {
        archive.addExistenceEvent(this.duping.rep);
      } else {
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: nudge.x, y: -nudge.y });
      }
      return this.changeAccum = {
        x: 0,
        y: 0
      };
    },

      //@duping = undefined

    point(e) {
      e.elem.redrawHoverTargets();
      e.elem.clearCachedObjects();
      let nudge = new Posn(e).subtract(ui.cursor.lastDown);
      nudge.setZoom(ui.canvas.zoom);
      return archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x,
        y: -nudge.y
      });
    },

    antlerPoint(e) {
      e.elem.redrawHoverTargets();

      let nudge = new Posn(e).subtract(ui.cursor.lastDown);
      nudge.setZoom(ui.canvas.zoom);

      return archive.addMapEvent("nudge", ui.selection.points.zIndexes(), {
        x: nudge.x,
        y: -nudge.y,
        antler: (e.point.role === -1 ? "p3" : "p2")
      });
    },


    transformerHandle(e) {
      ui.utilities.transform.refresh();
      for (let elem of Array.from(ui.selection.elements.all)) {
        elem.redrawHoverTargets();
      }
      archive.addMapEvent("scale", ui.selection.elements.zIndexes(), {
        x: ui.transformer.accumX,
        y: ui.transformer.accumY,
        origin: ui.transformer.origin
      });
      return ui.transformer.resetAccum();
    },

    hoverTarget(e) {
      e.elem.redrawHoverTargets();
      e.elem.clearCachedObjects();

      ui.selection.points.selectMore(e.hoverTarget.a);
      ui.selection.points.selectMore(e.hoverTarget.b);

      let nudge = new Posn(e).subtract(ui.cursor.lastDown);

      let eventData = {};
      let zi = e.elem.zIndex();
      eventData[zi] = [];
      eventData[zi].push(e.hoverTarget.a.at, e.hoverTarget.b.at);

      return archive.addMapEvent("nudge", eventData, {
        x: nudge.x,
        y: -nudge.y
      });
    }
  }
});




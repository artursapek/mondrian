import tools from 'script/tools/tools';
import Tool from 'script/tools/tool';
/*

  Pen tool

  Polygon/path-drawing tool


            *
            *
          *///#
          //* *#
          // * #
       //##########
       // * * * * #
       //* * * * *#
       // * * * * #



tools.pen = new Tool({

  offsetX: 5,
  offsetY: 0,

  cssid: 'pen',

  id: 'pen',

  hotkey: 'P',

  ignoreDoubleclick: true,

  tearDown() {
    if (this.drawing) {
      ui.selection.elements.select(this.drawing);
      this.drawing.redrawHoverTargets();
      this.drawing.points.map(function(p) {
        if (typeof p.hideHandles === 'function') {
          p.hideHandles();
        }
        return p.hide();
      });
      this.drawing = false;
    }
    return this.clearPoints();
  },


  // Metadata: what shape we're in, what point was just put down,
  // which is being dragged, etc.

  drawing: false,
  firstPoint: null,
  lastPoint: null,
  currentPoint: null,

  clearPoints() {
    // Resetting most of the metadata.
    this.firstPoint = null;
    this.currentPoint = null;
    return this.lastPoint = null;
  },


  beginNewShape(e) {
    // Ok, if we're drawing and there's no stroke color defined
    // but the stroke width isn't 0, we need to resort to black.
    if ((ui.uistate.get('strokeWidth') > 0) && (ui.stroke.toString() === "none")) {
      ui.stroke.absorb(ui.colors.black);
    }

    // State a new Path!
    let shape = new Path({
      stroke: ui.stroke,
      fill:   ui.fill,
      'stroke-width': ui.uistate.get('strokeWidth'),
      d: `M${e.canvasX},${e.canvasY}`});
    shape.appendTo('#main');
    shape.commit().showPoints();

    archive.addExistenceEvent(shape.rep);

    this.drawing = shape;
    this.firstPoint = shape.points.first;
    return this.currentPoint = this.firstPoint;
  },



  endShape() {

    // Close up the shape we're drawing.
    // This happens when the last point is clicked.

    this.drawing.points.close().hide();
    this.drawing.commit();
    this.drawing.redrawHoverTargets();
    this.drawing.points.first.antlers.basep3 = null;

    this.drawing = false;
    return this.clearPoints();
  },


  addStraightPoint(x, y) {

    // On a static click, add a point inheriting the last point's succp2 antler.
    // If there was one, this will be a SmoothTo. If there wasn't, then a LineTo.

    let point;
    let { last } = this.drawing.points;
    let { succp2 } = last.antlers;

    if ((this.drawing.points.last.antlers != null ? this.drawing.points.last.antlers.succp2 : undefined) != null) {
      if (last instanceof CurvePoint && (succp2.x !== last.x) && (succp2.y !== last.y)) {
        point = new SmoothTo(x, y, x, y, this.drawing, last);
      } else {
        point = new CurveTo(last.antlers.succp2.x, last.antlers.succp2.y, x, y, x, y, this.drawing, last);
      }
    } else {
      point = new LineTo(x, y, this.drawing);
    }

    this.drawing.points.push(point);

    if (typeof last.hideHandles === 'function') {
      last.hideHandles();
    }
    this.drawing.hidePoints();
    point.draw();

    archive.addPointExistenceEvent(this.drawing.zIndex(), point);

    this.drawing.commit().showPoints();
    return this.currentPoint = point;
  },

  addCurvePoint(x, y) {
    // CurveTo
    let x2 = x;
    let y2 = y;

    let { last } = this.drawing.points;
    if (typeof last.hideHandles === 'function') {
      last.hideHandles();
    }
    let point = new CurveTo(last.x, last.y, x, y, x, y, this.drawing, this.drawing.points.last);

    this.drawing.points.push(point);

    if ((last.antlers != null ? last.antlers.succp2 : undefined) != null) {
      point.x2 = point.prec.antlers.succp2.x;
      point.y2 = point.prec.antlers.succp2.y;
    }

    if (typeof last.hideHandles === 'function') {
      last.hideHandles();
    }
    this.drawing.hidePoints();
    point.draw();

    archive.addPointExistenceEvent(this.drawing.zIndex(), point);

    this.drawing.commit().showPoints();
    return this.currentPoint = point;
  },


  updateCurvePoint(e) {
    this.currentPoint.antlers.importNewSuccp2(new Posn(e.canvasX, e.canvasY));

    if (this.drawing.points.closed) {
      this.currentPoint.antlers.show();
      this.currentPoint.antlers.succp.persist();
    }

    this.currentPoint.antlers.lockAngle = true;
    this.currentPoint.antlers.show();
    this.currentPoint.antlers.refresh();
    return this.drawing.commit();
  },


  leaveShape(e) {
    return this.drawing = false;
  },


  hover: {
    point(e) {
      if (this.drawing) {
        switch (e.point) {
          case this.lastPoint:
            e.point.actionHint();
            let undo = e.point.antlers.hideTemp(2);
            return this.unhover.point = () => {
              undo();
              e.point.hideActionHint();
              return this.unhover.point = function() {};
            };
          case this.firstPoint:
            e.point.actionHint();
            return this.unhover.point = () => {
              e.point.hideActionHint();
              return this.unhover.point = function() {};
            };
        }
      }
    }
  },


  unhover: {},


  click: {
    background_elem(e) {
      if (!this.drawing) {
        return this.beginNewShape(e);
      } else {
        return this.addStraightPoint(e.canvasX, e.canvasY);
      }
    },

    point(e) {
      switch (e.point) {
        case this.lastPoint:
          return e.point.antlers.killSuccp2();
        case this.firstPoint:
          this.drawing.points.close();
          this.addStraightPoint(e.point.x, e.point.y);
          this.drawing.points.last.antlers.importNewSuccp2(this.drawing.points.first.antlers.succp2);
          this.drawing.points.last.antlers.lockAngle = true;

          // We've closed the shape
          return this.endShape();
        default:
          return this.click.background_elem.call(this, e);
      }
    }
  },

  mousedown: {
    all() {
      if ((this.currentPoint != null) && this.snapTo45) {
        return ui.snap.presets.every45(((this.currentPoint != null) ? this.currentPoint : this.lastPoint), "canvas");
      }
    }
  },

  activateModifier(modifier) {
    switch (modifier) {
      case "shift":
        this.snapTo45 = true;
        if ((this.currentPoint != null) || (this.lastPoint != null)) {
          return ui.snap.presets.every45(((this.currentPoint != null) ? this.currentPoint : this.lastPoint), "canvas");
        }
        break;
    }
  },

  deactivateModifier(modifier) {
    switch (modifier) {
      case "shift":
        this.snapTo45 = false;
        return ui.snap.toNothing();
    }
  },

  snapTo45: false,

  startDrag: {
    point(e) {
      if (e.point === this.firstPoint) {
        this.drawing.points.close();
        return this.addCurvePoint(e.point.x, e.point.y);
      } else {
        return this.startDrag.all(e);
      }
    },

    all(e) {
      if (this.drawing) {
        return this.addCurvePoint(e.canvasX, e.canvasY);
      } else {
        return this.beginNewShape(e);
      }
    }
  },


  continueDrag: {
    all(e, change) {
      if (this.drawing) { return this.updateCurvePoint(e); }
    }
  },


  stopDrag: {
    all(e) {
      if (this.drawing.points.closed) {
        this.currentPoint.deselect().hide();
        this.endShape();
      }
      this.lastPoint = this.currentPoint;
      return this.currentPoint = null;
    }
  }
});


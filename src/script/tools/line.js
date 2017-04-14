import tools from 'script/tools/tools';
import Tool from 'script/tools/tool';
/*


   o
    \
     \
      \
       \
        \
         \
          \
           \
            o

*/


tools.line = new Tool({

  drawing: false,
  cssid: 'crosshair',
  id: 'line',

  hotkey: '\\',

  offsetX: 7,
  offsetY: 7,

  activateModifier(modifier) {
    switch (modifier) {
      case "shift":
        let op = this.initialDragPosn;
        if (op != null) {
          return ui.snap.presets.every45(op, "canvas");
        }
        break;
    }
  },

  deactivateModifier(modifier) {
    switch (modifier) {
      case "shift":
        return ui.snap.toNothing();
    }
  },

  tearDown() {
    return this.drawing = false;
  },

  startDrag: {
    all(e) {
      this.beginNewLine(e);
      return this.initialDragPosn = e.canvasPosnZoomed;
    }
  },


  beginNewLine(e) {
    let p = e.canvasPosnZoomed;
    this.drawing = new Path({
      stroke: ui.stroke,
      fill:   ui.fill,
      'stroke-width': ui.uistate.get('strokeWidth'),
      d: `M${e.canvasX},${e.canvasY} L${e.canvasX},${e.canvasY}`});
    this.drawing.appendTo('#main');
    return this.drawing.commit();
  },


  continueDrag: {
    all(e) {
      let p = e.canvasPosnZoomed;
      this.drawing.points.last.x = p.x;
      this.drawing.points.last.y = p.y;
      return this.drawing.commit();
    }
  },


  stopDrag: {
    all() {
      this.drawing.redrawHoverTargets();
      this.drawing.commit();
      return ui.selection.elements.select(this.drawing);
    }
  }
});








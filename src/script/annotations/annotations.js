import ui from 'script/ui/ui';
import dom from 'script/dom/dom';
import Line from 'script/geometry/line';
/*

  Helper geometry layer

*/

let annotations = {

  uiMainColor: '#4982E0',

  drawLine(a, b, stroke) {
    if (stroke == null) { stroke = this.uiMainColor; }
    if (!dom.main) { return; }

    let line = new Line({
      x1: a.x,
      y1: a.y,
      x2: b.x,
      y2: b.y,
      fill: 'none',
      stroke
    });

    line.commit();
    line.appendTo('svg#annotations', false);
    return line;
  },

  drawDot(p, fill, r) {
    if (fill == null) { fill = this.uiMainColor; }
    if (r == null) { r = 3; }
    if (!dom.main) { return; }

    let dot = new Circle({
      cx: p.x,
      cy: p.y,
      r,
      fill,
      stroke: 'none'
    });

    dot.commit();
    dot.appendTo('svg#annotations', false);
    return dot;
  },

  drawDots(posns, color, r) {
    return posns.forEach(posn => {
      return this.drawDot(posn, color, r);
    });
  },

  clear() {
    return $("#annotations").empty();
  }
};


ui.annotations = annotations;

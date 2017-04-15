import Monsvg from 'script/geometry/monsvg'
import Range from 'script/geometry/range'

class Circle extends Monsvg {
  static initClass() {
    this.prototype.type = 'circle';
      // Conver to ellipse, then scale.
  
    this.prototype.points = [];
  }

  scale(factor, origin) {
    this.attr({'r'(r) { return r * factor; }});
    return this.commit();
  }

  scaleXY(x, y, origin) {}

  center() {
    return new Posn(this.data.cx, this.data.cy);
  }

  xRange() {
    return new Range(this.data.cx - this.data.r, this.data.cx + this.data.r);
  }

  yRange() {
    return new Range(this.data.cy - this.data.r, this.data.cy + this.data.r);
  }

  overlaps(other) {

    /*
      Checks for overlap with another shape.
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    */

    return this[`overlaps${other.type.capitalize()}`](other);
  }



  overlapsPolygon(polygon) {
    if (polygon.contains(this.center())) { return true; }
    for (let line of Array.from(polygon.lineSegments())) {
      if (line.intersects(this)) {
        return true;
      }
    }
    return false;
  }


  overlapsCircle(circle) {}
    // TODO

  overlapsRect(rectangle) {
    return this.overlapsPolygon(rectangle);
  }

  nudge(x, y) {
    this.attr({
      cx(cx) { return cx += x; },
      cy(cy) { return cy -= y; }
    });
    return this.commit();
  }
}
Circle.initClass();



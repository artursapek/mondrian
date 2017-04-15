import Monsvg from 'script/geometry/monsvg'
import Range from 'script/geometry/range'
import Posn from 'script/geometry/posn'
import Point from 'script/geometry/point'
import Path from 'script/geometry/path';

export default class Rect extends Monsvg {
  static initClass() {
    this.prototype.type = 'rect';
  }

  constructor(data) {
    super(data);
    this.data = data;
    if ((this.data.x == null)) { this.data.x = 0; }
    if ((this.data.y == null)) { this.data.y = 0; }

    this.data.x = parseFloat(this.data.x);
    this.data.y = parseFloat(this.data.y);
    this.data.width = parseFloat(this.data.width);
    this.data.height = parseFloat(this.data.height);
  }


  commit() {
    this._validateDimensions();
    return super.commit(...arguments);
  }


  points() {
    return [new Point(this.data.x, this.data.y),
     new Point(this.data.x + this.data.width, this.data.y),
     new Point(this.data.x + this.data.width, this.data.y + this.data.height),
     new Point(this.data.x, this.data.y + this.data.height)];
  }


  /*

    Geometric data

      points()
      lineSegments()
      center()
      xRange()
      yRange()

  */

  lineSegments() {
    let p = this.points();
    return [new LineSegment(p[0], p[1], p[1]),
     new LineSegment(p[1], p[2], p[2]),
     new LineSegment(p[2], p[3], p[3]),
     new LineSegment(p[3], p[0], p[0])];
  }

  center() {
    return new Posn(this.data.x + (this.data.width / 2), this.data.y + (this.data.height / 2));
  }

  xRange() {
    return new Range(this.data.x, this.data.x + this.data.width);
  }

  yRange() {
    return new Range(this.data.y, this.data.y + this.data.height);
  }

  clearCachedObjects() {}

  /*

    Relationship analysis

      contains()
      overlaps()
      intersections()
      containments()
      containmentsBothWays()

  */

  contains(posn) {
    return this.xRange().contains(posn.x) && this.yRange().contains(posn.y);
  }


  overlaps(other) {

    /*
      Redirects to appropriate method.

      I/P: Polygon/Circle/Rect
      O/P: true or false
    */

    return this[`overlaps${other.type.capitalize()}`](other);
  }

  overlapsPolygon(polygon) {
    return console.trace();
    /*
    if (this.contains(polygon.center() || polygon.contains(this.center()))) {
      return true;
    }
    return this.lineSegmentsIntersect(polygon);
    */
  }


  overlapsCircle(circle) {
    return console.trace();
  }

  overlapsRect(rectangle) {
    return console.trace();
    //return this.overlapsPolygon(rectangle);
  }


  intersections(obj) {
    let intersections = [];
    for (let s1 of Array.from(this.lineSegments())) {
      for (let s2 of Array.from(obj.lineSegments())) {
        let inter = s1.intersection(s2);
        if (inter instanceof Posn) {
          intersections.push(inter);
        }
      }
    }
    return intersections;
  }

  containments(obj) {
    let containments = [];
    let { points } = obj;
    let xr = this.xRange();
    let yr = this.yRange();

    for (let point of Array.from(points)) {
      if (xr.contains(point.x) && yr.contains(point.y)) {
        containments.push(point);
      }
    }
    return containments;
  }


  containmentsBothWays(obj) {
    return this.containments(obj).concat(obj.containments(this));
  }


  scale(factorX, factorY, origin) {
    if (origin == null) { origin = this.center(); }
    this.attr({
      x:      x => ((x - origin.x) * factorX) + origin.x,
      y:      y => ((y - origin.y) * factorY) + origin.y,
      width(w) { return w * factorX; },
      height(h) { return h * factorY; }
    });
    return this.commit();
  }


  nudge(x, y) {
    this.data.x += x;
    this.data.y -= y;
    return this.commit();
  }


  // Operates on perfect rectangle
  //
  // O/P: self as polygon, replaces instance with polygon instance


  convertToPath() {
    // Get this rect's points
    let pts = this.points();

    // Build a new rectangular path from it
    let path = new Path({
      d: `M${pts[0]} L${pts[1]} L${pts[2]} L${pts[3]} L${pts[0]}`});

    // Copy the colors over
    path.eyedropper(this);

    path.updateDataArchived();

    return path;
  }


  drawToCanvas(context) {
    context = this.setupToCanvas(context);
    context.rect(this.data.x, this.data.y, this.data.width, this.data.height);
    return context = this.finishToCanvas(context);
  }


  _validateDimensions() {
    if (this.data.height < 0) {
      this.data.height *= -1;
    }
    if (this.data.width < 0) {
      return this.data.width *= -1;
    }
  }
}
Rect.initClass();





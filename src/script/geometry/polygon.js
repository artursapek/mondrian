import Monsvg from 'script/geometry/monsvg'
import Range from 'script/geometry/range'

// Polygon class
//
//
//
//

export default class Polygon extends Monsvg {
  static initClass() {
    this.prototype.type = 'polygon';
  }

  constructor(data) {
    this.data = data;
    this.points = new PointsList(this.parsePoints(this.data.points));
    super(this.data);
  }

  appendTo(selector, track) {
    if (track == null) { track = true; }
    super.appendTo(selector, track);
    this.points.drawBasePoints().hide();
    if (track) { this.redrawHoverTargets(); }
    return this;
  }


  commit() {
    this.data.points = this.points.toString();
    return super.commit(...arguments);
  }

  lineSegments() {
    let { points } = this.points;
    let segments = [];
    // Recur over points, loop back to first posn at the end.
    points.map(function(curr, ind) {
      // Get the next point. If there is no next point, use the first point (loop back around)
      let next = points[ind === (points.length - 1) ? 0 : ind + 1];
      // Make the LineSegment and bail
      return segments.push(new LineSegment(curr, next));
    });

    return segments;
  }


  xs() {
    return this.points.all().map(posn => posn.x);
  }


  ys() {
    return this.points.all().map(posn => posn.y);
  }


  xRange() {
    return new Range().fromList(this.xs());
  }


  yRange() {
    return new Range().fromList(this.ys());
  }


  topLeftBound() {
    return new Posn(this.xRange().min, this.yRange().min);
  }


  topRightBound() {
    return new Posn(this.xRange().max, this.yRange().min);
  }


  bottomRightBound() {
    return new Posn(this.xRange().max, this.yRange().max);
  }


  bottomLeftBound() {
    return new Posn(this.xRange().min, this.yRange().max);
  }

  bounds() {
    let xr = this.xRange();
    let yr = this.yRange();
    return new Bounds(xr.min, yr.min, xr.length(), yr.length());
  }

  center() {
    return this.bounds().center();
  }


  parsePoints() {
    if (this.data.points === '') {
      return [];
    }

    let points = [];

    this.data.points = this.data.points.match(/[\d\,\. ]/gi).join('');

    this.data.points.split(' ').map(coords => {
      coords = coords.split(',');
      if (coords.length === 2) {
        let x = parseFloat(coords[0]);
        let y = parseFloat(coords[1]);
        let p = new Point(x, y, this);
        return points.push(p);
      }
      });

    return points;
  }

  clearCachedObjects() {}

  /*
    Transformations
      rotate
      nudge
  */

  rotate(angle, center) {
    if (center == null) { center = this.center(); }
    this.points.map(p => p.rotate(angle, center));
    this.metadata.angle += angle;
    return this.metadata.angle %= 360;
  }

  scale(x, y, origin) {
    //console.log "scale polygon", x, y, origin.toString(), "#{@points}"
    if (origin == null) { origin = this.center(); }
    this.points.map(p => p.scale(x, y, origin));
    return this.commit();
  }
    //console.log "scaled. #{@points}"

  nudge(x, y) {
    this.points.map(p => p.nudge(x, y));
    return this.commit();
  }

  contains(posn) {
    return posn.insideOf(this.lineSegments());
  }

  overlaps(other) {

    // Checks for overlap with another shape.
    // Redirects to appropriate method.

    // I/P: Polygon/Circle/Rect
    // O/P: true or false

    return this[`overlaps${other.type.capitalize()}`](other);
  }


  overlapsPolygon(polygon) {
    if (this.contains(polygon.center() || polygon.contains(this.center()))) {
      return true;
    }
    for (let line of Array.from(this.lineSegments())) {
      if (polygon.contains(line.a || polygon.contains(line.b))) {
        return true;
      }
      for (let polyLine of Array.from(polygon.lineSegments())) {
        if (polyLine.intersects(line)) {
          return true;
        }
      }
    }
    return false;
  }


  overlapsCircle(circle) {}

  overlapsRect(rectangle) {
    return this.overlapsPolygon(rectangle);
  }

  convertToPath() {
    let path = new Path({
      d: `M${this.points.at(0).x},${this.points.at(0).y}`
    });
    path.eyedropper(this);

    let old = path.points.at(0);
    for (let p of Array.from(this.points.all().slice(1))) {
      let lt = new LineTo(p.x, p.y, path, old, false);
      path.points.push(lt);
      old = lt;
    }

    path.points.close();
    return path;
  }
}
Polygon.initClass();



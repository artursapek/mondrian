import Posn from 'script/geometry/posn';
import Range from 'script/geometry/range';
import { LineTo } from 'script/geometry/path-points';
/*
  Internal representation of a straight line segment

  a
   \
    \
     \
      \
       \
        \
         \
          b

  I/P:
    a: First point
    b: Second point

*/


export default class LineSegment {
  static initClass() {
  
    this.prototype.boundsCached = undefined;
  }

  // LineSegment
  //
  // Allows you to do calculations on simple straight line segments.
  //
  // I/P : a, b Posns

  constructor(a, b, source) {
    this.a = a;
    this.b = b;
    if (source == null) { source = this.toLineTo(); }
    this.source = source;
    this.calculate();
  }

  calculate() {

    // Do some calculations at startup:
    //
    // Slope, number
    // Angle, number (degrees)
    // Length, number
    //
    // No I/P
    // O/P : self

    this.slope = (this.a.y - this.b.y) / (this.b.x - this.a.x);
    this.angle = Math.atan(this.slope) / (Math.PI / 180);
    this.length = Math.sqrt(Math.pow((this.b.x - this.a.x), 2) + Math.pow((this.b.y - this.a.y), 2));
    return this;
  }

  beginning() { return this.a; }

  end() { return this.a; }

  toString() {
    // Returns as string in "x y" format.
    return `(Line segment: ${this.a.toString()} ${this.b.toString()})`;
  }

  constructorString() {
    return `new LineSegment(${this.a.constructorString()}, ${this.b.constructorString()})`;
  }

  angle360() {
    return this.b.angle360(this.a);
  }

  toLineTo() {
    return new LineTo(this.b.x, this.b.y);
  }

  toSVGPoint() { return this.toLineTo(); }

  reverse() {
    // Note: this makes it lose its source
    return new LineSegment(this.b, this.a);
  }

  bounds(useCached) {
    if (useCached == null) { useCached = false; }
    if ((this.boundsCached != null) && useCached) {
      return this.boundsCached;
    }

    let minx = Math.min(this.a.x, this.b.x);
    let maxx = Math.max(this.a.x, this.b.x);
    let miny = Math.min(this.a.y, this.b.y);
    let maxy = Math.max(this.a.y, this.b.y);

    let width = this.width();
    let height = this.height();

    // Cache the bounds and return them at the same time

    return this.boundsCached = new Bounds(minx, miny, width, height);
  }

  rotate(angle, origin) { return new LineSegment(this.a.rotate(angle, origin), this.b.rotate(angle, origin)); }

  width() {
    return Math.abs(this.a.x - this.b.x);
  }

  height() {
    return Math.abs(this.a.y - this.b.y);
  }

  xRange() {
    // Returns a Range of x values covered
    //
    // O/P : a Range
    return new Range(Math.min(this.a.x, this.b.x), Math.max(this.a.x, this.b.x));
  }


  yRange() {
    // Returns a Range of y values covered
    //
    // O/P : a Range
    return new Range(Math.min(this.a.y, this.b.y), Math.max(this.a.y, this.b.y));
  }


  xDiff() {
    // Difference between x values of a and b points
    //
    // O/P : number

    return Math.max(this.b.x, this.a.x) - Math.min(this.b.x, this.a.x);
  }


  xbaDiff() {
    // Difference between second point x and first point x
    //
    // O/P: number

    return this.b.x - this.a.x;
  }


  yDiff() {
    // Difference between y values of a and b points
    //
    // O/P : number

    return Math.max(this.b.y, this.a.y) - Math.min(this.b.y, this.a.y);
  }


  ybaDiff() {
    // Difference between secoind point y and first point y
    //
    // O/P: number

    return this.b.y - this.a.y;
  }


  yAtX(x, extrapolate) {
    if (extrapolate == null) { extrapolate = true; }
    if (!extrapolate && !this.xRange().containsInclusive(x)) {
      return null;
    }
    return this.a.y + ((x - this.a.x) * this.slope);
  }


  xAtY(y, extrapolate) {
    if (extrapolate == null) { extrapolate = true; }
    if (!extrapolate && !this.yRange().containsInclusive(y)) {
      return null;
    }
    return this.a.x + ((y - this.a.y) / this.slope);
  }


  ends() {
    return [a, b];
  }

  posnAtPercent(p) {
    // I/P: p, number between 0 and 1
    // O/P: Posn at that point on the LineSegment

    return new Posn(this.a.x + ((this.b.x - this.a.x) * p), this.a.y + ((this.b.y - this.a.y) * p));
  }


  findPercentageOfPoint(p) {
    // I/P: A single Posn
    // O/P: A floating point value

    let distanceA = p.distanceFrom(this.a);
    return distanceA / (distanceA + p.distanceFrom(this.b));
  }


  splitAt(p, forced) {
    // I/P: p, a float between 0 and 1
    //
    // O/P: Array with two LineSegments

    // So we're allowed to pass either a floating point value
    // or a Posn. Or a list of Posns.
    //
    // If given Posns, we have to calculate the float for each and then recur.

    if (forced == null) { forced = null; }
    if (typeof p === "number") {
      let split = forced ? forced : this.posnAtPercent(p);
      return [new LineSegment(this.a, split), new LineSegment(split, this.b)];

    } else if (p instanceof Array) {
      let segments = [];
      let distances = {};

      for (var posn of Array.from(p)) {
        distances[posn.distanceFrom(this.a)] = posn;
      }

      let distancesSorted = Object.keys(distances).map(parseFloat).sort(sortNumbers);
       // ARE YOU FUICKING SERIOUS JAVASCRIPT

      let nextA = this.a;

      for (let key of Array.from(distancesSorted)) {
        posn = distances[key];
        segments.push(new LineSegment(nextA, posn));
        nextA = posn;
      }

      segments.push(new LineSegment(nextA, this.b));

      return segments;


    } else if (p instanceof Posn) {
      // Given a single Posn, find how far along it is on the line
      // and recur with that floating point value.
      return [new LineSegment(this.a, p), new LineSegment(p, this.b)];
    }
  }

  midPoint() {
    return this.splitAt(0.5)[0].b;
  }

  nudge(x, y) {
    this.a.nudge(x, y);
    return this.b.nudge(x, y);
  }

  scale(x, y, origin) {
    this.a.scale(x, y, origin);
    return this.b.scale(x, y, origin);
  }

  equal(ls) {
    if (ls instanceof CubicBezier) { return false; }
    return ((this.a.equal(ls.a)) && (this.b.equal(ls.b))) || ((this.a.equal(ls.b)) && (this.b.equal(ls.a)));
  }
}
LineSegment.initClass();


// TODO RM HACK
window.LineSegment = LineSegment;

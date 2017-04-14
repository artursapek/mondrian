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

  intersects(s) {
    // Does it have an intersection with ...?
    let inter = this.intersection(s);
    return inter instanceof Posn || inter instanceof Array;
  }

  intersection(s) {
    // What is its intersection with ...?
    if (s instanceof LineSegment) {
      return this.intersectionWithLineSegment(s);
    } else if (s instanceof Circle) {
      return this.intersectionWithCircle(s);
    } else if (s instanceof CubicBezier) {
      return s.intersectionWithLineSegment(this);
    }
  }


  intersectionWithLineSegment(s) {
    /*
      Get intersection with another LineSegment

      I/P : LineSegment

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */

    let ana_s = (s.xbaDiff() * (this.a.y - s.a.y)) - (s.ybaDiff() * (this.a.x - s.a.x));
    let ana_m = (this.xbaDiff() * (this.a.y - s.a.y)) - (this.ybaDiff() * (this.a.x - s.a.x));
    let crossDiff  = (s.ybaDiff() * this.xbaDiff()) - (s.xbaDiff() * this.ybaDiff());

    if (crossDiff !== 0) {
      let anas = ana_s / crossDiff;
      let anam = ana_m / crossDiff;

      if ((0 <= anas) && (anas <= 1) && (0 <= anam) && (anam <= 1)) {
        return new Posn(this.a.x + (anas * (this.b.x - this.a.x)), this.a.y + (anas * (this.b.y - this.a.y)));
      } else {
        return null;
      }
    } else {
      if ((ana_s === 0) || (ana_m === 0)) {
        // Coinicident (identical)
        return Infinity;
      } else {
        // Parallel
        return 0;
      }
    }
  }


  intersectionWithEllipse(s) {
    /*
     Get intersection with an ellipse

     I/P: Ellipse

     O/P: null if no intersections, or Array of Posn(s) if there are

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */


    let { rx } = s.data;
    let { ry } = s.data;
    let { cx } = s.data;
    let { cy } = s.data;

    let origin = new Posn(this.a.x, this.a.y);
    let dir    = new Posn(this.b.x - this.a.x, this.b.y - this.a.y);
    let center = new Posn(cx, cy);
    let diff   = origin.subtract(center);
    let mDir   = new Posn(dir.x / (rx * rx), dir.y / (ry * ry));
    let mDiff  = new Posn(diff.x / (rx * rx), diff.y / (ry * ry));

    let results = [];

    let a = dir.dot(mDir);
    let b = dir.dot(mDiff);
    let c = diff.dot(mDiff) - 1.0;
    let d = (b * b) - (a * c);

    if (d < 0) {
      // Line is outside ellipse
      return null;
    } else if (d > 0) {
      let root = Math.sqrt(d);
      let t_a = (-b - root) / a;
      let t_b = (-b + root) / a;

      if (((t_a < 0) || (1 < t_a)) && ((t_b < 0) || (1 < t_b))) {
        if (((t_a < 0) && (t_b < 0)) && ((t_a > 1) && (t_b > 1))) {
          // Line is outside ellipse
          return null;
        } else {
          // Line is inside ellipse
          return null;
        }
      } else {
        if ((0 <= t_a) && (t_a <= 1)) {
          results.push(this.a.lerp(this.b, t_a));
        }
        if ((0 <= t_b) && (t_b <= 1)) {
          results.push(this.a.lerp(this.b, t_b));
        }
      }
    } else {
        let t = -b / a;
        if ((0 <= t) && (t <= 1)) {
          results.push(this.a.lerp(this.b, t));
        } else {
          return null;
        }
      }

    return results;
  }


  intersectionWithCircle(s) {
    /*
      Get intersection with a circle

      I/P : Circle

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */

    let a = Math.pow(this.xDiff(), 2) + Math.pow(this.yDiff(), 2);
    let b = 2 * (((this.b.x - this.a.x) * (this.a.x - s.data.cx)) + ((this.b.y - this.a.y) * (this.a.y - s.data.cy)));
    let cc = (Math.pow(s.data.cx, 2) + Math.pow(s.data.cy, 2) + Math.pow(this.a.x, 2) + Math.pow(this.a.y, 2)) -
         (2 * ((s.data.cx * this.a.x) + (s.data.cy * this.a.y))) - Math.pow(s.data.r, 2);
    let deter = (b * b) - (4 * a * cc);

    if (deter < 0) {
      return null; // No intersection
    } else if (deter === 0) {
      return 0; // Tangent
    } else {
      let e = Math.sqrt(deter);
      let u1 = (-b + e) / (2 * a);
      let u2 = (-b - e) / (2 * a);

      if (((u1 < 0) || (u1 > 1)) && ((u2 < 0) || (u2 > 1))) {
        if (((u1 < 0) && (u2 < 0)) || ((u1 > 1) && (u2 > 1))) {
          return null; // No intersection
        } else {
          return true; // It's inside
        }
      } else {
        let ints = [];

        if ((0 <= u1) && (u1 <= 1)) {
          ints.push(this.a.lerp(this.b, u1));
        }

        if ((0 <= u2) && (u2 <= 1)) {
          ints.push(this.a.lerp(this.b, u2));
        }

        return ints;
      }
    }
  }
}
LineSegment.initClass();



/*

  Posn

    •
      (x, y)


  Lowest-level geometry class.

  Consists of x, y coordinates. Provides methods for manipulating or representing
  the point in two-dimensional space.

  Superclass: Point

*/

export default class Posn {

  constructor(x1, y1, zoomLevel) {
    // I/P:
    //   x: number
    //   y: number
    //
    //     OR
    //
    //   e: Event object with clientX and clientY values

    this.x = x1;
    this.y = y1;
    if (zoomLevel == null) { zoomLevel = 1.0; }
    this.zoomLevel = zoomLevel;
    if (this.x instanceof Object) {
      // Support for providing an Event object as the only arg.
      // Reads the clientX and clientY values
      if ((this.x.clientX != null) && (this.x.clientY != null)) {
        this.y = this.x.clientY;
        this.x = this.x.clientX;
      } else if ((this.x.left != null) && (this.x.top != null)) {
        this.y = this.x.top;
        this.x = this.x.left;
      } else if ((this.x.x != null) && (this.x.y != null)) {
        this.y = this.x.y;
        this.x = this.x.x;
      }

    } else if ((typeof this.x === "string") && (this.x.mentions(","))) {
      // Support for giving a string of two numbers and a comma "12.3,840"
      let split = this.x.split(",").map(parseFloat);
      let x = split[0];
      let y = split[1];
      this.x = x;
      this.y = y;
    }

    // That's fucking it.
    this;
  }

  // Rounding an you know

  cleanUp() {
    // TODO
    // This was giving me NaN bullshit. Don't enable again until the app is stable
    // and we can test it properly
    return;
    this.x = cleanUpNumber(this.x);
    return this.y = cleanUpNumber(this.y);
  }


  // Zoom compensation

  // By default, all Posns are interpreted as they are explicitly invoked. x is x, y is y.
  // You can call Posn.zoom() to ensure you're using a zoom-adjusted version of this Posn.
  //
  // In this case, x is x times the zoom level, and the same goes for y.
  //
  // Posn.unzoom() takes it back to zoom-agnostic mode - 1.0


  zoomed(level) {
    // Return this Posn after ensuring it is at the given zoom level.
    // If no level is given, current zoom level of document is used.
    //
    // I/P: level: float (optional)
    //
    // O/P: adjusted Posn

    if (level == null) { level = ui.canvas.zoom; }
    if (this.zoomLevel === level) { return this; }

    this.unzoomed();

    this.alterValues(val => val *= level);
    this.zoomLevel = level;
    return this;
  }


  unzoomed() {
    // Return this Posn after ensuring it is in 100% "true" mode.
    //
    // No I/P
    //
    // O/P: adjusted Posn

    if (this.zoomLevel === 1.0) { return this; }

    this.alterValues(val => val /= this.zoomLevel);
    this.zoomLevel = 1.0;
    return this;
  }


  setZoom(zoomLevel) {
    this.zoomLevel = zoomLevel;
    this.x /= this.zoomLevel;
    this.y /= this.zoomLevel;
    return this;
  }


  // Aliases:


  zoomedc() {
    return this.clone().zoomed();
  }


  unzoomedc() {
    return this.clone.unzoomed();
  }


  // Helper:


  alterValues(fun) {
    // Do something to all the values this Posn has. Kind of like map, but return is immediately applied.
    //
    // Since Posns get superclassed into Points which get superclassed into CurvePoints,
    // they may have x2, y2, x3, y3 attributes. This checks which ones it has and alters all of them.
    //
    // I/P: fun: one-argument function to be called on each of this Posn's values.
    //
    // O/P: self

    for (let a of ["x", "y", "x2", "y2", "x3", "y3"]) {
      this[a] = (this[a] != null) ? fun(this[a]) : this[a];
    }
    return this;
  }


  toString() {
    return `${this.x},${this.y}`;
  }

  toJSON() {
    return {
      x: this.x,
      y: this.y
    };
  }

  toConstructorString() {
    return `new Posn(${this.x},${this.y})`;
  }


  nudge(x, y) {
    this.x += x;
    this.y -= y;

    return this;
  }

  lerp(b, factor) {
    return new Posn(this.x + ((b.x - this.x) * factor), this.y + ((b.y - this.y) * factor));
  }

  gte(p) {
    return (this.x >= p.x) && (this.y >= p.y);
  }

  lte(p) {
    return (this.x <= p.x) && (this.y <= p.y);
  }

  directionRelativeTo(p) {
    return `${this.y < p.y ? "t" : (this.y > p.y ? "b" : "")}${this.x < p.x ? "l" : (this.x > p.x ? "r" : "")}`;
  }

  squareUpAgainst(p) {
    // Takes another posn as an anchor, and nudges this one
    // so that it's on the nearest 45° going off of the anchor posn.

    let xDiff = Math.abs(this.x - p.x);
    let yDiff = Math.abs(this.y - p.y);
    let direction = this.directionRelativeTo(p);

    if ((xDiff === 0) && (yDiff === 0)) { return p; }

    switch (direction) {
      case "tl":
        if (xDiff < yDiff) {
          this.nudge(xDiff - yDiff, 0);
        } else if (yDiff < xDiff) {
          this.nudge(0, xDiff - yDiff, 0);
        }
        break;
      case "tr":
        if (xDiff < yDiff) {
          this.nudge(yDiff - xDiff, 0);
        } else if (yDiff < xDiff) {
          this.nudge(0, xDiff - yDiff);
        }
        break;
      case "br":
        if (xDiff < yDiff) {
          this.nudge(yDiff - xDiff, 0);
        } else if (yDiff < xDiff) {
          this.nudge(0, yDiff - xDiff);
        }
        break;
      case "bl":
        if (xDiff < yDiff) {
          this.nudge(xDiff - yDiff, 0);
        } else if (yDiff < xDiff) {
          this.nudge(0, yDiff - xDiff);
        }
        break;
      case "t": case "b":
        this.nudge(yDiff, 0);
        break;
      case "r": case "l":
        this.nudge(0, xDiff);
        break;
    }
    return this;
  }


  equal(p) {
    return (this.x === p.x) && (this.y === p.y);
  }

  min(p) {
    return new Posn(Math.min(this.x, p.x), Math.min(this.y, p.y));
  }

  max(p) {
    return new Posn(Math.max(this.x, p.x), Math.max(this.y, p.y));
  }

  angle360(base) {
    let a = 90 - new LineSegment(base, this).angle;
    return a + (this.x < base.x ? 180 : 0);
  }

  rotate(angle, origin) {

    if (origin == null) { origin = new Posn(0, 0); }
    if (origin.equal(this)) { return this; }

    angle *= (Math.PI / 180);

    // Normalize the point on the origin.
    this.x -= origin.x;
    this.y -= origin.y;

    let x = (this.x * (Math.cos(angle))) - (this.y * Math.sin(angle));
    let y = (this.x * (Math.sin(angle))) + (this.y * Math.cos(angle));

    // Move points back to where they were.
    this.x = x + origin.x;
    this.y = y + origin.y;

    return this;
  }

  scale(x, y, origin) {
    if (origin == null) { origin = new Posn(0, 0); }
    this.x += (this.x - origin.x) * (x - 1);
    this.y += (this.y - origin.y) * (y - 1);
    return this;
  }

  copy(p) {
    this.x = p.x;
    return this.y = p.y;
  }


  clone() {
    // Just make a new Posn, and maintain the zoomLevel
    return new Posn(this.x, this.y, this.zoomLevel);
  }


  snap(to, threshold) {
    // Algorithm: bisect the line on this posn's x and y
    // coordinates and return the midpoint of that line.
    if (threshold == null) { threshold = Math.INFINITY; }
    let perpLine = this.verti(10000);
    perpLine.rotate(to.angle360() + 90, this);
    return perpLine.intersection(to);
  }


  reflect(posn) {
    /*

      Reflect the point over an x and/or y axis

      I/P:
        posn: Posn

    */

    let { x } = posn;
    let { y } = posn;

    return new Posn(x + (x - this.x), y + (y - this.y));
  }

  distanceFrom(p) {
    return new LineSegment(this, p).length;
  }

  perpendicularDistanceFrom(ls) {
    let ray = this.verti(1e5);
    ray.rotate(ls.angle360() + 90, this);
    //ui.annotations.drawLine(ray.a, ray.b)
    let inter = ray.intersection(ls);
    if (inter != null) {
      ls = new LineSegment(this, inter);
      let len = ls.length;
      return [len, inter, ls];
    } else {
      return null;
    }
  }

  multiplyBy(s) {
    switch (typeof s) {
      case 'number':
        let np = this.clone();
        np.x *= s;
        np.y *= s;
        return np;
      case 'object':
        np = this.clone();
        np.x *= s.x;
        np.y *= s.y;
        return np;
    }
  }

  multiplyByMutable(s) {
    this.x *= s;
    this.y *= s;

    if (this.x2 != null) {
      this.x2 *= s;
      this.y2 *= s;
    }

    if (this.x3 != null) {
      this.x3 *= s;
      return this.y3 *= s;
    }
  }

  add(s) {
    switch (typeof s) {
      case 'number':
        return new Posn(this.x + s, this.y + s);
      case 'object':
        return new Posn(this.x + s.x, this.y + s.y);
    }
  }

  subtract(s) {
    switch (typeof s) {
      case 'number':
        return new Posn(this.x - s, this.y - s);
      case 'object':
        return new Posn(this.x - s.x, this.y - s.y);
    }
  }

  setPrec(prec) {
    this.prec = prec;
  }

  setSucc(succ) {
    this.succ = succ;
  }


  /*
      I love you artur
      hackerkate nows the sick code
  */

  inRanges(xr, yr) {
    return xr.contains(this.x && yr.contains(this.y));
  }

  inRangesInclusive(xr, yr) {
    return xr.containsInclusive(this.x) && yr.containsInclusive(this.y);
  }

  verti(ln) {
    return new LineSegment(this.clone().nudge(0, -ln), this.clone().nudge(0, ln));
  }

  insideOf(shape) {
    // Draw a horizontal ray starting at this posn.
    // If it intersects the shape's perimeter an odd
    // number of times, the posn's inside of it.
    //
    //    _____
    //  /      \
    // |   o----X------------
    //  \______/
    //
    //  1 intersection - it's inside.
    //
    //    __         __
    //  /   \      /    \
    // |  o--X----X-----X---------
    // |      \__/      |
    //  \______________/
    //
    //  3 intersections - it's inside.
    //
    //  etc.

    if (shape instanceof Polygon || shape instanceof Path) {
      let ray = new LineSegment(this, new Posn(this.x + 1e+20, this.y));
      let counter = 0;
      shape.lineSegments().map(function(a) {
        let inter = a.intersection(ray);
        if (inter instanceof Posn) {
          return ++ counter;
        } else if (inter instanceof Array) {
          return counter += inter.length;
        }
      });

      // If there's an odd number of intersections, we are inside.
      return (counter % 2) === 1;
    }

    // Rect
    // This one is trivial. Method lives in the Rect class.
    if (shape instanceof Rect) {
      return shape.contains(this);
    }
  }


  dot(v) {
    return (this.x * v.x) + (this.y * v.y);
  }

  within(tolerance, posn) {
    return (Math.abs(this.x - posn.x) < tolerance) && (Math.abs(this.y - posn.y) < tolerance);
  }

  parseInt() {
    this.x = parseInt(this.x, 10);
    return this.y = parseInt(this.y, 10);
  }
}


Posn.fromJSON = json => new Posn(json.x, json.y);


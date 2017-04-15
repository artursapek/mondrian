import Posn from 'script/geometry/posn';
import Point from 'script/geometry/point';
/*

  Path points

  MoveTo
    Mx,y
    Begin a path at x,y

  LineTo
    Lx,y
    Draw straight line from pvx,pvy to x,y

  CurveTo
    Cx1,y1 x2,y2 x,y
    Draw a line to x,y.
    x1,y1 is the control point put on the previous point
    x2,y2 is the control point put on this point (x,y)

  SmoothTo
    Sx2,y2 x,y
    Shorthand for curveto. x1,y1 becomes x2,y2 from previous CurveTo.

  HorizTo
    Hx
    Draw a horizontal line inheriting the y-value from precessor

  VertiTo
    Vy
    Draw a vertical line inheriting the x-value from precessor

*/

export class PathPoint extends Point {
  constructor(x, y, owner, prec, rel) {
    super(x, y, owner);
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
  }

  static fromString(point, owner, prec) {
    // Given a string like "M 10.2 502.19"
    // return the corresponding Point.
    // Returns one of:
    //   MoveTo
    //   CurveTo
    //   SmoothTo
    //   LineTo
    //   HorizTo
    //   VertiTo

    let patterns = {
      moveTo:   /M[^A-Za-z]+/gi,
      lineTo:   /L[^A-Za-z]+/gi,
      curveTo:  /C[^A-Za-z]+/gi,
      smoothTo: /S[^A-Za-z]+/gi,
      horizTo:  /H[^A-Za-z]+/gi,
      vertiTo:  /V[^A-Za-z]+/gi
    };

    let classes = {
      moveTo:   MoveTo,
      lineTo:   LineTo,
      curveTo:  CurveTo,
      smoothTo: SmoothTo,
      horizTo:  HorizTo,
      vertiTo:  VertiTo
    };

    let lengths = {
      moveTo:   2,
      lineTo:   2,
      curveTo:  6,
      smoothTo: 4,
      horizTo:  1,
      vertiTo:  1
    };

    let pairs = /[-+]?\d*\.?\d*(e\-)?\d*/g;

    // It's possible in SVG to list several sets of coords
    // for one character key. For example, "L 10 20 40 50"
    // is actually two seperate LineTos: a (10, 20) and a (40, 50)
    //
    // So we build the point(s) into an array, and return points[0]
    // if there's one, or the whole array if there's more.
    let points = [];

    for (let key in patterns) {
      // Find which pattern this string matches.
      // This check uses regex to also validate the point's syntax at the same time.

      let val = patterns[key];
      let matched = point.match(val);

      if (matched !== null) {

        // Matched will not be null when we find the correct point from the 'pattern' regex collection.
        // Match for the cooridinate pairs inside this point (1-3 should show up)
        // These then get mapped with parseFloat to get the true values, as coords

        let coords = (point.match(pairs)).filter(p => p.length > 0).map(parseFloat);

        let relative = point.substring(0,1).match(/[mlcshv]/) !== null; // Is it lower-case? So it's relative? Shit!

        let clen = coords.length;
        let elen = lengths[key]; // The expected amount of values for this kind of point

        // If the number of coordinates checks out, build the point(s)
        if ((clen % elen) === 0) {

          let sliceAt = 0;

          for (let i = 0, end = (clen / elen) - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
            let set = coords.slice(sliceAt, sliceAt + elen);

            if (i > 0) {
              if (key === "moveTo") {
                key = "lineTo";
              }
            }

            let values = [null].concat(set);

            values.push(owner); // Point owner
            values.push(prec);
            values.push(relative);

            if (values.join(' ').mentions("NaN")) { debugger; }

            // At this point, values should be an array that looks like this:
            //   [null, 100, 120, 300.5, 320.5, Path]
            // The amount of numbers depends on what kind of point we're making.

            // Build the point from the appropriate constructor

            let constructed = new (Function.prototype.bind.apply(classes[key], values));

            points.push(constructed);

            sliceAt += elen;
          }

        } else {
          // We got a weird amount of points. Dunno what to do with that.
          // TODO maybe I should actually rethink this later to be more robust: like, parse what I can and
          // ignore the rest. Idk if that would be irresponsible.
          throw new Error(`Wrong amount of coordinates: ${point}. Expected ${elen} and got ${clen}.`);
        }

        // Don't keep looking
        break;
      }
    }

    if (points.length === 0) {
      // We have no clue what this is, cuz
      throw new Error(`Unreadable path value: ${point}`);
    }

    if (points.length === 1) {
      return points[0];
    } else {
      return points;
    }
  }
}

export class MoveTo extends PathPoint {
  constructor(x, y, owner, prec, rel) {
    super(...arguments);
  }


  relative() {
    if (this.at === 0) {
      this.rel = false;
      return this;
    } else {
      if (this.rel) { return this; }

      let precAbs = this.prec.absolute();
      let { x } = precAbs;
      let { y } = precAbs;

      let m = new MoveTo(this.x - x, this.y - y, this.owner);
      m.rel = true;
      return m;
    }
  }

  absolute() {
    if (this.at === 0) {
      this.rel = false;
      return this;
    } else {
      if (!this.rel) { return this; }

      let precAbs = this.prec.absolute();
      let { x } = precAbs;
      let { y } = precAbs;

      let m = new MoveTo(this.x + x, this.y + y, this.owner);
      m.rel = false;
      return m;
    }

    return Array.from(points.match(/[MLCSHV][\-\de\.\,\-\s]+/gi)).map((point) => new Point(point, this.owner));
  }

  p2() {
    if ((this.antlers != null ? this.antlers.succp2 : undefined) != null) {
      return new Posn(this.antlers.succp2.x, this.antlers.succp2.y);
    } else {
      return null;
    }
  }

  toString() { return `${this.rel ? "m" : "M"}${this.x},${this.y}`; }

  toLineSegment() {
    return this.prec.toLineSegment();
  }

  // I know this can be abstracted somehow with bind and apply but I
  // don't have time to figure that out before launch - already wasted time trying
  clone() { return new MoveTo(this.x, this.y, this.owner, this.prec, this.rel); }
}


export class LineTo extends PathPoint {
  constructor(x, y, owner, prec, rel) {
    super(...arguments);
  }

  relative() {
    if (this.rel) { return this; }

    let precAbs = this.prec.absolute();
    let { x } = precAbs;
    let { y } = precAbs;

    let l = new LineTo(this.x - x, this.y - y, this.owner);
    l.rel = true;
    return l;
  }

  absolute() {
    if (!this.rel) { return this; }
    if (this.absoluteCached) {
      return this.absoluteCached;
    }


    let precAbs = this.prec.absolute();
    let { x } = precAbs;
    let { y } = precAbs;

    let l = new LineTo(this.x + x, this.y + y, this.owner);
    l.rel = false;

    this.absoluteCached = l;

    return l;
  }

  toString() { return `${this.rel ? 'l' : 'L'}${this.x},${this.y}`; }

  clone() { return new LineTo(this.x, this.y, this.owner, this.prec, this.rel); }
}




export class HorizTo extends PathPoint {
  constructor(x, owner, prec, rel) {
    super(...arguments);
    this.inheritFromPrec(this.prec);
  }

  inheritFromPrec(prec) {
    this.prec = prec;
    return this.y = this.prec.absolute().y;
  }

  toString() {
    return `${this.rel ? 'h' : 'H'}${this.x}`;
  }

  convertToLineTo() {
    // Converts and replaces this with an equivalent LineTo
    // Returns the resulting LineTo so it can be operated on.
    let lineTo = new LineTo(this.x, this.y);
    this.replaceWith(lineTo);
    return lineTo;
  }

  rotate(a, origin) {
    return this.convertToLineTo().rotate(a, origin);
  }

  absolute() {
    if (!this.rel) { return this; }
    if (this.absoluteCached) { return this.absoluteCached; }
    return this.absoluteCached = new HorizTo(this.x + this.prec.absolute().x, this.owner, this.prec, false);
  }

  relative() {
    if (this.rel) { return this; }
    return new HorizTo(this.x - this.prec.absolute().x, this.owner, this.prec, true);
  }

  clone() { return new HorizTo(this.x, this.owner, this.prec, this.rel); }
}



export class VertiTo extends PathPoint {
  constructor(y, owner, prec, rel) {
    super(...arguments);
    this.inheritFromPrec(this.prec);
  }

  inheritFromPrec(prec) {
    this.prec = prec;
    return this.x = this.prec.absolute().x;
  }

  toString() { return `${this.rel ? 'v' : 'V'}${this.y}`; }

  convertToLineTo() {
    // Converts and replaces this with an equivalent LineTo
    // Returns the resulting LineTo so it can be operated on.
    let lineTo = new LineTo(this.x, this.y);
    this.replaceWith(lineTo);
    return lineTo;
  }

  rotate(a, origin) {
    return this.convertToLineTo().rotate(a, origin);
  }

  absolute() {
    if (!this.rel) { return this; }
    if (this.absoluteCached) { return this.absoluteCached; }
    return this.absoluteCached = new VertiTo(this.y + this.prec.absolute().y, this.owner, this.prec, false);
  }

  relative() {
    if (this.rel) { return this; }
    return new VertiTo(this.y - this.prec.absolute().y, this.owner, this.prec, true);
  }

  clone() { return new VertiTo(this.y, this.owner, this.prec, this.rel); }
}







/*

  CurvePoint

  A Point that has handles. Builds the handles in its constructor.

*/

export class CurvePoint extends PathPoint {
  constructor(x2, y2, x3, y3, x, y, owner, prec, rel) {
    super(x, y, owner, prec, rel);
    this.x2 = x2;
    this.y2 = y2;
    this.x3 = x3;
    this.y3 = y3;
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    /*

      This Class just extends into CurveTo and SmoothTo as a way of abstracting out the curve
      handling the control points. It has two control points in addition to the base point (handled by super)

      Each point has a predecessor and a successor (in terms of line segments).

      It has two control points:
        (@x2, @y2) is the first curve control point (p2), which becomes @p2h
        (@x3, @y3) is the second (p3), which becomes @p3h
      (Refer to ASCII art at top of cubic-bezier-line-segment.coffee for point name reference)

      Dragging these mofos will alter the correct control point(s), which will change the curve

      I/P:
        x2, y2: control point (p2)
        x3, y3: control point (p3)
        x, y:   next base point (like any other point)
        owner:  elem that owns this shape (supered into Point)
        prec:   point that comes before it
        rel:    bool - true if it's relative or false if it's absolute

    */
  }


  p2() {
    return new Posn(this.x2, this.y2);
  }


  p3() {
    return new Posn(this.x3, this.y3);
  }


  p() {
    return new Posn(this.x, this.y);
  }


  absorb(p, n) {
    // I/P: p, Posn
    //      n, 2 or 3 (p2 or p3)
    // Given a Posn/Point and an int (2 or 3), sets @x2/@x3 and @y2/@y3 to p's coordinats.
    // Abstracted method for updating a specific bezier curve control point.

    this[`x${n}`] = p.x;
    return this[`y${n}`] = p.y;
  }


  show() {
    if (!this.owner) { return this; } // Orphan points should be ignored (usually used in testing)
    return super.show(...arguments);
  }


  cleanUp() {
    return;
    this.x2 = cleanUpNumber(this.x2);
    this.y2 = cleanUpNumber(this.y2);
    this.x3 = cleanUpNumber(this.x3);
    this.y3 = cleanUpNumber(this.y3);
    return super.cleanUp(...arguments);
  }


  scale(x, y, origin) {
    this.absorb(this.p2().scale(x, y, origin), 2);
    this.absorb(this.p3().scale(x, y, origin), 3);
    return super.scale(x, y, origin);
  }


  rotate(a, origin) {
    this.absorb(this.p2().rotate(a, origin), 2);
    this.absorb(this.p3().rotate(a, origin), 3);
    return super.rotate(a, origin);
  }


  relative() {
    if (this.rel) { return this; }

    // Assuming it's absolute now we want to subtract the precessor...
    // The base case here is a MoveTo, which will always be absolute.
    let precAbs = this.prec.absolute();
    let { x } = precAbs;
    let { y } = precAbs;

    // Now we make a new one of whatever this is.
    // @constructor will point to either CurveTo or SmoothTo, in this case.
    // Since those both take the same arguments, simply subtract the precessor's absolute coords
    // from this one's absolute coords and we're in business!
    let args = [this.x2 - x, this.y2 - y, this.x3 - x, this.y3 - y, this.x - x, this.y - y, this.owner, this.prec];
    if (this.constructor === SmoothTo) {
      args = args.slice(2);
    }
    args.unshift(null);

    let c = new (Function.prototype.bind.apply(this.constructor, args));
    c.rel = true;
    return c;
  }

  absolute() {
    // This works the same way as relative but opposite.
    if (!this.rel) { return this; }

    let precAbs = this.prec.absolute();
    let { x } = precAbs;
    let { y } = precAbs;

    let args = [this.x2 + x, this.y2 + y, this.x3 + x, this.y3 + y, this.x + x, this.y + y, this.owner, this.prec];
    if (this.constructor === SmoothTo) {
      args = args.slice(2);
    }
    args.unshift(null);

    let c = new (Function.prototype.bind.apply(this.constructor, args));

    c.rel = false;

    return c;
  }
}


export class CurveTo extends CurvePoint {
  constructor(x2, y2, x3, y3, x, y, owner, prec, rel) {
    super(x2, y2, x3, y3, x, y, owner, prec, rel);
    this.x2 = x2;
    this.y2 = y2;
    this.x3 = x3;
    this.y3 = y3;
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
  }

  toString() { return `${this.rel ? 'c' : 'C'}${this.x2},${this.y2} ${this.x3},${this.y3} ${this.x},${this.y}`; }

  reverse() {
    return new CurveTo(this.x3, this.y3, this.x2, this.y2, this.x, this.y, this.owner, this.prec, this.rel).inheritPosition(this);
  }

  clone() { return new CurveTo(this.x2, this.y2, this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel); }
}


export class SmoothTo extends CurvePoint {
  constructor(x3, y3, x, y, owner, prec, rel) {
    // TODO FIX???? 0 0???
    super(0, 0, x3, y3, x, y, owner, prec, rel);
    this.x3 = x3;
    this.y3 = y3;
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    this.inheritFromPrec(this.prec);
  }

  inheritFromPrec(prec) {
    // Since a SmoothTo's p2 is a reflection of its precessor's p3 over
    // its previous point, we need to query that info from its precessor.
    let p2;
    this.prec = prec;
    if (this.prec instanceof CurvePoint) {
      let precAbs = this.prec.absolute();
      p2 = new Posn(precAbs.x3, precAbs.y3).reflect(precAbs);
    } else {
      p2 = new Posn(this.x, this.y); // No p2 to inherit, so just nullify it
    }

    this.x2 = p2.x;
    return this.y2 = p2.y;
  }


  toCurveTo(p2) {
    if (p2 == null) { p2 = null; }
    if (p2 === null) {
      if (this.prec instanceof CurvePoint) {
        p2 = this.prec.p3().reflect(this.prec.p());
      } else {
        p2 = new Posn(this.x, this.y);
      }
    }

    let ct = new CurveTo(p2.x, p2.y, this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel);
    ct.at = this.at;
    return ct;
  }

  replaceWithCurveTo(p2) {
    if (p2 == null) { p2 = null; }
    return this.replaceWith(this.toCurveTo(p2));
  }

  toString() { return `${this.rel ? 's' : 'S'}${this.x3},${this.y3} ${this.x},${this.y}`; }

  reverse() { return new CurveTo(this.x3, this.y3, this.x2, this.y2, this.x, this.y, this.owner, this.prec, this.rel); }

  clone() { return new SmoothTo(this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel); }
}


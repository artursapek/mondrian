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


class MoveTo extends Point {
  constructor(x, y, owner, prec, rel) {
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    super(this.x, this.y, this.owner);
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


class LineTo extends Point {
  constructor(x, y, owner, prec, rel) {
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    super(this.x, this.y, this.owner);
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




class HorizTo extends Point {
  constructor(x, owner, prec, rel) {
    this.x = x;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    this.inheritFromPrec(this.prec);
    super(this.x, this.y, this.owner);
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



class VertiTo extends Point {
  constructor(y, owner, prec, rel) {
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    this.inheritFromPrec(this.prec);
    super(this.x, this.y, this.owner);
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

class CurvePoint extends Point {
  constructor(x2, y2, x3, y3, x, y, owner, prec, rel) {
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

    super(this.x, this.y, this.owner);
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


class CurveTo extends CurvePoint {
  constructor(x2, y2, x3, y3, x, y, owner, prec, rel) {
    this.x2 = x2;
    this.y2 = y2;
    this.x3 = x3;
    this.y3 = y3;
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    super(this.x2, this.y2, this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel);
  }

  toString() { return `${this.rel ? 'c' : 'C'}${this.x2},${this.y2} ${this.x3},${this.y3} ${this.x},${this.y}`; }

  reverse() {
    return new CurveTo(this.x3, this.y3, this.x2, this.y2, this.x, this.y, this.owner, this.prec, this.rel).inheritPosition(this);
  }

  clone() { return new CurveTo(this.x2, this.y2, this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel); }
}


class SmoothTo extends CurvePoint {
  constructor(x3, y3, x, y, owner, prec, rel) {

    this.x3 = x3;
    this.y3 = y3;
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.prec = prec;
    this.rel = rel;
    this.inheritFromPrec(this.prec);

    super(this.x2, this.y2, this.x3, this.y3, this.x, this.y, this.owner, this.prec, this.rel);
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


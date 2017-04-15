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

  nudge(x, y) {
    if (this.basep3 != null) {
      this.basep3.nudge(x, y);
    }
    if (this.succp2 != null) {
      this.succp2.nudge(x, y);
    }
    if (this.succ() instanceof CurvePoint) {
      this.succ().x2 += x;
      this.succ().y2 -= y;
    }

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



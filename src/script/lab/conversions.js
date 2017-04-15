import CONSTANTS from 'script/constants';
import Posn from 'script/geometry/posn';
import CubicBezier from 'script/geometry/cubic-bezier-line-segment';
import Point from 'script/geometry/point';
import {
  MoveTo,
  LineTo,
  HorizTo,
  VertiTo,
  CurveTo,
  SmoothTo,

} from 'script/geometry/point';

import lab from 'script/lab/lab';
// Geometry conversions and operations

lab.conversions = {
  pathSegment(a, b) {
    // Returns the LineSegment or BezierCurve that connects two bezier points
    //   (MoveTo, LineTo, CurveTo, SmoothTo)
    //
    // I/P:
    //   a: first point
    //   b: second point
    // O/P: LineSegment or CubiBezier


    if (b == null) { b = a.succ; }
    if (b instanceof LineTo || b instanceof MoveTo || b instanceof HorizTo || b instanceof VertiTo) {
      return new LineSegment(new Posn(a.x, a.y), new Posn(b.x, b.y), b);

    } else if (b instanceof CurveTo) {
      // CurveTo creates a CubicBezier

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b);

    } else if (b instanceof SmoothTo) {
      // SmoothTo creates a CubicBezier also, but it derives its p2 as the
      // reflection of the previous point's p3 reflected over its p4

      return new CubicBezier(
        new Posn(a.x, a.y),
        new Posn(b.x2, b.y2),
        new Posn(b.x3, b.y3),
        new Posn(b.x, b.y), b);
    }
  },


  nextSubstantialPathSegment(point) {
    // Skip any points within 1e-6 of each other
    while (point.within(1e-6, point.succ)) {
      point = point.succ;
    }

    return this.pathSegment(point, point.succ);
  },

  previousSubstantialPathSegment(point) {
    // Skip any points within 1e-6 of each other
    while (point.within(1e-6, point.prec)) {
      point = point.prec;
    }

    return this.pathSegment(point, point.prec);
  },

  stringToAlop(string, owner) {
    // Given a d="M204,123 C9023........." string,
    // return an array of Points.

    let results = [];
    let previous = undefined;

    let all_matches = string.match(CONSTANTS.MATCHERS.POINT);

    for (let point of Array.from(all_matches)) {
      // Point's constructor decides what kind of subclass to make
      // (MoveTo, CurveTo, etc)
      let p = Point.fromString(point, owner, previous);

      if (p instanceof Point) {
        if (previous != null) { p.setPrec(previous); }
        previous = p; // Set it for the next point

        // Don't remember why I did this.
        if ((p instanceof SmoothTo) && (owner instanceof Point)) {
          p.setPrec(owner);
        }

        results.push(p);

      } else if (p instanceof Array) {
        // There's an edge case where you can get an array of a MoveTo followed by LineTos.
        // Terrible function signature design, I know
        // TODO fix this hack garbage
        if (previous != null) {
          p[0].setPrec(previous);
          p.reduce((a, b) => b.setPrec(a));
        }

        results = results.concat(p);
      }
    }

    return results;
  },

  posn: {

    clientToCanvas(p) {
      p = p.clone();
      p.x -= ui.canvas.normal.x;
      p.y -= ui.canvas.normal.y;
      return p;
    },

    canvasToClient(p) {
      p = p.clone();
      p.x += ui.canvas.normal.x;
      p.y += ui.canvas.normal.y;
      return p;
    },

    canvasZoomedToClient(p) {
      p = p.multiplyBy(ui.canvas.zoom);
      return this.canvasToClient(p);
    },

    clientToCanvasZoomed(p) {
      return this.clientToCanvas(p).multiplyBy(1 / ui.canvas.zoom);
    }
  }
};


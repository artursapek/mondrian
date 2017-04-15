import Posn from 'script/geometry/posn';
import Polynomial from 'script/geometry/polynomial';
import CubicBezier from 'script/geometry/cubic-bezier-line-segment';

export default {

  overlap(a, b) {
    if (a.lineSegments && b.lineSegments) {
      return this.lineSegmentsIntersect(a, b);
    } else {
      console.log('Incompatible overlap call', a, b);
      console.trace();
    }
  },

  lineSegmentsIntersect(sa, sb) {
    // Returns bool, whether or not this shape and that shape intersect or overlap
    // Short-circuits as soon as it finds true.
    //
    // I/P: Another shape that has lineSegments()
    // O/P: Boolean

    let alns = sa.lineSegments(); // My lineSegments
    let blns = sb.lineSegments(); // Other's lineSegments

    for (let aline of Array.from(alns)) {

      // The true parameter on bounds() tells aline to use its cached bounds.
      // It saves a lot of time and is okay to do in a situation like this where we're just going
      // through a for-loop and not changing the lines at all.
      //
      // Admittedly, it really only saves time below when it calls it for bline since
      // each aline is only being looked at once, but why not cache as much as possible? :)

      var abounds;
      if (aline instanceof CubicBezier) {
        abounds = aline.bounds(true);
      }

      let a = aline instanceof LineSegment ? aline.a : aline.p1;
      let b = aline instanceof LineSegment ? aline.b : aline.p2;

      if (sb.contains) {
        if (sb.contains(a) || sb.contains(b)) {
          return true;
        }
      }

      for (let bline of Array.from(blns)) {

        var continueChecking;
        if (aline instanceof CubicBezier && bline instanceof CubicBezier) {
          let bbounds = bline.bounds(true);
          console.log(abounds, bbounds);
          continueChecking = abounds.overlapsBounds(bbounds);
        } else {
          continueChecking = true;
        }

        if (continueChecking) {
          if (this.intersect(aline, bline)) {
            return true;
          }
        }
      }
    }
    return false;
  },

  intersect(ashape, bshape) {
    let ints = this.intersections(ashape, bshape);
    return (ints instanceof Array && ints.length > 0);
  },

  intersections(ashape, bshape) {
    let line;
    let subject;
    if (ashape instanceof LineSegment || ashape instanceof CubicBezier) {
      line = ashape;
      subject = bshape;
    } else if (bshape instanceof LineSegment || bshape instanceof CubicBezier) {
      line = bshape;
      subject = ashape;
    }

    if (line instanceof LineSegment) {
      if (subject instanceof LineSegment) {
        return this.lineSegmentIntersectionsWithLineSegment(line, subject);
      } else if (subject instanceof CubicBezier) {
        return this.lineSegmentIntersectionsWithCubicBezier(line, subject);
      } else if (subject instanceof Circle) {
        return this.lineSegmentIntersectionsWithCircle(line, subject);
      } else if (subject instanceof Ellipse) {
        return this.lineSegmentIntersectionsWithEllipse(line, subject);
      } else {
        throw new Error('Invalid intersections call');
      }
    } else if (line instanceof CubicBezier) {
      if (subject instanceof LineSegment) {
        return this.lineSegmentIntersectionsWithCubicBezier(subject, line); // Reverse args here
      } else if (subject instanceof CubicBezier) {
        return this.cubicBezierIntersectionsWithCubicBezier(line, subject);
      } else {
        throw new Error('Invalid intersections call');
      }
    }
  },

  lineSegmentIntersectionsWithLineSegment(aline, bline) {
    /*
      Get intersection with another LineSegment

      I/P : LineSegment

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */

    let ana_s = (bline.xbaDiff() * (aline.a.y - bline.a.y)) - (bline.ybaDiff() * (aline.a.x - bline.a.x));
    let ana_m = (aline.xbaDiff() * (aline.a.y - bline.a.y)) - (aline.ybaDiff() * (aline.a.x - bline.a.x));
    let crossDiff  = (bline.ybaDiff() * aline.xbaDiff()) - (bline.xbaDiff() * aline.ybaDiff());

    if (crossDiff !== 0) {
      let anas = ana_s / crossDiff;
      let anam = ana_m / crossDiff;

      if ((0 <= anas) && (anas <= 1) && (0 <= anam) && (anam <= 1)) {
        return new Posn(aline.a.x + (anas * (aline.b.x - aline.a.x)), aline.a.y + (anas * (aline.b.y - aline.a.y)));
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
  },

  lineSegmentIntersectionsWithEllipse(aline, bz) {

    /*
     Get intersection with an ellipse

     I/P: Ellipse

     O/P: null if no intersections, or Array of Posn(s) if there are

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */


    let { rx, ry, cx, cy } = bz.data;

    let origin = new Posn(aline.a.x, aline.a.y);
    let dir    = new Posn(aline.b.x - aline.a.x, aline.b.y - aline.a.y);
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
          results.push(aline.a.lerp(aline.b, t_a));
        }
        if ((0 <= t_b) && (t_b <= 1)) {
          results.push(aline.a.lerp(aline.b, t_b));
        }
      }
    } else {
        let t = -b / a;
        if ((0 <= t) && (t <= 1)) {
          results.push(aline.a.lerp(aline.b, t));
        } else {
          return null;
        }
      }

    return results;
  },

  lineSegmentIntersectionsWithCircle(aline, circle) {
    /*
      Get intersection with a circle

      I/P : Circle

      O/P : If intersection exists, [x, y] coords of intersection
            If none exists, null
            If they're parallel, 0
            If they're coincident, Infinity

      Source: http://www.kevlindev.com/gui/math/intersection/Intersection.js
    */

    let a = Math.pow(aline.xDiff(), 2) + Math.pow(aline.yDiff(), 2);
    let b = 2 * (((aline.b.x - aline.a.x) * (aline.a.x - circle.data.cx)) + ((aline.b.y - aline.a.y) * (aline.a.y - circle.data.cy)));
    let cc = (Math.pow(circle.data.cx, 2) + Math.pow(circle.data.cy, 2) + Math.pow(aline.a.x, 2) + Math.pow(aline.a.y, 2)) -
         (2 * ((circle.data.cx * aline.a.x) + (circle.data.cy * aline.a.y))) - Math.pow(circle.data.r, 2);
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
          ints.push(aline.a.lerp(aline.b, u1));
        }

        if ((0 <= u2) && (u2 <= 1)) {
          ints.push(aline.a.lerp(aline.b, u2));
        }

        return ints;
      }
    }
  },

  lineSegmentIntersectionsWithCubicBezier(aline, bz) {
    /*

      Given a LineSegment, lists intersection point(s).

      I/P: LineSegment
      O/P: Array of Posns

      I am a cute sick Kate Whiper Snapper
      i love monodebe and I learn all about the flexible scemless data base

      Disclaimer: I don't really understand this but it passes my tests.

    */

    let min = aline.a.min(aline.b);
    let max = aline.a.max(aline.b);

    let results = [];

    let a = bz.p1.multiplyBy(-1);
    let b = bz.p2.multiplyBy(3);
    let c = bz.p3.multiplyBy(-3);
    let d = a.add(b.add(c.add(bz.p4)));
    let c3 = new Posn(d.x, d.y);

    a = bz.p1.multiplyBy(3);
    b = bz.p2.multiplyBy(-6);
    c = bz.p3.multiplyBy(3);
    d = a.add(b.add(c));
    let c2 = new Posn(d.x, d.y);

    a = bz.p1.multiplyBy(-3);
    b = bz.p2.multiplyBy(3);
    c = a.add(b);
    let c1 = new Posn(c.x, c.y);

    let c0 = new Posn(bz.p1.x, bz.p1.y);

    let n = new Posn(aline.a.y - aline.b.y, aline.b.x - aline.a.x);

    let cl = (aline.a.x * aline.b.y) - (aline.b.x * aline.a.y);

    let roots = new Polynomial([n.dot(c3), n.dot(c2), n.dot(c1), n.dot(c0) + cl]).roots();

    for (let i in roots) {

      let t = roots[i];
      if ((0 <= t) && (t <= 1)) {

        let p5 = bz.p1.lerp(bz.p2, t);
        let p6 = bz.p2.lerp(bz.p3, t);
        let p7 = bz.p3.lerp(bz.p4, t);
        let p8 = p5.lerp(p6, t);
        let p9 = p6.lerp(p7, t);
        let p10 = p8.lerp(p9, t);

        if (aline.a.x === aline.b.x) {
          if ((min.y <= p10.y) && (p10.y <= max.y)) {
            results.push(p10);
          }
        } else if (aline.a.y === aline.b.y) {
          if ((min.x <= p10.x) && (p10.x <= max.x)) {
            results.push(p10);
          }
        } else if (p10.gte(min) && p10.lte(max)) {
          results.push(p10);
        }
      }
    }

    return results;
  },

  cubicBezierIntersectionsWithCubicBezier(bz1, bz2) {
    // I don't know.
    //
    // I/P: Another CubicBezier
    // O/P: Array of Posns.
    //
    // Source: http://www.kevlindev.com/gui/math/intersection/index.htm#Anchor-intersectBezie-45477

    let results = [];

    let a = bz1.p1.multiplyBy(-1);
    let b = bz1.p2.multiplyBy(3);
    let c = bz1.p3.multiplyBy(-3);
    let d = a.add(b.add(c.add(bz1.p4)));
    let c13 = new Posn(d.x, d.y);

    a = bz1.p1.multiplyBy(3);
    b = bz1.p2.multiplyBy(-6);
    c = bz1.p3.multiplyBy(3);
    d = a.add(b.add(c));
    let c12 = new Posn(d.x, d.y);

    a = bz1.p1.multiplyBy(-3);
    b = bz1.p2.multiplyBy(3);
    c = a.add(b);
    let c11 = new Posn(c.x, c.y);

    let c10 = new Posn(bz1.p1.x, bz1.p1.y);

    a = bz2.p1.multiplyBy(-1);
    b = bz2.p2.multiplyBy(3);
    c = bz2.p3.multiplyBy(-3);
    d = a.add(b.add(c.add(bz2.p4)));
    let c23 = new Posn(d.x, d.y);

    a = bz2.p1.multiplyBy(3);
    b = bz2.p2.multiplyBy(-6);
    c = bz2.p3.multiplyBy(3);
    d = a.add(b.add(c));
    let c22 = new Posn(d.x, d.y);

    a = bz2.p1.multiplyBy(-3);
    b = bz2.p2.multiplyBy(3);
    c = a.add(b);
    let c21 = new Posn(c.x, c.y);

    let c20 = new Posn(bz2.p1.x, bz2.p1.y);

    let c10x2 = c10.x * c10.x;
    let c10x3 = c10.x * c10.x * c10.x;
    let c10y2 = c10.y * c10.y;
    let c10y3 = c10.y * c10.y * c10.y;
    let c11x2 = c11.x * c11.x;
    let c11x3 = c11.x * c11.x * c11.x;
    let c11y2 = c11.y * c11.y;
    let c11y3 = c11.y * c11.y * c11.y;
    let c12x2 = c12.x * c12.x;
    let c12x3 = c12.x * c12.x * c12.x;
    let c12y2 = c12.y * c12.y;
    let c12y3 = c12.y * c12.y * c12.y;
    let c13x2 = c13.x * c13.x;
    let c13x3 = c13.x * c13.x * c13.x;
    let c13y2 = c13.y * c13.y;
    let c13y3 = c13.y * c13.y * c13.y;
    let c20x2 = c20.x * c20.x;
    let c20x3 = c20.x * c20.x * c20.x;
    let c20y2 = c20.y * c20.y;
    let c20y3 = c20.y * c20.y * c20.y;
    let c21x2 = c21.x * c21.x;
    let c21x3 = c21.x * c21.x * c21.x;
    let c21y2 = c21.y * c21.y;
    let c22x2 = c22.x * c22.x;
    let c22x3 = c22.x * c22.x * c22.x;
    let c22y2 = c22.y * c22.y;
    let c23x2 = c23.x * c23.x;
    let c23x3 = c23.x * c23.x * c23.x;
    let c23y2 = c23.y * c23.y;
    let c23y3 = c23.y * c23.y * c23.y;


    let poly = new Polynomial([
      (((-c13x3*c23y3) + (c13y3*c23x3)) - (3*c13.x*c13y2*c23x2*c23.y)) +
      (3*c13x2*c13.y*c23.x*c23y2),

      (((-6*c13.x*c22.x*c13y2*c23.x*c23.y) + (6*c13x2*c13.y*c22.y*c23.x*c23.y) + (3*c22.x*c13y3*c23x2)) -
      (3*c13x3*c22.y*c23y2) - (3*c13.x*c13y2*c22.y*c23x2)) + (3*c13x2*c22.x*c13.y*c23y2),
      ((((-6*c21.x*c13.x*c13y2*c23.x*c23.y) - (6*c13.x*c22.x*c13y2*c22.y*c23.x)) + (6*c13x2*c22.x*c13.y*c22.y*c23.y) +
      (3*c21.x*c13y3*c23x2) + (3*c22x2*c13y3*c23.x) + (3*c21.x*c13x2*c13.y*c23y2)) - (3*c13.x*c21.y*c13y2*c23x2) -
      (3*c13.x*c22x2*c13y2*c23.y)) + (c13x2*c13.y*c23.x*((6*c21.y*c23.y) + (3*c22y2))) + (c13x3*((-c21.y*c23y2) -
      (2*c22y2*c23.y) - (c23.y*((2*c21.y*c23.y) + c22y2)))),

      ((((((((((((((((((c11.x*c12.y*c13.x*c13.y*c23.x*c23.y) - (c11.y*c12.x*c13.x*c13.y*c23.x*c23.y)) + (6*c21.x*c22.x*c13y3*c23.x) +
      (3*c11.x*c12.x*c13.x*c13.y*c23y2) + (6*c10.x*c13.x*c13y2*c23.x*c23.y)) - (3*c11.x*c12.x*c13y2*c23.x*c23.y) -
      (3*c11.y*c12.y*c13.x*c13.y*c23x2) - (6*c10.y*c13x2*c13.y*c23.x*c23.y) - (6*c20.x*c13.x*c13y2*c23.x*c23.y)) +
      (3*c11.y*c12.y*c13x2*c23.x*c23.y)) - (2*c12.x*c12y2*c13.x*c23.x*c23.y) - (6*c21.x*c13.x*c22.x*c13y2*c23.y) -
      (6*c21.x*c13.x*c13y2*c22.y*c23.x) - (6*c13.x*c21.y*c22.x*c13y2*c23.x)) + (6*c21.x*c13x2*c13.y*c22.y*c23.y) +
      (2*c12x2*c12.y*c13.y*c23.x*c23.y) + (c22x3*c13y3)) - (3*c10.x*c13y3*c23x2)) + (3*c10.y*c13x3*c23y2) +
      (3*c20.x*c13y3*c23x2) + (c12y3*c13.x*c23x2)) - (c12x3*c13.y*c23y2) - (3*c10.x*c13x2*c13.y*c23y2)) +
      (3*c10.y*c13.x*c13y2*c23x2)) - (2*c11.x*c12.y*c13x2*c23y2)) + (c11.x*c12.y*c13y2*c23x2)) - (c11.y*c12.x*c13x2*c23y2)) +
      (2*c11.y*c12.x*c13y2*c23x2) + (3*c20.x*c13x2*c13.y*c23y2)) - (c12.x*c12y2*c13.y*c23x2) -
      (3*c20.y*c13.x*c13y2*c23x2)) + (c12x2*c12.y*c13.x*c23y2)) - (3*c13.x*c22x2*c13y2*c22.y)) +
      (c13x2*c13.y*c23.x*((6*c20.y*c23.y) + (6*c21.y*c22.y))) + (c13x2*c22.x*c13.y*((6*c21.y*c23.y) + (3*c22y2))) +
      (c13x3*((-2*c21.y*c22.y*c23.y) - (c20.y*c23y2) - (c22.y*((2*c21.y*c23.y) + c22y2)) - (c23.y*((2*c20.y*c23.y) + (2*c21.y*c22.y))))),

      (((((((((((((6*c11.x*c12.x*c13.x*c13.y*c22.y*c23.y) + (c11.x*c12.y*c13.x*c22.x*c13.y*c23.y) + (c11.x*c12.y*c13.x*c13.y*c22.y*c23.x)) -
      (c11.y*c12.x*c13.x*c22.x*c13.y*c23.y) - (c11.y*c12.x*c13.x*c13.y*c22.y*c23.x) - (6*c11.y*c12.y*c13.x*c22.x*c13.y*c23.x) -
      (6*c10.x*c22.x*c13y3*c23.x)) + (6*c20.x*c22.x*c13y3*c23.x) + (6*c10.y*c13x3*c22.y*c23.y) + (2*c12y3*c13.x*c22.x*c23.x)) -
      (2*c12x3*c13.y*c22.y*c23.y)) + (6*c10.x*c13.x*c22.x*c13y2*c23.y) + (6*c10.x*c13.x*c13y2*c22.y*c23.x) +
      (6*c10.y*c13.x*c22.x*c13y2*c23.x)) - (3*c11.x*c12.x*c22.x*c13y2*c23.y) - (3*c11.x*c12.x*c13y2*c22.y*c23.x)) +
      (2*c11.x*c12.y*c22.x*c13y2*c23.x) + (4*c11.y*c12.x*c22.x*c13y2*c23.x)) - (6*c10.x*c13x2*c13.y*c22.y*c23.y) -
      (6*c10.y*c13x2*c22.x*c13.y*c23.y) - (6*c10.y*c13x2*c13.y*c22.y*c23.x) - (4*c11.x*c12.y*c13x2*c22.y*c23.y) -
      (6*c20.x*c13.x*c22.x*c13y2*c23.y) - (6*c20.x*c13.x*c13y2*c22.y*c23.x) - (2*c11.y*c12.x*c13x2*c22.y*c23.y)) +
      (3*c11.y*c12.y*c13x2*c22.x*c23.y) + (3*c11.y*c12.y*c13x2*c22.y*c23.x)) - (2*c12.x*c12y2*c13.x*c22.x*c23.y) -
      (2*c12.x*c12y2*c13.x*c22.y*c23.x) - (2*c12.x*c12y2*c22.x*c13.y*c23.x) - (6*c20.y*c13.x*c22.x*c13y2*c23.x) -
      (6*c21.x*c13.x*c21.y*c13y2*c23.x) - (6*c21.x*c13.x*c22.x*c13y2*c22.y)) + (6*c20.x*c13x2*c13.y*c22.y*c23.y) +
      (2*c12x2*c12.y*c13.x*c22.y*c23.y) + (2*c12x2*c12.y*c22.x*c13.y*c23.y) + (2*c12x2*c12.y*c13.y*c22.y*c23.x) +
      (3*c21.x*c22x2*c13y3) + (3*c21x2*c13y3*c23.x)) - (3*c13.x*c21.y*c22x2*c13y2) - (3*c21x2*c13.x*c13y2*c23.y)) +
      (c13x2*c22.x*c13.y*((6*c20.y*c23.y) + (6*c21.y*c22.y))) + (c13x2*c13.y*c23.x*((6*c20.y*c22.y) + (3*c21y2))) +
      (c21.x*c13x2*c13.y*((6*c21.y*c23.y) + (3*c22y2))) + (c13x3*((-2*c20.y*c22.y*c23.y) - (c23.y*((2*c20.y*c22.y) + c21y2)) -
      (c21.y*((2*c21.y*c23.y) + c22y2)) - (c22.y*((2*c20.y*c23.y) + (2*c21.y*c22.y))))),

      (((((((((((((((c11.x*c21.x*c12.y*c13.x*c13.y*c23.y) + (c11.x*c12.y*c13.x*c21.y*c13.y*c23.x) + (c11.x*c12.y*c13.x*c22.x*c13.y*c22.y)) -
      (c11.y*c12.x*c21.x*c13.x*c13.y*c23.y) - (c11.y*c12.x*c13.x*c21.y*c13.y*c23.x) - (c11.y*c12.x*c13.x*c22.x*c13.y*c22.y) -
      (6*c11.y*c21.x*c12.y*c13.x*c13.y*c23.x) - (6*c10.x*c21.x*c13y3*c23.x)) + (6*c20.x*c21.x*c13y3*c23.x) +
      (2*c21.x*c12y3*c13.x*c23.x) + (6*c10.x*c21.x*c13.x*c13y2*c23.y) + (6*c10.x*c13.x*c21.y*c13y2*c23.x) +
      (6*c10.x*c13.x*c22.x*c13y2*c22.y) + (6*c10.y*c21.x*c13.x*c13y2*c23.x)) - (3*c11.x*c12.x*c21.x*c13y2*c23.y) -
      (3*c11.x*c12.x*c21.y*c13y2*c23.x) - (3*c11.x*c12.x*c22.x*c13y2*c22.y)) + (2*c11.x*c21.x*c12.y*c13y2*c23.x) +
      (4*c11.y*c12.x*c21.x*c13y2*c23.x)) - (6*c10.y*c21.x*c13x2*c13.y*c23.y) - (6*c10.y*c13x2*c21.y*c13.y*c23.x) -
      (6*c10.y*c13x2*c22.x*c13.y*c22.y) - (6*c20.x*c21.x*c13.x*c13y2*c23.y) - (6*c20.x*c13.x*c21.y*c13y2*c23.x) -
      (6*c20.x*c13.x*c22.x*c13y2*c22.y)) + (3*c11.y*c21.x*c12.y*c13x2*c23.y)) - (3*c11.y*c12.y*c13.x*c22x2*c13.y)) +
      (3*c11.y*c12.y*c13x2*c21.y*c23.x) + (3*c11.y*c12.y*c13x2*c22.x*c22.y)) - (2*c12.x*c21.x*c12y2*c13.x*c23.y) -
      (2*c12.x*c21.x*c12y2*c13.y*c23.x) - (2*c12.x*c12y2*c13.x*c21.y*c23.x) - (2*c12.x*c12y2*c13.x*c22.x*c22.y) -
      (6*c20.y*c21.x*c13.x*c13y2*c23.x) - (6*c21.x*c13.x*c21.y*c22.x*c13y2)) + (6*c20.y*c13x2*c21.y*c13.y*c23.x) +
      (2*c12x2*c21.x*c12.y*c13.y*c23.y) + (2*c12x2*c12.y*c21.y*c13.y*c23.x) + (2*c12x2*c12.y*c22.x*c13.y*c22.y)) -
      (3*c10.x*c22x2*c13y3)) + (3*c20.x*c22x2*c13y3) + (3*c21x2*c22.x*c13y3) + (c12y3*c13.x*c22x2) +
      (3*c10.y*c13.x*c22x2*c13y2) + (c11.x*c12.y*c22x2*c13y2) + (2*c11.y*c12.x*c22x2*c13y2)) -
      (c12.x*c12y2*c22x2*c13.y) - (3*c20.y*c13.x*c22x2*c13y2) - (3*c21x2*c13.x*c13y2*c22.y)) +
      (c12x2*c12.y*c13.x*((2*c21.y*c23.y) + c22y2)) + (c11.x*c12.x*c13.x*c13.y*((6*c21.y*c23.y) + (3*c22y2))) +
      (c21.x*c13x2*c13.y*((6*c20.y*c23.y) + (6*c21.y*c22.y))) + (c12x3*c13.y*((-2*c21.y*c23.y) - c22y2)) +
      (c10.y*c13x3*((6*c21.y*c23.y) + (3*c22y2))) + (c11.y*c12.x*c13x2*((-2*c21.y*c23.y) - c22y2)) +
      (c11.x*c12.y*c13x2*((-4*c21.y*c23.y) - (2*c22y2))) + (c10.x*c13x2*c13.y*((-6*c21.y*c23.y) - (3*c22y2))) +
      (c13x2*c22.x*c13.y*((6*c20.y*c22.y) + (3*c21y2))) + (c20.x*c13x2*c13.y*((6*c21.y*c23.y) + (3*c22y2))) +
      (c13x3*((-2*c20.y*c21.y*c23.y) - (c22.y*((2*c20.y*c22.y) + c21y2)) - (c20.y*((2*c21.y*c23.y) + c22y2)) -
      (c21.y*((2*c20.y*c23.y) + (2*c21.y*c22.y))))),

      (((((((((((((((((((((((((((((((((((-c10.x*c11.x*c12.y*c13.x*c13.y*c23.y) + (c10.x*c11.y*c12.x*c13.x*c13.y*c23.y) + (6*c10.x*c11.y*c12.y*c13.x*c13.y*c23.x)) -
      (6*c10.y*c11.x*c12.x*c13.x*c13.y*c23.y) - (c10.y*c11.x*c12.y*c13.x*c13.y*c23.x)) + (c10.y*c11.y*c12.x*c13.x*c13.y*c23.x) +
      (c11.x*c11.y*c12.x*c12.y*c13.x*c23.y)) - (c11.x*c11.y*c12.x*c12.y*c13.y*c23.x)) + (c11.x*c20.x*c12.y*c13.x*c13.y*c23.y) +
      (c11.x*c20.y*c12.y*c13.x*c13.y*c23.x) + (c11.x*c21.x*c12.y*c13.x*c13.y*c22.y) + (c11.x*c12.y*c13.x*c21.y*c22.x*c13.y)) -
      (c20.x*c11.y*c12.x*c13.x*c13.y*c23.y) - (6*c20.x*c11.y*c12.y*c13.x*c13.y*c23.x) - (c11.y*c12.x*c20.y*c13.x*c13.y*c23.x) -
      (c11.y*c12.x*c21.x*c13.x*c13.y*c22.y) - (c11.y*c12.x*c13.x*c21.y*c22.x*c13.y) - (6*c11.y*c21.x*c12.y*c13.x*c22.x*c13.y) -
      (6*c10.x*c20.x*c13y3*c23.x) - (6*c10.x*c21.x*c22.x*c13y3) - (2*c10.x*c12y3*c13.x*c23.x)) + (6*c20.x*c21.x*c22.x*c13y3) +
      (2*c20.x*c12y3*c13.x*c23.x) + (2*c21.x*c12y3*c13.x*c22.x) + (2*c10.y*c12x3*c13.y*c23.y)) - (6*c10.x*c10.y*c13.x*c13y2*c23.x)) +
      (3*c10.x*c11.x*c12.x*c13y2*c23.y)) - (2*c10.x*c11.x*c12.y*c13y2*c23.x) - (4*c10.x*c11.y*c12.x*c13y2*c23.x)) +
      (3*c10.y*c11.x*c12.x*c13y2*c23.x) + (6*c10.x*c10.y*c13x2*c13.y*c23.y) + (6*c10.x*c20.x*c13.x*c13y2*c23.y)) -
      (3*c10.x*c11.y*c12.y*c13x2*c23.y)) + (2*c10.x*c12.x*c12y2*c13.x*c23.y) + (2*c10.x*c12.x*c12y2*c13.y*c23.x) +
      (6*c10.x*c20.y*c13.x*c13y2*c23.x) + (6*c10.x*c21.x*c13.x*c13y2*c22.y) + (6*c10.x*c13.x*c21.y*c22.x*c13y2) +
      (4*c10.y*c11.x*c12.y*c13x2*c23.y) + (6*c10.y*c20.x*c13.x*c13y2*c23.x) + (2*c10.y*c11.y*c12.x*c13x2*c23.y)) -
      (3*c10.y*c11.y*c12.y*c13x2*c23.x)) + (2*c10.y*c12.x*c12y2*c13.x*c23.x) + (6*c10.y*c21.x*c13.x*c22.x*c13y2)) -
      (3*c11.x*c20.x*c12.x*c13y2*c23.y)) + (2*c11.x*c20.x*c12.y*c13y2*c23.x) + (c11.x*c11.y*c12y2*c13.x*c23.x)) -
      (3*c11.x*c12.x*c20.y*c13y2*c23.x) - (3*c11.x*c12.x*c21.x*c13y2*c22.y) - (3*c11.x*c12.x*c21.y*c22.x*c13y2)) +
      (2*c11.x*c21.x*c12.y*c22.x*c13y2) + (4*c20.x*c11.y*c12.x*c13y2*c23.x) + (4*c11.y*c12.x*c21.x*c22.x*c13y2)) -
      (2*c10.x*c12x2*c12.y*c13.y*c23.y) - (6*c10.y*c20.x*c13x2*c13.y*c23.y) - (6*c10.y*c20.y*c13x2*c13.y*c23.x) -
      (6*c10.y*c21.x*c13x2*c13.y*c22.y) - (2*c10.y*c12x2*c12.y*c13.x*c23.y) - (2*c10.y*c12x2*c12.y*c13.y*c23.x) -
      (6*c10.y*c13x2*c21.y*c22.x*c13.y) - (c11.x*c11.y*c12x2*c13.y*c23.y) - (2*c11.x*c11y2*c13.x*c13.y*c23.x)) +
      (3*c20.x*c11.y*c12.y*c13x2*c23.y)) - (2*c20.x*c12.x*c12y2*c13.x*c23.y) - (2*c20.x*c12.x*c12y2*c13.y*c23.x) -
      (6*c20.x*c20.y*c13.x*c13y2*c23.x) - (6*c20.x*c21.x*c13.x*c13y2*c22.y) - (6*c20.x*c13.x*c21.y*c22.x*c13y2)) +
      (3*c11.y*c20.y*c12.y*c13x2*c23.x) + (3*c11.y*c21.x*c12.y*c13x2*c22.y) + (3*c11.y*c12.y*c13x2*c21.y*c22.x)) -
      (2*c12.x*c20.y*c12y2*c13.x*c23.x) - (2*c12.x*c21.x*c12y2*c13.x*c22.y) - (2*c12.x*c21.x*c12y2*c22.x*c13.y) -
      (2*c12.x*c12y2*c13.x*c21.y*c22.x) - (6*c20.y*c21.x*c13.x*c22.x*c13y2) - (c11y2*c12.x*c12.y*c13.x*c23.x)) +
      (2*c20.x*c12x2*c12.y*c13.y*c23.y) + (6*c20.y*c13x2*c21.y*c22.x*c13.y) + (2*c11x2*c11.y*c13.x*c13.y*c23.y) +
      (c11x2*c12.x*c12.y*c13.y*c23.y) + (2*c12x2*c20.y*c12.y*c13.y*c23.x) + (2*c12x2*c21.x*c12.y*c13.y*c22.y) +
      (2*c12x2*c12.y*c21.y*c22.x*c13.y) + (c21x3*c13y3) + (3*c10x2*c13y3*c23.x)) - (3*c10y2*c13x3*c23.y)) +
      (3*c20x2*c13y3*c23.x) + (c11y3*c13x2*c23.x)) - (c11x3*c13y2*c23.y) - (c11.x*c11y2*c13x2*c23.y)) +
      (c11x2*c11.y*c13y2*c23.x)) - (3*c10x2*c13.x*c13y2*c23.y)) + (3*c10y2*c13x2*c13.y*c23.x)) - (c11x2*c12y2*c13.x*c23.y)) +
      (c11y2*c12x2*c13.y*c23.x)) - (3*c21x2*c13.x*c21.y*c13y2) - (3*c20x2*c13.x*c13y2*c23.y)) + (3*c20y2*c13x2*c13.y*c23.x) +
      (c11.x*c12.x*c13.x*c13.y*((6*c20.y*c23.y) + (6*c21.y*c22.y))) + (c12x3*c13.y*((-2*c20.y*c23.y) - (2*c21.y*c22.y))) +
      (c10.y*c13x3*((6*c20.y*c23.y) + (6*c21.y*c22.y))) + (c11.y*c12.x*c13x2*((-2*c20.y*c23.y) - (2*c21.y*c22.y))) +
      (c12x2*c12.y*c13.x*((2*c20.y*c23.y) + (2*c21.y*c22.y))) + (c11.x*c12.y*c13x2*((-4*c20.y*c23.y) - (4*c21.y*c22.y))) +
      (c10.x*c13x2*c13.y*((-6*c20.y*c23.y) - (6*c21.y*c22.y))) + (c20.x*c13x2*c13.y*((6*c20.y*c23.y) + (6*c21.y*c22.y))) +
      (c21.x*c13x2*c13.y*((6*c20.y*c22.y) + (3*c21y2))) + (c13x3*((-2*c20.y*c21.y*c22.y) - (c20y2*c23.y) -
      (c21.y*((2*c20.y*c22.y) + c21y2)) - (c20.y*((2*c20.y*c23.y) + (2*c21.y*c22.y))))),

      (((((((((((((((((((((((((((((((((((((((((-c10.x*c11.x*c12.y*c13.x*c13.y*c22.y) + (c10.x*c11.y*c12.x*c13.x*c13.y*c22.y) + (6*c10.x*c11.y*c12.y*c13.x*c22.x*c13.y)) -
      (6*c10.y*c11.x*c12.x*c13.x*c13.y*c22.y) - (c10.y*c11.x*c12.y*c13.x*c22.x*c13.y)) + (c10.y*c11.y*c12.x*c13.x*c22.x*c13.y) +
      (c11.x*c11.y*c12.x*c12.y*c13.x*c22.y)) - (c11.x*c11.y*c12.x*c12.y*c22.x*c13.y)) + (c11.x*c20.x*c12.y*c13.x*c13.y*c22.y) +
      (c11.x*c20.y*c12.y*c13.x*c22.x*c13.y) + (c11.x*c21.x*c12.y*c13.x*c21.y*c13.y)) - (c20.x*c11.y*c12.x*c13.x*c13.y*c22.y) -
      (6*c20.x*c11.y*c12.y*c13.x*c22.x*c13.y) - (c11.y*c12.x*c20.y*c13.x*c22.x*c13.y) - (c11.y*c12.x*c21.x*c13.x*c21.y*c13.y) -
      (6*c10.x*c20.x*c22.x*c13y3) - (2*c10.x*c12y3*c13.x*c22.x)) + (2*c20.x*c12y3*c13.x*c22.x) + (2*c10.y*c12x3*c13.y*c22.y)) -
      (6*c10.x*c10.y*c13.x*c22.x*c13y2)) + (3*c10.x*c11.x*c12.x*c13y2*c22.y)) - (2*c10.x*c11.x*c12.y*c22.x*c13y2) -
      (4*c10.x*c11.y*c12.x*c22.x*c13y2)) + (3*c10.y*c11.x*c12.x*c22.x*c13y2) + (6*c10.x*c10.y*c13x2*c13.y*c22.y) +
      (6*c10.x*c20.x*c13.x*c13y2*c22.y)) - (3*c10.x*c11.y*c12.y*c13x2*c22.y)) + (2*c10.x*c12.x*c12y2*c13.x*c22.y) +
      (2*c10.x*c12.x*c12y2*c22.x*c13.y) + (6*c10.x*c20.y*c13.x*c22.x*c13y2) + (6*c10.x*c21.x*c13.x*c21.y*c13y2) +
      (4*c10.y*c11.x*c12.y*c13x2*c22.y) + (6*c10.y*c20.x*c13.x*c22.x*c13y2) + (2*c10.y*c11.y*c12.x*c13x2*c22.y)) -
      (3*c10.y*c11.y*c12.y*c13x2*c22.x)) + (2*c10.y*c12.x*c12y2*c13.x*c22.x)) - (3*c11.x*c20.x*c12.x*c13y2*c22.y)) +
      (2*c11.x*c20.x*c12.y*c22.x*c13y2) + (c11.x*c11.y*c12y2*c13.x*c22.x)) - (3*c11.x*c12.x*c20.y*c22.x*c13y2) -
      (3*c11.x*c12.x*c21.x*c21.y*c13y2)) + (4*c20.x*c11.y*c12.x*c22.x*c13y2)) - (2*c10.x*c12x2*c12.y*c13.y*c22.y) -
      (6*c10.y*c20.x*c13x2*c13.y*c22.y) - (6*c10.y*c20.y*c13x2*c22.x*c13.y) - (6*c10.y*c21.x*c13x2*c21.y*c13.y) -
      (2*c10.y*c12x2*c12.y*c13.x*c22.y) - (2*c10.y*c12x2*c12.y*c22.x*c13.y) - (c11.x*c11.y*c12x2*c13.y*c22.y) -
      (2*c11.x*c11y2*c13.x*c22.x*c13.y)) + (3*c20.x*c11.y*c12.y*c13x2*c22.y)) - (2*c20.x*c12.x*c12y2*c13.x*c22.y) -
      (2*c20.x*c12.x*c12y2*c22.x*c13.y) - (6*c20.x*c20.y*c13.x*c22.x*c13y2) - (6*c20.x*c21.x*c13.x*c21.y*c13y2)) +
      (3*c11.y*c20.y*c12.y*c13x2*c22.x) + (3*c11.y*c21.x*c12.y*c13x2*c21.y)) - (2*c12.x*c20.y*c12y2*c13.x*c22.x) -
      (2*c12.x*c21.x*c12y2*c13.x*c21.y) - (c11y2*c12.x*c12.y*c13.x*c22.x)) + (2*c20.x*c12x2*c12.y*c13.y*c22.y)) -
      (3*c11.y*c21x2*c12.y*c13.x*c13.y)) + (6*c20.y*c21.x*c13x2*c21.y*c13.y) + (2*c11x2*c11.y*c13.x*c13.y*c22.y) +
      (c11x2*c12.x*c12.y*c13.y*c22.y) + (2*c12x2*c20.y*c12.y*c22.x*c13.y) + (2*c12x2*c21.x*c12.y*c21.y*c13.y)) -
      (3*c10.x*c21x2*c13y3)) + (3*c20.x*c21x2*c13y3) + (3*c10x2*c22.x*c13y3)) - (3*c10y2*c13x3*c22.y)) + (3*c20x2*c22.x*c13y3) +
      (c21x2*c12y3*c13.x) + (c11y3*c13x2*c22.x)) - (c11x3*c13y2*c22.y)) + (3*c10.y*c21x2*c13.x*c13y2)) -
      (c11.x*c11y2*c13x2*c22.y)) + (c11.x*c21x2*c12.y*c13y2) + (2*c11.y*c12.x*c21x2*c13y2) + (c11x2*c11.y*c22.x*c13y2)) -
      (c12.x*c21x2*c12y2*c13.y) - (3*c20.y*c21x2*c13.x*c13y2) - (3*c10x2*c13.x*c13y2*c22.y)) + (3*c10y2*c13x2*c22.x*c13.y)) -
      (c11x2*c12y2*c13.x*c22.y)) + (c11y2*c12x2*c22.x*c13.y)) - (3*c20x2*c13.x*c13y2*c22.y)) + (3*c20y2*c13x2*c22.x*c13.y) +
      (c12x2*c12.y*c13.x*((2*c20.y*c22.y) + c21y2)) + (c11.x*c12.x*c13.x*c13.y*((6*c20.y*c22.y) + (3*c21y2))) +
      (c12x3*c13.y*((-2*c20.y*c22.y) - c21y2)) + (c10.y*c13x3*((6*c20.y*c22.y) + (3*c21y2))) +
      (c11.y*c12.x*c13x2*((-2*c20.y*c22.y) - c21y2)) + (c11.x*c12.y*c13x2*((-4*c20.y*c22.y) - (2*c21y2))) +
      (c10.x*c13x2*c13.y*((-6*c20.y*c22.y) - (3*c21y2))) + (c20.x*c13x2*c13.y*((6*c20.y*c22.y) + (3*c21y2))) +
      (c13x3*((-2*c20.y*c21y2) - (c20y2*c22.y) - (c20.y*((2*c20.y*c22.y) + c21y2)))),

      (((((((((((((((((((((((((((((((((((-c10.x*c11.x*c12.y*c13.x*c21.y*c13.y) + (c10.x*c11.y*c12.x*c13.x*c21.y*c13.y) + (6*c10.x*c11.y*c21.x*c12.y*c13.x*c13.y)) -
      (6*c10.y*c11.x*c12.x*c13.x*c21.y*c13.y) - (c10.y*c11.x*c21.x*c12.y*c13.x*c13.y)) + (c10.y*c11.y*c12.x*c21.x*c13.x*c13.y)) -
      (c11.x*c11.y*c12.x*c21.x*c12.y*c13.y)) + (c11.x*c11.y*c12.x*c12.y*c13.x*c21.y) + (c11.x*c20.x*c12.y*c13.x*c21.y*c13.y) +
      (6*c11.x*c12.x*c20.y*c13.x*c21.y*c13.y) + (c11.x*c20.y*c21.x*c12.y*c13.x*c13.y)) - (c20.x*c11.y*c12.x*c13.x*c21.y*c13.y) -
      (6*c20.x*c11.y*c21.x*c12.y*c13.x*c13.y) - (c11.y*c12.x*c20.y*c21.x*c13.x*c13.y) - (6*c10.x*c20.x*c21.x*c13y3) -
      (2*c10.x*c21.x*c12y3*c13.x)) + (6*c10.y*c20.y*c13x3*c21.y) + (2*c20.x*c21.x*c12y3*c13.x) + (2*c10.y*c12x3*c21.y*c13.y)) -
      (2*c12x3*c20.y*c21.y*c13.y) - (6*c10.x*c10.y*c21.x*c13.x*c13y2)) + (3*c10.x*c11.x*c12.x*c21.y*c13y2)) -
      (2*c10.x*c11.x*c21.x*c12.y*c13y2) - (4*c10.x*c11.y*c12.x*c21.x*c13y2)) + (3*c10.y*c11.x*c12.x*c21.x*c13y2) +
      (6*c10.x*c10.y*c13x2*c21.y*c13.y) + (6*c10.x*c20.x*c13.x*c21.y*c13y2)) - (3*c10.x*c11.y*c12.y*c13x2*c21.y)) +
      (2*c10.x*c12.x*c21.x*c12y2*c13.y) + (2*c10.x*c12.x*c12y2*c13.x*c21.y) + (6*c10.x*c20.y*c21.x*c13.x*c13y2) +
      (4*c10.y*c11.x*c12.y*c13x2*c21.y) + (6*c10.y*c20.x*c21.x*c13.x*c13y2) + (2*c10.y*c11.y*c12.x*c13x2*c21.y)) -
      (3*c10.y*c11.y*c21.x*c12.y*c13x2)) + (2*c10.y*c12.x*c21.x*c12y2*c13.x)) - (3*c11.x*c20.x*c12.x*c21.y*c13y2)) +
      (2*c11.x*c20.x*c21.x*c12.y*c13y2) + (c11.x*c11.y*c21.x*c12y2*c13.x)) - (3*c11.x*c12.x*c20.y*c21.x*c13y2)) +
      (4*c20.x*c11.y*c12.x*c21.x*c13y2)) - (6*c10.x*c20.y*c13x2*c21.y*c13.y) - (2*c10.x*c12x2*c12.y*c21.y*c13.y) -
      (6*c10.y*c20.x*c13x2*c21.y*c13.y) - (6*c10.y*c20.y*c21.x*c13x2*c13.y) - (2*c10.y*c12x2*c21.x*c12.y*c13.y) -
      (2*c10.y*c12x2*c12.y*c13.x*c21.y) - (c11.x*c11.y*c12x2*c21.y*c13.y) - (4*c11.x*c20.y*c12.y*c13x2*c21.y) -
      (2*c11.x*c11y2*c21.x*c13.x*c13.y)) + (3*c20.x*c11.y*c12.y*c13x2*c21.y)) - (2*c20.x*c12.x*c21.x*c12y2*c13.y) -
      (2*c20.x*c12.x*c12y2*c13.x*c21.y) - (6*c20.x*c20.y*c21.x*c13.x*c13y2) - (2*c11.y*c12.x*c20.y*c13x2*c21.y)) +
      (3*c11.y*c20.y*c21.x*c12.y*c13x2)) - (2*c12.x*c20.y*c21.x*c12y2*c13.x) - (c11y2*c12.x*c21.x*c12.y*c13.x)) +
      (6*c20.x*c20.y*c13x2*c21.y*c13.y) + (2*c20.x*c12x2*c12.y*c21.y*c13.y) + (2*c11x2*c11.y*c13.x*c21.y*c13.y) +
      (c11x2*c12.x*c12.y*c21.y*c13.y) + (2*c12x2*c20.y*c21.x*c12.y*c13.y) + (2*c12x2*c20.y*c12.y*c13.x*c21.y) +
      (3*c10x2*c21.x*c13y3)) - (3*c10y2*c13x3*c21.y)) + (3*c20x2*c21.x*c13y3) + (c11y3*c21.x*c13x2)) - (c11x3*c21.y*c13y2) -
      (3*c20y2*c13x3*c21.y) - (c11.x*c11y2*c13x2*c21.y)) + (c11x2*c11.y*c21.x*c13y2)) - (3*c10x2*c13.x*c21.y*c13y2)) +
      (3*c10y2*c21.x*c13x2*c13.y)) - (c11x2*c12y2*c13.x*c21.y)) + (c11y2*c12x2*c21.x*c13.y)) - (3*c20x2*c13.x*c21.y*c13y2)) +
      (3*c20y2*c21.x*c13x2*c13.y),

      ((((((((((((((((((((((((((((((((((((((((((((((((((c10.x*c10.y*c11.x*c12.y*c13.x*c13.y) - (c10.x*c10.y*c11.y*c12.x*c13.x*c13.y)) + (c10.x*c11.x*c11.y*c12.x*c12.y*c13.y)) -
      (c10.y*c11.x*c11.y*c12.x*c12.y*c13.x) - (c10.x*c11.x*c20.y*c12.y*c13.x*c13.y)) + (6*c10.x*c20.x*c11.y*c12.y*c13.x*c13.y) +
      (c10.x*c11.y*c12.x*c20.y*c13.x*c13.y)) - (c10.y*c11.x*c20.x*c12.y*c13.x*c13.y) - (6*c10.y*c11.x*c12.x*c20.y*c13.x*c13.y)) +
      (c10.y*c20.x*c11.y*c12.x*c13.x*c13.y)) - (c11.x*c20.x*c11.y*c12.x*c12.y*c13.y)) + (c11.x*c11.y*c12.x*c20.y*c12.y*c13.x) +
      (c11.x*c20.x*c20.y*c12.y*c13.x*c13.y)) - (c20.x*c11.y*c12.x*c20.y*c13.x*c13.y) - (2*c10.x*c20.x*c12y3*c13.x)) +
      (2*c10.y*c12x3*c20.y*c13.y)) - (3*c10.x*c10.y*c11.x*c12.x*c13y2) - (6*c10.x*c10.y*c20.x*c13.x*c13y2)) +
      (3*c10.x*c10.y*c11.y*c12.y*c13x2)) - (2*c10.x*c10.y*c12.x*c12y2*c13.x) - (2*c10.x*c11.x*c20.x*c12.y*c13y2) -
      (c10.x*c11.x*c11.y*c12y2*c13.x)) + (3*c10.x*c11.x*c12.x*c20.y*c13y2)) - (4*c10.x*c20.x*c11.y*c12.x*c13y2)) +
      (3*c10.y*c11.x*c20.x*c12.x*c13y2) + (6*c10.x*c10.y*c20.y*c13x2*c13.y) + (2*c10.x*c10.y*c12x2*c12.y*c13.y) +
      (2*c10.x*c11.x*c11y2*c13.x*c13.y) + (2*c10.x*c20.x*c12.x*c12y2*c13.y) + (6*c10.x*c20.x*c20.y*c13.x*c13y2)) -
      (3*c10.x*c11.y*c20.y*c12.y*c13x2)) + (2*c10.x*c12.x*c20.y*c12y2*c13.x) + (c10.x*c11y2*c12.x*c12.y*c13.x) +
      (c10.y*c11.x*c11.y*c12x2*c13.y) + (4*c10.y*c11.x*c20.y*c12.y*c13x2)) - (3*c10.y*c20.x*c11.y*c12.y*c13x2)) +
      (2*c10.y*c20.x*c12.x*c12y2*c13.x) + (2*c10.y*c11.y*c12.x*c20.y*c13x2) + (c11.x*c20.x*c11.y*c12y2*c13.x)) -
      (3*c11.x*c20.x*c12.x*c20.y*c13y2) - (2*c10.x*c12x2*c20.y*c12.y*c13.y) - (6*c10.y*c20.x*c20.y*c13x2*c13.y) -
      (2*c10.y*c20.x*c12x2*c12.y*c13.y) - (2*c10.y*c11x2*c11.y*c13.x*c13.y) - (c10.y*c11x2*c12.x*c12.y*c13.y) -
      (2*c10.y*c12x2*c20.y*c12.y*c13.x) - (2*c11.x*c20.x*c11y2*c13.x*c13.y) - (c11.x*c11.y*c12x2*c20.y*c13.y)) +
      (3*c20.x*c11.y*c20.y*c12.y*c13x2)) - (2*c20.x*c12.x*c20.y*c12y2*c13.x) - (c20.x*c11y2*c12.x*c12.y*c13.x)) +
      (3*c10y2*c11.x*c12.x*c13.x*c13.y) + (3*c11.x*c12.x*c20y2*c13.x*c13.y) + (2*c20.x*c12x2*c20.y*c12.y*c13.y)) -
      (3*c10x2*c11.y*c12.y*c13.x*c13.y)) + (2*c11x2*c11.y*c20.y*c13.x*c13.y) + (c11x2*c12.x*c20.y*c12.y*c13.y)) -
      (3*c20x2*c11.y*c12.y*c13.x*c13.y) - (c10x3*c13y3)) + (c10y3*c13x3) + (c20x3*c13y3)) - (c20y3*c13x3) -
      (3*c10.x*c20x2*c13y3) - (c10.x*c11y3*c13x2)) + (3*c10x2*c20.x*c13y3) + (c10.y*c11x3*c13y2) +
      (3*c10.y*c20y2*c13x3) + (c20.x*c11y3*c13x2) + (c10x2*c12y3*c13.x)) - (3*c10y2*c20.y*c13x3) - (c10y2*c12x3*c13.y)) +
      (c20x2*c12y3*c13.x)) - (c11x3*c20.y*c13y2) - (c12x3*c20y2*c13.y) - (c10.x*c11x2*c11.y*c13y2)) +
      (c10.y*c11.x*c11y2*c13x2)) - (3*c10.x*c10y2*c13x2*c13.y) - (c10.x*c11y2*c12x2*c13.y)) + (c10.y*c11x2*c12y2*c13.x)) -
      (c11.x*c11y2*c20.y*c13x2)) + (3*c10x2*c10.y*c13.x*c13y2) + (c10x2*c11.x*c12.y*c13y2) +
      (2*c10x2*c11.y*c12.x*c13y2)) - (2*c10y2*c11.x*c12.y*c13x2) - (c10y2*c11.y*c12.x*c13x2)) + (c11x2*c20.x*c11.y*c13y2)) -
      (3*c10.x*c20y2*c13x2*c13.y)) + (3*c10.y*c20x2*c13.x*c13y2) + (c11.x*c20x2*c12.y*c13y2)) - (2*c11.x*c20y2*c12.y*c13x2)) +
      (c20.x*c11y2*c12x2*c13.y)) - (c11.y*c12.x*c20y2*c13x2) - (c10x2*c12.x*c12y2*c13.y) - (3*c10x2*c20.y*c13.x*c13y2)) +
      (3*c10y2*c20.x*c13x2*c13.y) + (c10y2*c12x2*c12.y*c13.x)) - (c11x2*c20.y*c12y2*c13.x)) + (2*c20x2*c11.y*c12.x*c13y2) +
      (3*c20.x*c20y2*c13x2*c13.y)) - (c20x2*c12.x*c12y2*c13.y) - (3*c20x2*c20.y*c13.x*c13y2)) + (c12x2*c20y2*c12.y*c13.x)
    ]);

    let roots = poly.rootsInterval(0, 1);

    for (let i of Object.keys(roots || {})) {
      let s = roots[i];
      let xRoots = new Polynomial([
        c13.x,
        c12.x,
        c11.x,
        c10.x - c20.x - (s * c21.x) - (s * s * c22.x) - (s * s * s * c23.x)
      ]).roots();
      let yRoots = new Polynomial([
        c13.y,
        c12.y,
        c11.y,
        c10.y - c20.y - (s * c21.y) - (s * s * c22.y) - (s * s * s * c23.y)
      ]).roots();


      if ((xRoots.length > 0) && (yRoots.length > 0)) {
        // IMPORTANT
        // Tweaking this to be smaller can make it miss intersections.
        let tolerance = 1e-2;

        for (let j of Object.keys(xRoots || {})) {
          let xRoot = xRoots[j];
          if ((0 <= xRoot) && (xRoot <= 1)) {
            for (let k of Object.keys(yRoots || {})) {
              let yRoot = yRoots[k];
              if (Math.abs(xRoot - yRoot) < tolerance) {
                results.push(
                  c23.multiplyBy(s * s * s).add(c22.multiplyBy(s * s).add(c21.multiplyBy(s).add(c20))));
              }
            }
          }
        }
      }
    }
    return results;
  }
}

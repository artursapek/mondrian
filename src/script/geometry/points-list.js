import lab from 'script/lab/lab';
import PointsSegment from 'script/geometry/points-segment';
import {
  PathPoint,
  MoveTo,
  LineTo,
  HorizTo,
  VertiTo,
  CurveTo,
  SmoothTo,
} from 'script/geometry/path-points';


/*

  PointsList

  Stores points, keeps them in order, lets you do shit
  Basically a linked-list.

*/


export default class PointsList {
  static initClass() {
  
    this.prototype.first = null;
    this.prototype.last = null;
  
    this.prototype.firstSegment = null;
    this.prototype.lastSegment = null;
  
    this.prototype.closed = false;
  }
  constructor(alop, owner, segments) {
    // Build this thing out of PointsSegment objects.
    //
    // I/P:
    //   alop: a list of Points or a string
    //   @owner: Mongsvg element these points belong to

    // This is just one big for-loop with intermediate calls
    // to commitSegment every time we run into a MoveTo.
    //
    // Effectively we create many PointsSegments starting with MoveTos
    // and going until the next MoveTo (which is the start of the
    // next PointsSegment)

    // First, if we were given a string of SVG points let's
    // parse that into what we work with, an array of Points
    this.owner = owner;
    if (segments == null) { segments = []; }
    this.segments = segments;
    if (typeof alop === "string") {
      alop = lab.conversions.stringToAlop(alop, this.owner);
    }

    // Now set up some helper variables to keep track of things

    // The point segment we are working on right now
    // This gets shoved into @segments when commitSegment is called
    let accumulatedSegment = [];

    // The last point we made.
    // Used to keep track of prec and succ relationships.
    let lastPoint = undefined;

    let commitSegment = () => {
      // Helper method that gets called for every MoveTo we bump into.
      // Basically we stack points up starting with a MoveTo and
      // until the next MoveTo, then we call this and it takes
      // that stack and makes a PointsSegment with them.

      if (accumulatedSegment.length === 0) { return; }

      // Make the PointsSegment
      let sgmt = new PointsSegment(accumulatedSegment, this);

      // Keep track of which is our last segment
      this.lastSegment = sgmt;

      // Only set it as the first segment if that hasn't been set yet
      // (which would mean that it is indeed the first segment)
      if (this.firstSegment === null) {
        this.firstSegment = sgmt;
      }

      // Commit the PointsSegment to this PointsList's @segments!
      this.segments.push(sgmt);

      // Reset the accumulated points stack array
      return accumulatedSegment = [];
    };

    // We can call PointsList with pre-constructed PointsSegments.
    // In this case, set up these two variables manually.
    if (this.segments.length !== 0) {
      this.firstSegment = this.segments[0];
      this.lastSegment = this.segments[this.segments.length - 1];
    }

    if (alop.length === 0) { return; } // Initiate empty PointsList

    // Now we iterate thru the points and split them into PointsSegment objects
    for (let ind of Object.keys(alop || {})) {

      // Get integer of index number, save it as point.at attribute
      let point = alop[ind];
      ind = parseInt(ind, 10);
      point.at = ind;

      // Set the @first and @last aliases as we get to them
      if (ind === 0) { this.first = point; }
      if (ind === (alop.length - 1)) { this.last = point; }

      point.setPrec(((lastPoint != null) ? lastPoint : alop[alop.length - 1]));
      if (lastPoint != null) {
        lastPoint.setSucc(point);
      }

      if (point instanceof MoveTo) {
        // Close up the last segment, start a new one.
        commitSegment();
      }

      accumulatedSegment.push(point);

      // Now we're done, so set this as the lastPoint for the next point ;^)
      lastPoint = point;
    }

    // Get the last one we never got to.
    commitSegment();
    lastPoint.setSucc(this.first);
  }

  moveSegmentToFront(segment) {
    if (!(this.segments.has(segment))) { return; }
    return this.segments = this.segments.cannibalizeUntil(segment);
  }

  movePointToFront(point) {
    this.moveSegmentToFront(point.segment);
    return point.segment.movePointToFront(point);
  }


  firstPointThatEquals(point) {
    return this.filter(p => p.equal(point))[0];
  }


  closedOnSameSpot() {
    return this.closed && (this.last.equal(this.first));
  }


  length() {
    return this.segments.reduce((a, b) => a + b.points.length
    , 0);
  }


  all() {
    let pts = [];
    for (let s of Array.from(this.segments)) {
      pts = pts.concat(s.points);
    }
    return pts;
  }


  renumber() {
    return this.all().map(function(p, i) {
      p.at = i;
      return p;
    });
  }

  pushSegment(sgmt) {
    this.lastSegment = sgmt;
    return this.segments.push(sgmt);
  }


  push(point, after) {
    // Add a new point!

    if (this.segments.length === 0) {
      this.pushSegment(new PointsSegment([], this));
    }

    point.owner = this.owner;

    if ((after == null)) {
      point.at = this.lastSegment.points.length;
      this.lastSegment.points.push(point);

      if (this.last != null) {
        this.last.setSucc(point);
        point.setPrec(this.last);
      } else {
        point.setPrec(point);
      }

      if (this.first != null) {
        this.first.setPrec(point);
        point.setSucc(this.first);
      } else {
        point.setSucc(point);
      }

      this.last = point;

      return this;
    }
  }


  replace(old, replacement) {
    return this.segmentContaining(old).replace(old, replacement);
  }


  reverse() {
    // Reverse the order of the points, while maintaining the exact same shape.
    return new PointsList([], this.owner, this.segments.map(s => s.reverse()));
  }


  at(n) {
    return this.segmentContaining(parseInt(n, 10)).at(n);
  }

  close() {
    this.closed = true;
    return this;
  }

  relative() {
    this.segments = this.segments.map(function(s) {
      s.points = s.points.map(function(p) {
        let abs = p.relative();
        abs.inheritPosition(p);
        return abs;
      });
      return s;
    });
    return this;
  }

  absolute() {
    this.segments = this.segments.map(function(s) {
      s.points = s.points.map(function(p) {
        let abs = p.absolute();
        abs.inheritPosition(p);
        return abs;
      });
      return s;
    });
    return this;
  }

  drawBasePoints() {
    this.map(function(p) {
      if (p.baseHandle != null) {
        p.baseHandle.remove();
      }
      p.draw();
      return p.makeAntlers();
    });
    return this;
  }

  removeBasePoints() {
    this.map(p => p.baseHandle != null ? p.baseHandle.remove() : undefined);
    return this;
  }


  hide() {
    return this.map(p => p.hide());
  }

  unhover() {
    return this.map(p => p.unhover());
  }

  join(x) {
    return this.all().join(x);
  }

  segmentContaining(a) {
    if (typeof a === "number") {
      let segm;
      for (let s of Array.from(this.segments)) {
        if (s.startsAt <= a) {
          segm = s;
        } else { break; }
      }
      return segm;
    } else {
      let segments = this.segments.filter(s => s.points.indexOf(a) > -1);
      if (segments.length === 1) { return segments[0]; }
    }
    return [];
  }


  hasPointWithin(tolerance, point) {
    return this.filter(p => p.within(tolerance, point)).length > 0;
  }


  remove(x) {
    if (typeof x === "number") {
      x = this.at(x);
    }
    if (x instanceof Array) {
      return Array.from(x).map((p) =>
        this.remove(p));
    } else if (x instanceof PathPoint) {
      return this.segmentContaining(x).remove(x);
    }
  }

  filter(fun) {
    return this.all().filter(fun);
  }

  filterSegments(fun) {
    return this.segments.map(segment => new PointsSegment(segment.points.filter(fun)));
  }

  fetch(cl) {
    // Given a class like MoveTo or CurveTo or Point or CurvePoint,
    // return all points of that class.
    return this.all().filter(p => p instanceof cl);
  }

  map(fun) {
    return this.segments.map(s => s.points.map(fun));
  }

  forEach(fun) {
    return this.segments.forEach(s => s.points.forEach(fun));
  }

  mapApply(fun) {
    return this.segments.map(s => s.points = s.points.map(fun));
  }

  xRange() {
    let xs = this.all().map(p => p.x);
    return new Range(Math.min.apply(this, xs), Math.max.apply(this, xs));
  }

  yRange() {
    let ys = this.all().map(p => p.y);
    return new Range(Math.min.apply(this, ys), Math.max.apply(this, ys));
  }

  toString() {
    return this.segments.join(' ') + (this.closed ? "z" : "");
  }

  insideOf(other) {
    return this.all().filter(p => p.insideOf(other));
  }

  notInsideOf(other) {
    return this.all().filter(p => !p.insideOf(other));
  }

  withoutMoveTos() {
    return new PointsList([], this.owner, this.filterSegments(p => !(p instanceof MoveTo)));
  }
}
PointsList.initClass();


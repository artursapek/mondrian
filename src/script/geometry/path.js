import Monsvg from 'script/geometry/monsvg'

/*

  Path

  Highest order of vector data. Lowest level of expression.

*/

class Path extends Monsvg {
  static initClass() {
    this.prototype.type = 'path';
  
  
    // Are we caching expensive metadata like bounds?
    this.prototype.caching = true;
  
    // A Path can have a "virgin" attribute that it will be exported as if no points
    // have been changed individually since it was assigned.
    // You would assign another SVG element as its virgin attr and that will get scaled,
    // nudged alongside the Path itself.
    // Any time a point is moved by itself and the "shape" is changed, the virgin attribute
    // is reset to false.
    this.prototype.virgin = undefined;
  
  
    this.prototype.xRangeCached = null;
  
  
    this.prototype.yRangeCached = null;
  
    this.prototype.lineSegmentsCached = null;
  }


  constructor(data) {
    this.data = data;
    super(this.data);

    if ((this.data != null ? this.data.d : undefined) != null) {
      this.importNewPoints(this.data.d);
    }


    this.antlerPoints = new PointsList([], this);

    // Kind of a hack
    if (__guard__(this.data != null ? this.data.d : undefined, x => x.match(/z$/gi)) !== null) {
      this.points.closed = true;
    }
  }


  commit() {
    this.data.d = this.points.toString();
    return super.commit(...arguments);
  }


  hover() {
    if (!ui.selection.elements.all.has(this)) {
      this.showPoints();
    }

    return ui.unhighlightHoverTargets();
  }

  unhover() {
    return this.hidePoints();
  }


  virginMode() {
    this.virgin.eyedropper(this);
    return this.$rep.replaceWith(this.virgin.$rep);
  }


  editMode() {
    return this.virgin.$rep.replaceWith(this.$rep);
  }


  woohoo() {
    return this.virgin = undefined;
  }


  importNewPoints(points) {
    if (points instanceof PointsList) {
      this.points = points;
    } else {
      this.points = new PointsList(points, this);
    }

    this.points = this.points.absolute();

    this.clearCachedObjects();

    return this;
  }


  cleanUpPoints() {
    for (let p of Array.from(this.points.all())) {
      p.cleanUp();
    }
    return this.commit();
  }


  appendTo(selector, track) {
    if (track == null) { track = true; }
    super.appendTo(selector, track);
    this.points.drawBasePoints().hide();
    if (track) { this.redrawHoverTargets(); }
    return this;
  }


  xRange() {
    let cached = this.xRangeCached;
    if (cached !== null) {
      return cached;
    } else {
      return this.xRangeCached = new Range().fromRangeList(this.lineSegments().map(x => x.xRange()));
    }
  }


  yRange() {
    let cached = this.yRangeCached;
    if (cached !== null) {
      return cached;
    } else {
      return this.yRangeCached = new Range().fromRangeList(this.lineSegments().map(x => x.yRange()));
    }
  }


  nudgeCachedObjects(x, y) {
    if (this.boundsCached != null) {
      this.boundsCached.nudge(x, y);
    }
    if (this.xRangeCached != null) {
      this.xRangeCached.nudge(x);
    }
    if (this.yRangeCached != null) {
      this.yRangeCached.nudge(y);
    }
    return (this.lineSegmentsCached != null ? this.lineSegmentsCached.map(ls => ls.nudge(x, y)) : undefined);
  }


  scaleCachedObjects(x, y, origin) {
    if (this.boundsCached != null) {
      this.boundsCached.scale(x, y, origin);
    }
    if (this.xRangeCached != null) {
      this.xRangeCached.scale(x, origin.x);
    }
    if (this.yRangeCached != null) {
      this.yRangeCached.scale(y, origin.y);
    }
    return this.lineSegmentsCached = null;
    /*
    @lineSegmentsCached.map (ls) ->
      ls.scale(x, y, origin)
    */
  }


  clearCachedObjects() {
    this.lineSegmentsCached = null;
    this.boundsCached = null;
    this.xRangeCached = null;
    this.yRangeCached = null;
    return this;
  }


  lineSegments() {
    // No I/P
    //
    // O/P: A list of LineSegments and/or CubicBeziers representing this path
    let cached = this.lineSegmentsCached;
    if (cached !== null) {
      return cached;
    } else {
      let segments = [];
      this.points.all().map((curr, ind) => {
        return segments.push(lab.conversions.pathSegment(curr, curr.succ));
      });
      return this.lineSegmentsCached = segments;
    }
  }

  scale(x, y, origin) {
    // Keep track of cached bounds and line segments
    if (origin == null) { origin = this.center(); }
    this.scaleCachedObjects(x, y, origin);

    // We might need to rotate and unrotate this thing
    // to keep its angle true. This way we can scale at angles
    // after we rotate shapes.
    let { angle } = this.metadata;

    // Don't do unecessary work: only do rotation if shape has an angle other than 0
    if (angle !== 0) {
      // Rotate the shape to normal (0 degrees) before doing the scaling.
      this.rotate(360 - angle, origin);
    }

    // After we've unrotated it, scale it
    this.points.map(a => a.scale(x, y, origin));

    if (angle !== 0) {
      // ...and rotate it back to where it should be.
      this.rotate(angle, origin);
    }

    // Boom
    this.commit();

    // Carry out on virgin rep
    return (this.virgin != null ? this.virgin.scale(x, y, origin) : undefined);
  }


  nudge(x, y) {
    // Nudge dis bitch
    this.points.map(p => p.nudge(x, y, false));

    // Nudge the cached bounds and line segments if they're there
    // to keep track of those.
    this.nudgeCachedObjects(x, y);

    // Commit the changes to the canvas
    this.commit();

    // Also nudge the virgin shape if there is one
    return (this.virgin != null ? this.virgin.nudge(x, y) : undefined);
  }


  rotate(a, origin) {
    // Add to the transform angle we're keeping track of.
    if (origin == null) { origin = this.center(); }
    this.metadata.angle += a;

    // Normalize it to be 0 <= n <= 360
    this.metadata.angle %= 360;

    // At this point the bounds are no longer valid, so ditch it.
    this.clearCachedObjects();

    // Rotate all the points!
    this.points.map(p => p.rotate(a, origin));

    // Commit it
    this.commit();

    // Rotated rect becomes path
    return this.woohoo();
  }


  fitToBounds(bounds) {
    this.clearCachedObjects();
    let mb = this.bounds();
    // Make up for the difference

    let myWidth = mb.width;
    let myHeight = mb.height;

    let sx = bounds.width / mb.width;
    let sy = bounds.height / mb.height;

    if ((isNaN(sx)) || (sx === Infinity) || (sx === -Infinity) || (sx === 0)) { sx = 1; }
    if ((isNaN(sy)) || (sy === Infinity) || (sy === -Infinity) || (sy === 0)) { sy = 1; }

    sx = Math.max(1e-5, sx);
    sy = Math.max(1e-5, sy);

    this.scale(sx, sy, new Posn(mb.x, mb.y));
    return this.nudge(bounds.x - mb.x, mb.y - bounds.y);
  }

    //debugger if @points.toString().indexOf("NaN") > -1


  overlapsRect(rect) {
    if (this.bounds().overlapsBounds(rect.bounds())) {
      // First, check if any of our points are inside of this rectangle.
      // This is a much cheaper operation than line segment intersections.
      // We resort to that if no points are found inside of the rect.
      for (let point of Array.from(this.points.all())) {
        if (point.insideOf(rect)) {
          return true;
        }
      }
      return this.lineSegmentsIntersect(rect);
    } else {
      return false;
    }
  }


  drawToCanvas(context) {
    context = this.setupToCanvas(context);
    for (let point of Array.from(this.points.all())) {
      switch (point.constructor) {
        case MoveTo:
          context.moveTo(point.x, point.y);
          break;
        case LineTo: case HorizTo: case VertiTo:
          context.lineTo(point.x, point.y);
          break;
        case CurveTo: case SmoothTo:
          context.bezierCurveTo(point.x2, point.y2, point.x3, point.y3, point.x, point.y);
          break;
      }
    }
    return this.finishToCanvas(context);
  }
}
Path.initClass();


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

/*

  Pathfinder

  Union, subtract, intersect.

  In-progress; this is still unstable, buggy. Not available through UI yet.
  To invoke "Union", select elements and hit "U" on the keyboard.


  *///#######
  //         #
  //    ###########
  //    #    #    #
  //##########    #
       //         #
       //##########


const DEBUGGING = true;


let pathfinder = {

  // Public API

  merge(elems) {
    this._reset();

    // First thing we want to do is clone everything, so we can
    // fuck around with the points behind the scenes.
    let elemClones = elems.map(elem => elem.clone());

    while (elemClones.length > 1) {
      let [first, second] = Array.from([elemClones[0], elemClones[1]]);
      let merged = this._mergePair(first, second);
      // Replace the old couple of elems with the newly merged elem
      elemClones = [merged].concat(elemClones.slice(2));
    }

    let finalResult = elemClones[0];
    //elems.forEach (e) -> e.remove()
    finalResult.appendTo('#main');
    finalResult.eyedropper(elems[0]);


    return ui.selection.elements.select(finalResult);
  },


  // Private helpers

  _segments: [],

  _segmentAccumulation: [],

  _intersections: [],

  _keep(point) {
    this._segmentAccumulation.push(point);
    //ui.annotations.clear() if DEBUGGING
    if (DEBUGGING) { ui.annotations.drawDot(point, ui.colors.black.hex, 4); }
    return point.flag('kept');
  },

  _commitCurrentSegment() {
    if (this._segmentAccumulation.length === 0) { return; }
    this._segments.push(new PointsSegment(this._segmentAccumulation).ensureMoveTo());
    return this._segmentAccumulation = [];
  },

  _getIntersection(point) {
    let fil = this._intersections.filter(int => int.intersection.has(p => p.equal(point)));
    if (fil.length > 0) {
      return fil[0];
    }
  },

  _packageSegmentsIntoPathElement() {
    let pointsList = new PointsList([], [], this._segments);
    let pathElement = new Path({
      // This isn't good because we're re-parsing objects we already have
      // but importNewPoints is jank. TODO fix
      d: pointsList.toString(),
      fill: new Color(0,0,0,0.4).toRGBString(),
      stroke: ui.colors.black.hex
    });

    return pathElement;
  },


  _reset() {
    return this._segments = (this._segmentAccumulation = (this._intersections = []));
  },


  _splitAtIntersections(elem, intersections) {
    // Given an elem and a pre-calculated list of intersections
    // with another elem, split this elem's line segments
    // at every point at which they have an intersection

    if (intersections.length === 0) { return elem; }

    let workingPoints = elem.points.all();

    for (var ls of Array.from(elem.lineSegments())) {

      // Intersections with this line segment
      let inter = intersections.filter(int => (int.aline.equal(ls)) || (int.bline.equal(ls)));

      if (inter.length > 0) {
        // NOTE: There may be more than one intersection since
        // a line segment may intersect with more than one other ls

        let originalPoint = ls.source;

        // If the next point was a SmoothTo, its p2 depends on this point's p3.
        // So let's just convert it into an independent CurveTo to maintain
        // its curve.
        if (originalPoint.succ instanceof SmoothTo) {
          originalPoint.succ.replaceWithCurveTo();
        }

        let posns = inter.reduce((x, y) =>
          // Since intersection objects have an array
          // of one or more intersection points,
          // we need to just get all these arrays and
          // flatten them into a single array.
          x.concat(y.intersection)
        
        , []);

        // TODO this is inefficient
        posns = posns.filter(function(p) {
          let valid = (workingPoints.filter(x => x.within(0.1, p)).length === 0);
          if (valid) { workingPoints.push(p); }
          return valid;
        });

        // Convert the line segment into a list of line segments
        // created by splitting it at each of the posns
        let lsSplit = ls.splitAt(posns);

        // Go backwards to get the original points that would
        // make up these line segments; these are what we'll be replacing
        // the point that made the original line segment with.
        let newListOfPoints = lsSplit.map(lx => lx.source);

        // We know we want to keep all intersection points,
        // which in this case is all but the last (original) point.
        newListOfPoints.slice(0, newListOfPoints.length - 1)
        .forEach(p => p.flag('desired'));

        // Replace the original point with the new points
        elem.points.replace(originalPoint, newListOfPoints);
      }
    }
    return elem;
  },


  _desiredPointsRemaining(points) {
    return points.filter(p => (p.flagged('desired')) && (!(p.flagged('kept'))));
  },

  _findAndSplitIntersections(a, b) {
    this._intersections = lab.analysis.intersections(a, b);
    a = this._splitAtIntersections(a, this._intersections);
    b = this._splitAtIntersections(b, this._intersections);
    return [a, b];
  },

  _removeOverlappingAdjecentPoints(elem) {
    return elem.points.forEach(function(p) {
      if (p.within(1e-5, p.succ)) {
        return elem.points.remove(p);
      }
    });
  },


  _flagDesiredPoints(a, b) {
    a.points.all().forEach(function(point) {
      if (!point.insideOf(b)) {
        return point.flag('desired');
      }
    });
    b.points.all().forEach(function(point) {
      if (!point.insideOf(a)) {
        return point.flag('desired');
      }
    });
    return [a, b];
  },

  _mergePair(first, second) {
    this._intersections = lab.analysis.intersections(first, second);

    // Manipulate both shapes such that they have new points
    // where they intersect with each other.
    [first, second] = Array.from(this._findAndSplitIntersections(first, second));

    // Go through all the points and flag those that we don't wish to keep.
    [first, second] = Array.from(this._flagDesiredPoints(first, second));

    // Purge the points list of MoveTos, since we're almost certainly
    // going to have a different amount/arrangement of point segments
    let pointsWalking =   first.points.withoutMoveTos();
    let pointsAlternate = second.points.withoutMoveTos();

    // Recursively walk through the two stacks of
    // points until we've satisfied the requirement that all
    // desired points make it into the new stack.
    this._walk(pointsWalking, pointsAlternate);

    let result = this._packageSegmentsIntoPathElement();

    this._reset();

    return result;
  },


  _walk(pointsWalking, pointsAlternate) {
    // _walk does most of the work.
    // It gets two bare lists of ordered points: one that we're
    // traversing and keeping points from, and one that we
    // are prepared to switch to given an intersection.
    // This is a recursive function.

    // The shape whose points we're currently traversing
    let current = pointsWalking.owner;

    for (let segment of Array.from(pointsWalking.segments)) {
      // We iterate in mini-loops within the pointSegments
      let { points } = segment;

      if (points[0].flagged('kept')) {
        // Base case; we've flipped back over to this point from an intersection,
        // so we've gone full-circle on this perimeter.
        // Close up this pointSegment (...z M....)
        // Then check if we still have more points not included,
        // with which we'll start a new pointSegment.
        this._commitCurrentSegment();

        // Returns FLATTENED ARRAY, not usable in recursion
        let pointsRemainingWalking = this._desiredPointsRemaining(pointsWalking);
        let pointsRemainingAlternate = this._desiredPointsRemaining(pointsAlternate);

        if ((pointsRemainingWalking.length === 0) || (pointsRemainingAlternate.length === 0)) {
          // We're done with these sets of points
          return;
        }

        if (pointsRemainingWalking.length > 0) {
          pointsWalking.movePointToFront(pointsRemainingWalking[0]);
          return this._walk(pointsWalking, pointsAlternate);

        } else if (pointsRemainingAlternate.length > 0) {
          pointsAlternate.movePointToFront(pointsRemainingAlternate[0]);
          return this._walk(pointsAlternate, pointsWalking);
        }
      }

      // Start iterating through the points and adding them to the
      // accumulated segment in the order they are chained together.
      for (var point of Array.from(points)) {

        if (DEBUGGING) { ui.annotations.drawDot(point, ui.colors.green.hex, 8); }

        // Is it an intersection point that we added? If so,
        // we're toggling over to the other shape.
        let intersection = this._getIntersection(point);
        if (intersection) {

          // Find the same point on alternate element.
          var desiredPoint;
          let otherSamePoint = pointsAlternate.filter(p =>
            // NOTE Potential bug when exactly matching points exist
            p.equal(point)
          )[0];

          // We only need one of these, and there's two, so always
          // flag the other one as kept without actually keeping it
          otherSamePoint.flag('kept');

          // Now we need to decide which direction we're going in. There are two options.

          // Moving forward
          let optionA = lab.conversions.pathSegment(otherSamePoint, otherSamePoint.succ);
          // Moving backward
          let optionB = lab.conversions.pathSegment(otherSamePoint.prec, otherSamePoint);

          // Now we're faced with two directions we can go in.
          // One of them will go into the current shape, and the other
          // will go the opposite way. We want to go the opposite way.
          //
          // We find out which line doesn't go into the current shape
          // by finding the one whose midpoint is not inside of it.

          if (otherSamePoint.within(1e-2, otherSamePoint.succ)) {
            let succTooClose = true;
          }

          if (otherSamePoint.within(1e-2, otherSamePoint.prec)) {
            let precTooClose = true;
          }

          if (!(optionA.midPoint().insideOf(current))) {
            // ...then we want to move forward
            desiredPoint = otherSamePoint.succ;

          } else if (!(optionB.midPoint().insideOf(current))) {
            // ...then we want to move backward, so we'll have to reverse the points.
            pointsAlternate = pointsAlternate.reverse();
            // TODO ABSTRACT
            otherSamePoint = pointsAlternate.filter(p => p.equal(point))[0];
            // Since we're going backwards, actually take the successor here
            desiredPoint = otherSamePoint.succ;

          } else {
            print("PANIC");
          }

          let desiredSegment = desiredPoint.segment;

          // Ok now we know what point we want to go back over to
          // Get that point's segment in front
          pointsAlternate.moveSegmentToFront(desiredSegment);

          // ...and get the point in front
          desiredSegment.movePointToFront(desiredPoint);

          // Now we're ready to _walk again
          // Keep this intersection point
          this._keep(point);

          // Stop iterating over these points.
          // Recur on other element's points.
          return this._walk(pointsAlternate, pointsWalking);

        } else {

          // If it's not an intersection, just keep it and keep moving
          if (point.flagged('kept')) {
            break;

          } else {
            this._keep(point);
          }
        }
      }

      this._commitCurrentSegment();

      // If we've gotten to the end of a segment,
      // let's make sure we shouldn't loop back
      // around to the beginning of it before moving on.
      let desiredPointsRemaining = this._desiredPointsRemaining(segment.points);

      if (desiredPointsRemaining.length === 0) {
        if (pointsWalking.segments.without(segment).length === 0) {
          // If there are no other segments, toggle
          this._walk(pointsAlternate, pointsWalking);
        } else {
          // If there are, go on to the next segment
          pointsWalking.segments = pointsWalking.segments.cannibalize();
          this._walk(pointsWalking, pointsAlternate);
        }
      } else {
        segment.movePointToFront(desiredPointsRemaining[0]);
        // Keep going with that segment in place as the first one
        this._walk(pointsWalking, pointsAlternate);
      }
    }

    this._commitCurrentSegment();

    // If we've iterated over all of pointsWalking's segments
    // we should check that pointsAlternate doesn't still have stuff for us,
    // so let's just flip and recur.
    return this._walk(pointsAlternate, pointsWalking);
  }
};




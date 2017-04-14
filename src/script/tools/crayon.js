/*

  Crayon plz

*/

tools.crayon = new Tool({

  offsetX: 5,
  offsetY: 0,
  cssid: 'crayon',
  id: 'crayon',

  hotkey: 'C',

  drawing: false,

  setup() {},

  tearDown() {},

  // How many events we go between putting down a point
  // Which kind of point alternates:
  frequency: 0,

  eventCounter: 0,

  alternatingCounter: 2,

  beginNewLine(e) {
    let line = new Path({
      stroke: ui.stroke,
      fill:   ui.fill,
      'stroke-width': ui.uistate.get('strokeWidth'),
      d: `M${e.canvasX},${e.canvasY}`});
    line.appendTo('#main');
    line.commit().showPoints();

    this.line = line;
    return this.currentPoint = this.line.points.first;
  },

  determineControlPoint(which) {
    // Helper for the crayon
    let compareA, compareB, stashed;
    switch (which) {
      case "p2":
        [compareA, compareB, stashed] = Array.from([this.lastPoint, this.currentPoint, this.stashed33]);
        break;
      case "p3":
        [compareA, compareB, stashed] = Array.from([this.currentPoint, this.lastPoint, this.stashed66]);
        break;
    }

    let lastBaseToNewBase = new LineSegment(compareA, compareB);
    let lastBaseTo33      = new LineSegment(compareA, stashed);

    let lBBA =  lastBaseToNewBase.angle360();
    let lB33A = lastBaseTo33.angle360();

    let angleBB = lB33A - lBBA;
    let angleDesired = lBBA + (angleBB * 2);

    let lenBB = lastBaseToNewBase.length;
    let lenDesired = lenBB / 3;

    let desiredHandle = new Posn(compareA);
    desiredHandle.nudge(0, -lenDesired);
    desiredHandle.rotate(angleDesired + 180, compareA);

    if (isNaN(desiredHandle.x)) {
      desiredHandle.x = compareB.x;
    }
    if (isNaN(desiredHandle.y)) {
      desiredHandle.y = compareB.y;
    }

    return desiredHandle;
  },

  stashedBaseP3: undefined,

  addPoint(e) {
    switch (this.alternatingCounter) {
      case 1:
        this.lastPoint = this.currentPoint;

        // Now we figure out where the last succp2 should have been
        // Twice the angle, half the length.

        if (e != null) {
          this.currentPoint = new CurveTo(
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            e.canvasX, e.canvasY,
            this.line);
        }

        //ui.annotations.drawDot(@currentPoint, '#ff0000')

        this.alternatingCounter = 2;

        //  Time for a shitty diagram!
        //
        //           C
        //          / \
        //         /   |
        //        /     |
        //       /    /
        //      /   X
        //     / /
        //    L------V
        //
        //   L = @lastPoint
        //   C = @currentPoint
        //   X = @stashed33
        //   V = what we want
        //
        //   Line from L-C = lastBaseToNewBase
        //   Line from L-V = lastBaseTo33

        if ((this.stashed33 == null)) { return; }

        this.lastPoint.antlers.succp2 = this.determineControlPoint('p2');
        this.currentPoint.antlers.basep3 = this.determineControlPoint('p3');

        this.lastPoint.succ = this.currentPoint;

        // Now that lastPoint has both antlers,
        // flatten them to be no less than 180
        this.lastPoint.antlers.flatten();
        this.lastPoint.antlers.commit();
        this.currentPoint.antlers.commit();

        this.line.points.push(this.currentPoint);
        this.currentPoint.draw();

        this.line.points.hide();
        return this.line.commit();

      case 2:
        // Stash the 33% mark
        this.stashed33 = e.canvasPosnZoomed;
        return this.alternatingCounter = 3;

      case 3:
        // Stash the 66% mark
        this.stashed66 = e.canvasPosnZoomed;
        return this.alternatingCounter = 1;
    }
  },


  // A static click means they didn't move, so don't do anything
  // We don't want stray points
  click: {
    all() {}
  },

  startDrag: {
    all(e) {
      return this.beginNewLine(e);
    }
  },

  continueDrag: {
    all(e) {
      //ui.annotations.drawDot(e.canvasPosnZoomed, 'rgba(0,0,0,0.2)')
      if (this.eventCounter === this.frequency) {
        this.addPoint(e);
        return this.eventCounter = 0;
      } else {
        return this.eventCounter += 1;
      }
    }
  },


  stopDrag: {
    all() {
      //ui.selection.elements.select @line
      // (meh)
      this.line.redrawHoverTargets();
      archive.addExistenceEvent(this.line.rep);
      return this.line = undefined;
    }
  }
});


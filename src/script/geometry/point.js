import Posn from 'script/geometry/posn';
/*

  Point



     o -----------
    /
   /
  /

  Tangible body for posn.
  Stored in PointsList for every shape.
  Comes in many flavors for a Path:
    MoveTo
    LineTo
    HorizTo
    VertiTo
    CurvePoint
      CurveTo
      SmoothTo

  This is the most heavily sub-classed class, even heavier than Monsvg.
  It's also the most heavily used, since all shapes are made of many of these.

  Needless to say, this is a very important class.
  Its efficiency basically decides the entire application's speed.
  (Not sure it's as good as it could be right now)

*/

export default class Point extends Posn {
  static initClass() {
  
    this.prototype.absoluteCached = undefined; //
  
    this.prototype.prec = null;
    this.prototype.succ = null;
  }

  constructor(x, y, owner) {
    this.x = x;
    this.y = y;
    this.owner = owner;
    this.constructArgs = arguments;
    if (((this.x == null)) && ((this.y == null))) { return; }


    // Robustness principle!
    // You can make a Point in many ways.
    //
    //   Posn: Give a posn, and it will just inherit the x and y positions
    //   Event:
    //     Give it an event with clientX and clientY
    //   Object:
    //     Give it a generic Object with an x and y
    //   String:
    //     Give it an SVG string like "M10 20"
    //
    // It will do what's most appropriate in each case; for the first three
    // it will just inherit x and y values from the input. In the third case
    // given an SVG string it will actually return a subclass of itself based
    // on what the string is.

    if (this.x instanceof Posn) {
      this.owner = this.y;
      this.y = this.x.y;
      this.x = this.x.x;
    } else if (this.x instanceof Object) {
      this.owner = this.y;
      if (this.x.clientX != null) {
        // ...then it's an Event object
        this.y = this.x.clientY;
        this.x = this.x.clientX;
      } else if ((this.x.x != null) && (this.x.y != null)) {
        // ...then it's some generic object
        this.y = this.x.y;
        this.x = this.x.x;
      }
    } else if (typeof this.x === "string") {
      // Call signature in this case:
      // new Point(pointString, owner, prec)
      // Example in lab.conversions.stringToAlop
      let prec;
      if (this.owner != null) { prec   = this.owner; }
      if (this.y != null) { this.owner = this.y; }
      let p = this.fromString(this.x, prec);
      return p;
    }

    if (isNaN(this.x)) { console.warn('NaN x'); }
    if (isNaN(this.y)) { console.warn('NaN y'); }

    this._flags = [];

    this.makeAntlers();

    super(this.x, this.y);
  }



  fromString(point, prec) {
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

            values.push(this.owner); // Point owner
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

  select() {
    this.show();
    this.showHandles();
    this.antlers.refresh();
    this.baseHandle.setAttribute('selected', '');
    return this;
  }

  deselect() {
    this.baseHandle.removeAttribute('selected');
    if (typeof this.hideHandles === 'function') {
      this.hideHandles();
    }
    this.hide();
    return this;
  }

  draw() {
    // Draw the main handle DOM object.
    this.$baseHandle = $('<div class="transform handle point"></div>');

    this.baseHandle = this.$baseHandle[0];
    // Set up the handle to have a connection to this elem

    if (this.at === undefined) {
      if (!(this instanceof AntlerPoint)) { debugger; }
    }

    this.baseHandle.setAttribute('at', this.at);
    if (this.owner != null) { this.baseHandle.setAttribute('owner', this.owner.metadata.uuid); }

    this.updateHandle(this.baseHandle, this.x, this.y);
    if (dom.ui != null) {
      dom.ui.appendChild(this.baseHandle);
    }

    return this;
  }


  makeAntlers() {
    let p2;
    if (this.succ != null) {
      p2 = (this.succ.p2 != null) ? this.succ.p2() : undefined;
    } else {
      p2 = null;
    }
    let p3 = (this.p3 != null) ? this.p3() : null;
    this.antlers = new Antlers(this, p3, p2);
    return this;
  }

  showHandles() {
    return this.antlers.show();
  }

  hideHandles() {
    return this.antlers.hide();
  }

  actionHint() {
    return this.baseHandle.setAttribute('action', '');
  }

  hideActionHint() {
    return this.baseHandle.removeAttribute('action');
  }


  updateHandle(handle, x, y) {
    if (handle == null) { handle = this.baseHandle; }
    if (x == null) { ({ x } = this); }
    if (y == null) { ({ y } = this); }
    if (handle === undefined) { return; }

    // Since Point objects actually affect the data for Paths but they always
    // need to be the same size on the UI, their zoom behavior
    // falls in the annotation category. (#1)
    //
    // That means we need to scale its UI rep without actually affecting
    // the source of its coordinates. In this case, we simply scale the
    // left and top attributes of the DOM point handle.

    handle.style.left = x * ui.canvas.zoom;
    handle.style.top = y * ui.canvas.zoom;
    return this;
  }


  inheritPosition(from) {
    // Maintain linked-list order in a PointsList
    this.at         = from.at;
    this.prec       = from.prec;
    this.succ       = from.succ;
    this.prec.succ  = this;
    this.succ.prec  = this;
    this.owner      = from.owner;
    if (from.baseHandle != null) { this.baseHandle = from.baseHandle; }
    return this;
  }



  nudge(x, y, checkForFirstOrLast) {
    if (checkForFirstOrLast == null) { checkForFirstOrLast = true; }
    let old = this.clone();
    super.nudge(x, y);
    if (this.antlers != null) {
      this.antlers.nudge(x, y);
    }
    this.updateHandle();

    if (this.owner.type === 'path') {
      if (checkForFirstOrLast && this.owner.points.closed) {
        // Check if this is the point overlapping the original MoveTo.
        if ((this === this.owner.points.first) && this.owner.points.last.equal(old)) {
          return this.owner.points.last.nudge(x, y, false);
        } else if ((this === this.owner.points.last) && this.owner.points.first.equal(old)) {
          return this.owner.points.first.nudge(x, y, false);
        }
      }
    }
  }


  rotate(a, origin) {
    super.rotate(a, origin);
    if (this.antlers != null) {
      this.antlers.rotate(a, origin);
    }
    return this.updateHandle();
  }


  scale(x, y, origin, angle) {
    super.scale(x, y, origin, angle);
    if (this.antlers != null) {
      this.antlers.scale(x, y, origin, angle);
    }
    this.updateHandle();
    return this;
  }


  replaceWith(point) {
    return this.owner.points.replace(this, point);
  }


  toPosn() {
    return new Posn(this.x, this.y);
  }


  toLineSegment() {
    return new LineSegment(this.prec, this);
  }


  /*

    Linked list action

  */

  setSucc(succ) {
    this.succ = succ;
    return succ.prec = this;
  }

  setPrec(prec) {
    return prec.setSucc(this);
  }


  /*

   Visibility functions for the UI

  */

  show() {
    if ((this.baseHandle == null)) { return; }
    if (!this.baseHandle) {
      this.draw();
    }
    this.baseHandle.style.display = 'block';
    return this.baseHandle.style.opacity = 1;
  }


  hide(force) {
    if (force == null) { force = false; }
    if ((this.baseHandle == null)) { return; }
    if (!this.baseHandle.hasAttribute('selected') || force) {
      this.baseHandle.style.opacity = 0;
      this.baseHandle.removeAttribute('action');
      this.hideHandles();
      return this.unhover();
    }
  }


  hover() {
    if (this.baseHandle != null) {
      this.baseHandle.setAttribute('hover', '');
    }
    if ((this.baseHandle == null)) { console.log("base handle missing"); }

    if (this.at === 0) {
      return this.owner.points.last.baseHandle.setAttribute('hover', '');
    } else if (this === this.owner.points.last) {
      return this.owner.points.first.baseHandle.setAttribute('hover', '');
    }
  }


  unhover() {
    return (this.baseHandle != null ? this.baseHandle.removeAttribute('hover') : undefined);
  }


  clear() {
    this.baseHandle.style.display = 'none';
    return this;
  }


  unclear() {
    this.baseHandle.style.display = 'block';
    return this;
  }


  remove() {
    if (this.antlers != null) {
      this.antlers.hide();
    }
    return (this.baseHandle != null ? this.baseHandle.remove() : undefined);
  }


  toStringWithZoom() {
    this.multiplyByMutable(ui.canvas.zoom);
    let str = this.toString();
    this.multiplyByMutable((1 / ui.canvas.zoom));
    return str;
  }

  flag(flag) { return this._flags.ensure(flag); }

  unflag(flag) { return this._flags.remove(flag); }

  flagged(flag) { return this._flags.has(flag); }

  annotate(color, radius) {
    return ui.annotations.drawDot(this, color, radius);
  }
}
Point.initClass();


import ui from 'script/ui/ui';
import setup from 'script/setup';
import Posn from 'script/geometry/posn';
import LineSegment from 'script/geometry/line-segment';
/*

  UI selected elements transformer

*/


ui.transformer = {


  angle: 0,


  resetAccum() {
    this.accumX = 1.0;
    this.accumY = 1.0;
    this.accumA = 0.0;
    this.origin = undefined;
    return this;
  },


  hide() {
    return (() => {
      let result = [];
      for (let i of Object.keys(this.reps || {})) {
        let r = this.reps[i];
        result.push(r.style.display = "none");
      }
      return result;
    })();
  },


  show() {
    this.resetAccum();
    return (() => {
      let result = [];
      for (let i of Object.keys(this.reps || {})) {
        let r = this.reps[i];
        result.push(r.style.display = "block");
      }
      return result;
    })();
  },


  center() {
    return new LineSegment(this.tl, this.br).midPoint();
  },


  refresh() {

    this.deriveCorners(ui.selection.elements.all); // Just to get the center

    let center = this.center();

    if (ui.selection.elements.all.length === 0) {
      return this.hide();
    } else {
      this.show();
    }

    let angles = new Set(ui.selection.elements.all.map(elem => elem.metadata.angle));

    if (angles.length === 1) {
      this.angle = parseFloat(angles[0]);
    } else {
      ui.selection.elements.all.map(elem => elem.metadata.angle = 0);
    }

    for (var elem of Array.from(ui.selection.elements.all)) {
      if (this.angle !== 0) {
        elem.rotate(360 - this.angle, center);
        elem.clearCachedObjects();
      }
      elem.clearCachedObjects();
      elem.lineSegments();
    }

    this.deriveCorners(ui.selection.elements.all);

    if (this.angle !== 0) {
      for (elem of Array.from(ui.selection.elements.all)) {
        elem.rotate(this.angle, center);
      }
      let toAngle = this.angle;
      this.angle = 0;
      this.rotate(toAngle, center);
    }

    this.redraw();

    return this;
  },

  deriveCorners(shapes) {
    if (shapes.length > 0) debugger;
    let elem;
    if (shapes.length === 0) {
      this.tl = (this.tr = (this.br = (this.bl = new Posn(0, 0))));
      this.width = (this.height = 0);
      return;
    }

    let xRanges = ((() => {
      let result = [];
      for (elem of Array.from(shapes)) {         result.push(elem.xRange());
      }
      return result;
    })());
    let yRanges = ((() => {
      let result1 = [];
      for (elem of Array.from(shapes)) {         result1.push(elem.yRange());
      }
      return result1;
    })());

    let getMin = function(rs) { return Math.min.apply(this, rs.map(a => a.min)); };
    let getMax = function(rs) { return Math.max.apply(this, rs.map(a => a.max)); };

    let xMin = getMin(xRanges);
    let xMax = getMax(xRanges);
    let yMin = getMin(yRanges);
    let yMax = getMax(yRanges);

    this.tl = new Posn(xMin, yMin);
    this.tr = new Posn(xMax, yMin);
    this.br = new Posn(xMax, yMax);
    this.bl = new Posn(xMin, yMax);

    this.lc = new Posn(xMin, yMin + ((yMax - yMin) / 2));
    this.rc = new Posn(xMax, yMin + ((yMax - yMin) / 2));
    this.tc = new Posn(xMin + ((xMax - xMin) / 2), yMin);
    this.bc = new Posn(xMin + ((xMax - xMin) / 2), yMax);

    this.width = xMax - xMin;
    this.height = yMax - yMin;

    if (this.width === 0) {
      this.width = 1;
    }
    if (this.height === 0) {
      return this.height = 1;
    }
  },


  pixelToFloat(amt, length) {
    if (amt === 0) { return 1; }
    return 1 + (amt / length);
  },


  redraw() {

    if (ui.selection.elements.all.length === 0) {
      return this.hide();
    }

    let tl = this.correctAngle(this.tl);

    let zl = ui.canvas.zoom;

    let center = this.center().zoomed();

    // This is so fucking ugly I'm sorry

    for (let corner of ["tl", "tr", "br", "bl", "tc", "rc", "bc", "lc"]) {
      let cp = this[corner].zoomedc();
      this.reps[corner].style.left = Math.floor(cp.x, 10);
      this.reps[corner].style.top = Math.floor(cp.y, 10);
      this.reps[corner].style.WebkitTransform = `rotate(${this.angle}deg)`;
      this.reps[corner].style.MozTransform = `rotate(${this.angle}deg)`;
    }

    this.reps.outline.style.width = `${Math.ceil(this.width * zl, 10)}px`;
    this.reps.outline.style.height = `${Math.ceil(this.height * zl, 10)}px`;

    tl.zoomed();

    this.reps.outline.style.left = `${Math.floor(tl.x, 10)}px`;
    this.reps.outline.style.top = `${Math.floor(tl.y, 10)}px`;
    this.reps.outline.style.WebkitTransform = `rotate(${this.angle}deg)`;
    this.reps.outline.style.MozTransform = `rotate(${this.angle}deg)`;

    this.reps.c.style.left = `${Math.ceil(center.x, 10)}px`;
    this.reps.c.style.top = `${Math.ceil(center.y, 10)}px`;

    return this;
  },


  correctAngle(p) {
    return p.clone().rotate(360 - this.angle, this.center());
  },


  drag(e) {
    let opposites;
    let change = {
      x: 0,
      y: 0
    };

    let center = this.center();

    // Just for readability's sake...
    let cursor = e.canvasPosnZoomed.clone().rotate(360 - this.angle, center);

    // This will be "tl"|"top"|"tr"|"right"|"br"|"bottom"|"bl"|"left"
    let direction = e.target.className.replace('transform handle ', '').split(' ')[1];

    let origins = {
      tl:     this.br,
      tr:     this.bl,
      br:     this.tl,
      bl:     this.tr,
      top:    this.bc,
      right:  this.lc,
      bottom: this.tc,
      left:   this.rc
    };

    let origin = origins[direction];

    // Change x
    if (["tr", "right", "br"].has(direction)) {
      change.x = cursor.x - this.correctAngle(this.rc).x;
    }
    if (["tl", "left", "bl"].has(direction)) {
      change.x = this.correctAngle(this.lc).x - cursor.x;
    }

    // Change y
    if (["tl", "top", "tr"].has(direction)) {
      change.y = this.correctAngle(this.tc).y - cursor.y;
    }
    if (["bl", "bottom", "br"].has(direction)) {
      change.y = cursor.y - this.correctAngle(this.bc).y;
    }

    let x = this.pixelToFloat(change.x, this.width);
    let y = this.pixelToFloat(change.y, this.height);

    // Flipping logic

    if (x < 0) {
      // Flip it horizontally
      opposites = {
        tl:     this.reps.tr,
        tr:     this.reps.tl,
        br:     this.reps.bl,
        bl:     this.reps.br,
        top:    this.reps.bc,
        right:  this.reps.lc,
        bottom: this.reps.tc,
        left:   this.reps.rc
      };

      ui.cursor.lastDownTarget = opposites[direction];
      switch (direction) {
        case "left": case "bl": case "tl":
          return this._flipOver("R");
          break;
        case "right": case "br": case "tr":
          return this._flipOver("L");
          break;
      }
    }

    if (y < 0) {
      opposites = {
        tl:     this.reps.bl,
        tr:     this.reps.br,
        br:     this.reps.tr,
        bl:     this.reps.tl,
        top:    this.reps.bc,
        right:  this.reps.lc,
        bottom: this.reps.tc,
        left:   this.reps.rc
      };

      ui.cursor.lastDownTarget = opposites[direction];
      switch (direction) {
        case "bottom": case "bl": case "br":
          return this._flipOver("T");
          break;
        case "top": case "tl": case "tr":
          return this._flipOver("B");
          break;
      }
    }

    if (ui.hotkeys.modifiersDown.has("shift")) {
      // Constrain proportions
      if (direction[0] === "side") {
        if (x === 1) {
          x = y;
        } else if (y === 1) {
          y = x;
        }
      }
      if (x < y) {
        y = x;
      } else { x = y; }
    }

    if (ui.hotkeys.modifiersDown.has("alt")) {
      // Scale around the center
      origin = center;
      x = x * x;
      y = y * y;
    }

    x = x.ensureRealNumber();
    y = y.ensureRealNumber();

    x = Math.max(1e-5, x);
    y = Math.max(1e-5, y);

    this.scale(x, y, origin);
    this.redraw();

    return ui.selection.scale(x, y, origin);
  },


  clonedPosns() {
    return [this.tl, this.tc, this.tr, this.rc, this.br, this.bc, this.bl, this.lc].map(p => p.clone());
  },


  _flipOver(side) {
    // side
    //   either "T", "R", "B", "L"

    let [tl, tc, tr, rc, br, bc, bl, lc] = Array.from(this.clonedPosns());

    switch (side) {
      case "T":
        this.tl = this.bl.reflect(tl);
        this.tc = this.bc.reflect(tc);
        this.tr = this.br.reflect(tr);

        this.rc = this.rc.reflect(tr);
        this.lc = this.lc.reflect(tl);

        this.bc = tc;
        this.bl = tl;
        this.br = tr;

        ui.selection.scale(1, -1, this.bc);
        break;

      case "B":
        this.bl = this.tl.reflect(bl);
        this.bc = this.tc.reflect(bc);
        this.br = this.tr.reflect(br);

        this.rc = this.rc.reflect(br);
        this.lc = this.lc.reflect(bl);

        this.tc = bc;
        this.tl = bl;
        this.tr = br;

        ui.selection.scale(1, -1, this.tc);
        break;

      case "L":
        this.tl = this.tr.reflect(tl);
        this.lc = this.rc.reflect(lc);
        this.bl = this.br.reflect(bl);

        this.tc = this.tc.reflect(tl);
        this.bc = this.bc.reflect(bl);

        this.rc = lc;
        this.br = bl;
        this.tr = tl;

        ui.selection.scale(-1, 1, this.rc);
        break;

      case "R":
        this.tr = this.tl.reflect(tr);
        this.rc = this.lc.reflect(rc);
        this.br = this.bl.reflect(br);

        this.tc = this.tc.reflect(tr);
        this.bc = this.bc.reflect(br);

        this.lc = rc;
        this.bl = br;
        this.tl = tr;

        ui.selection.scale(-1, 1, this.lc);
        break;
    }

    return this.redraw();
  },


  flipOriginHorizontally(o) {
    switch (o) {
      case this.tl:
        return this.tr;
      case this.tr:
        return this.tl;
      case this.br:
        return this.bl;
      case this.bl:
        return this.br;
      case this.rc:
        return this.lc;
      case this.lc:
        return this.rc;
    }
  },

  flipOriginVertically(o) {
    switch (o) {
      case this.tl:
        return this.tr;
      case this.tr:
        return this.tl;
      case this.br:
        return this.bl;
      case this.bl:
        return this.br;
      case this.rc:
        return this.lc;
      case this.lc:
        return this.rc;
    }
  },

  scale(x, y, origin) {
    // I/P:
    //   y: Float
    //   origin: Posn

    this.origin = origin;
    let center = this.center();

    for (let p of Array.from(this.pointsToScale(this.origin))) {
      if (this.angle !== 0) { p.rotate(360 - this.angle, center); }
      p.scale(x, y, this.origin.clone().rotate(360 - this.angle, center));
      if (this.angle !== 0) { p.rotate(this.angle, center); }
    }
    this;

    this.width *= x;
    this.height *= y;

    if (this.width === 0) {
      this.width = 1;
    }
    if (this.height === 0) {
      this.height = 1;
    }

    this.accumX *= x;
    this.accumY *= y;

    return this;
  },


  pointsToScale(origin) {
    switch (origin) {
      case this.tc: return [this.bl, this.bc, this.br, this.rc, this.lc];
      case this.rc: return [this.bl, this.lc, this.tl, this.tc, this.bc];
      case this.bc: return [this.tl, this.tc, this.tr, this.rc, this.lc];
      case this.lc: return [this.br, this.rc, this.tr, this.bc, this.tc];
      case this.tl: return [this.tr, this.br, this.bl, this.tc, this.rc, this.bc, this.lc];
      case this.tr: return [this.tl, this.br, this.bl, this.tc, this.rc, this.bc, this.lc];
      case this.br: return [this.tl, this.tr, this.bl, this.tc, this.rc, this.bc, this.lc];
      case this.bl: return [this.tl, this.tr, this.br, this.tc, this.rc, this.bc, this.lc];
      default: return [this.tl, this.tr, this.br, this.bl, this.tc, this.rc, this.bc, this.lc];
    }
  },


  nudge(x, y) {
    for (let p of [this.tl, this.tr, this.br, this.bl, this.tc, this.rc, this.bc, this.lc]) {
      p.nudge(x, -y);
    }
    return this;
  },

  rotate(a, origin) {
    this.origin = origin;
    this.angle += a;
    this.angle %= 360;

    this.accumA += a;
    this.accumA %= 360;

    for (let p of [this.tl, this.tr, this.br, this.bl, this.tc, this.rc, this.bc, this.lc]) {
      p.rotate(a, this.origin);
    }
    return this;
  },


  setup() {
    this.resetAccum();
    return this.reps = {
      tl: q("#trfm-tl"),
      tr: q("#trfm-tr"),
      br: q("#trfm-br"),
      bl: q("#trfm-bl"),
      tc: q("#trfm-tc"),
      rc: q("#trfm-rc"),
      bc: q("#trfm-bc"),
      lc: q("#trfm-lc"),
      c:  q("#trfm-c"),
      outline: q("#trfm-outline")
    };
  },


  tl: new Posn(0,0),
  tr: new Posn(0,0),
  br: new Posn(0,0),
  bl: new Posn(0,0),
  tc: new Posn(0,0),
  rc: new Posn(0,0),
  bc: new Posn(0,0),
  lc: new Posn(0,0),

  onRotatingMode() {
    return $(this.reps.c).hide();
  },

  offRotatingMode() {
    if (ui.selection.elements.all.length === 0) { return; }
    return $(this.reps.c).show();
  }
};


setup.push(() => ui.transformer.setup());

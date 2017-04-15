import Posn from 'script/geometry/posn';

export default class Bounds {

  constructor(x1, y1, width, height) {
    let x, y;
    this.x = x1;
    this.y = y1;
    this.width = width;
    this.height = height;
    if (this.x instanceof Array) {
      // A list of bounds
      let minX = Math.min.apply(this, this.x.map(b => b.x));
      this.y   = Math.min.apply(this, this.x.map(b => b.y));
      this.x2  = Math.max.apply(this, this.x.map(b => b.x2));
      this.y2  = Math.max.apply(this, this.x.map(b => b.y2));
      this.x   = minX;
      this.width  = this.x2 - this.x;
      this.height = this.y2 - this.y;


    } else if (this.x instanceof Posn && this.y instanceof Posn) {
      // A pair of posns

      x = Math.min(this.x.x, this.y.x);
      y = Math.min(this.x.y, this.y.y);
      this.x2 = Math.max(this.x.x, this.y.x);
      this.y2 = Math.max(this.x.y, this.y.y);
      this.x = x;
      this.y = y;
      this.width = this.x2 - this.x;
      this.height = this.y2 - this.y;

    } else {
      this.x2 = this.x + this.width;
      this.y2 = this.y + this.height;
    }

    this.xr = new Range(this.x, this.x + this.width);
    this.yr = new Range(this.y, this.y + this.height);
  }

  tl() { return new Posn(this.x, this.y); }
  tr() { return new Posn(this.x2, this.y); }
  br() { return new Posn(this.x2, this.y2); }
  bl() { return new Posn(this.x, this.y2); }

  clone() { return new Bounds(this.x, this.y, this.width, this.height); }

  toRect() {
    return new Rect({
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height
    });
  }

  center() {
    return new Posn(this.x + (this.width / 2), this.y + (this.height / 2));
  }

  points() { return [new Posn(this.x, this.y), new Posn(this.x2, this.y), new Posn(this.x2, this.y2), new Posn(this.x, this.y2)]; }

  contains(posn, tolerance) {
    return this.xr.containsInclusive(posn.x, tolerance) && this.yr.containsInclusive(posn.y, tolerance);
  }

  overlapsBounds(other, recur) {
    if (recur == null) { recur = true; }
    return this.toRect().overlaps(other.toRect());
  }

  nudge(x, y) {
    this.x += x;
    this.x2 += x;
    this.y += y;
    this.y2 += y;
    this.xr.nudge(x);
    return this.yr.nudge(y);
  }

  scale(x, y, origin) {
    let tl = new Posn(this.x, this.y);
    let br = new Posn(this.x2, this.y2);
    tl.scale(x, y, origin);
    br.scale(x, y, origin);

    this.x = tl.x;
    this.y = tl.y;
    this.x2 = br.x;
    this.y2 = br.y;

    this.width *= x;
    this.height *= y;

    this.xr.scale(x, origin);
    this.yr.scale(y, origin);

    return this;
  }

  squareSmaller(anchor) {
    if (this.width < this.height) {
      return this.height = this.width;
    } else {
      return this.width = this.height;
    }
  }

  centerOn(posn) {
    let offset = posn.subtract(this.center());
    return this.nudge(offset.x, offset.y);
  }

  fitTo(bounds) {
    let sw = this.width / bounds.width;
    let sh = this.height / bounds.height;
    let sm = Math.max(sw, sh);
    return new Bounds(0, 0, this.width / sm, this.height / sm);
  }


  adjustElemsTo(bounds) {
    // Returns a method that can run on Monsvg objects
    // that will nudge and scale them so they go from these bounds
    // to look proportionately the same in the given bounds.
    let offset = this.tl().subtract(bounds.tl());
    let sw = this.width / bounds.width;
    let sh = this.height / bounds.height;
    // Return a function that will adjust a given element to the canvas
    return function(elem) {
      elem.scale(1/sw, 1/sh, bounds.tl());
      return elem.nudge(-offset.x, offset.y);
    };
  }

  annotateCorners() {
    ui.annotations.drawDot(this.tl());
    ui.annotations.drawDot(this.tr());
    ui.annotations.drawDot(this.bl());
    return ui.annotations.drawDot(this.br());
  }
}


import Monsvg from 'script/geometry/monsvg'
import Range from 'script/geometry/range'

/*

  Ellipse

*/


class Ellipse extends Monsvg {
  static initClass() {
    this.prototype.type = 'ellipse';
  }


  constructor(data) {
    this.data = data;
    super(this.data);

    this.data.cx = parseFloat(this.data.cx);
    this.data.cy = parseFloat(this.data.cy);
    this.data.rx = parseFloat(this.data.rx);
    this.data.ry = parseFloat(this.data.ry);
  }


  xRange() {
    return new Range(this.data.cx - this.data.rx, this.data.cx + this.data.rx);
  }


  yRange() {
    return new Range(this.data.cy - this.data.ry, this.data.cy + this.data.ry);
  }


  c() {
    return new Posn(this.data.cx, this.data.cy);
  }


  top() {
    return new Posn(this.data.cx, this.data.cy - this.data.ry);
  }


  right() {
    return new Posn(this.data.cx + this.data.rx, this.data.cy);
  }


  bottom() {
    return new Posn(this.data.cx, this.data.cy + this.data.ry);
  }


  left() {
    return new Posn(this.data.cx - this.data.rx, this.data.cy);
  }


  overlapsRect(r) {
    for (let l of Array.from(r.lineSegments())) {
      if ((l.intersectionWithEllipse(this)) instanceof Array) {
        return true;
      }
    }
  }


  nudge(x, y) {
    this.data.cx += x;
    this.data.cy -= y;
    return this.commit();
  }


  scale(x, y, origin) {
    let c = this.c().scale(x, y, origin);
    this.data.cx = c.x;
    this.data.cy = c.y;
    this.data.rx *= x;
    this.data.ry *= y;
    return this.commit();
  }


  convertToPath() {
    let p = new Path({
      d: `M${this.data.cx},${this.data.cy - this.data.ry}`});

    p.eyedropper(this);

    let top = this.top();
    let right = this.right();
    let bottom = this.bottom();
    let left = this.left();

    let { rx } = this.data;
    let { ry } = this.data;

    let ky = Math.KAPPA * ry;
    let kx = Math.KAPPA * rx;

    p.points.push(new CurveTo(top.x + kx, top.y, right.x, right.y - ky, right.x, right.y));
    p.points.push(new CurveTo(right.x, right.y + ky, bottom.x + kx, bottom.y, bottom.x, bottom.y));
    p.points.push(new CurveTo(bottom.x - kx, bottom.y, left.x, left.y + ky, left.x, left.y));
    p.points.push(new CurveTo(left.x, left.y - ky, top.x - kx, top.y, top.x, top.y));
    p.points.close();
    p.points.drawBasePoints();

    p.updateDataArchived();

    return p;
  }
}
Ellipse.initClass();



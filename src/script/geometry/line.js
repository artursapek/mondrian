import Monsvg from 'script/geometry/monsvg'
import Range from 'script/geometry/range'

/*

  Line

*/


class Line extends Monsvg {
  static initClass() {
    this.prototype.type = 'line';
  }


  a() {
    return new Posn(this.data.x1, this.data.y1);
  }


  b() {
    return new Posn(this.data.x2, this.data.y2);
  }


  absorbA(a) {
    this.data.x1 = a.x;
    return this.data.y1 = a.y;
  }


  absorbB(b) {
    this.data.x2 = b.x;
    return this.data.y2 = b.y;
  }


  asLineSegment() {
    return new LineSegment(this.a(), this.b());
  }


  fromLineSegment(ls) {

    // Inherit points from a LineSegment
    //
    // I/P : LineSegment
    //
    // O/P : self

    this.absorbA(ls.a);
    return this.absorbB(ls.b);
  }


  xRange() { return this.asLineSegment().xRange(); }


  yRange() { return this.asLineSegment().yRange(); }


  nudge(x, y) {
    this.data.x1 += x;
    this.data.x2 += x;
    this.data.y1 -= y;
    this.data.y2 -= y;
    return this.commit();
  }


  scale(x, y, origin) {
    this.absorbA(this.a().scale(x, y, origin));
    this.absorbB(this.b().scale(x, y, origin));
    return this.commit();
  }


  overlapsRect(rect) {
    let ls = this.asLineSegment();

    if (this.a().insideOf(rect)) { return true; }
    if (this.b().insideOf(rect)) { return true; }

    for (let l of Array.from(rect.lineSegments())) {
      if (l.intersects(ls)) { return true; }
    }
    return false;
  }
}
Line.initClass();





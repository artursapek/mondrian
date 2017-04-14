import LineSegment from 'script/geometry/line-segment';

class Ray extends LineSegment {

  constructor(a, angle) {
    // subclass of LineSegment
    // Just makes a LineSegment that's insanely long lol
    //
    // I/P:
    //   a: Posn
    //   angle: number from 0 to 360
    this.a = a;
    this.angle = angle;
    super(this.a, this.a.clone().nudge(0, -1e5).rotate(this.angle, this.a));
  }
}



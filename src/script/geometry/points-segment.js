import {
  PathPoint,
  MoveTo,
  LineTo,
  HorizTo,
  VertiTo,
  CurveTo,
  SmoothTo,
} from 'script/geometry/point';
/*

  PointsSegment

  A segment of points that starts with a MoveTo.
  A PointsList is composed of a list of these.

*/


export default class PointsSegment {
  constructor(points, list) {
    this.points = points;
    this.list = list;
    this.startsAt = this.points.length !== 0 ? this.points[0].at : 0;

    if (this.list != null) {
      this.owner = this.list.owner;
    }

    if (this.points[0] instanceof MoveTo) {
      this.moveTo = this.points[0];
    }

    this.points.forEach(p => {
      return p.segment = this;
    });

    this;
  }


  insert(point, at) {
    let head = this.points.slice(0, at);
    let tail = this.points.slice(at);

    if (point instanceof Array) {
      tail.forEach(p => p.at += point.length);

      return head = head.concat(point);

    } else if (point instanceof Point) {
      tail.forEach(p => p.at += 1);

      head[head.length - 1].setSucc(point);
      tail[0].setPrec(point);

      return head.push(point);



    } else {
      throw new Error(`PointsList: don't know how to insert ${point}.`);
    }
  }



  toString() {
    return this.points.join(' ');
  }


  at(n) {
    return this.points[n - this.startsAt];
  }


  remove(x) {
    // Relink things
    x.prec.succ = x.succ;
    x.succ.prec = x.prec;
    if (x === this.list.last) {
      this.list.last = x.prec;
    }
    if (x === this.list.first) {
      this.list.first = x.succ;
    }
    this.points = this.points.remove(x);

    // Remove it from the canvas if it's there
    return x.remove();
  }


  movePointToFront(point) {
    if (!(this.points.has(point))) { return; }

    this.removeMoveTo();
    this.points = this.points.cannibalizeUntil(point);
    return this;
  }


  moveMoveTo(otherPoint) {
    let segment;
    let tail = this.points.slice(1);

    for (let i = 0, end = otherPoint.at - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
      segment = segment.cannibalize();
    }

    this.moveTo.copy(otherPoint);

    return this.points = [this.moveTo].concat(segment);
  }


  replace(old, replacement) {
    if (replacement instanceof Point) {
      replacement.inheritPosition(old);
      this.points = this.points.replace(old, replacement);

    } else if (replacement instanceof Array) {
      let replen = replacement.length;
      let { at } = old;
      let { prec } = old;
      let { succ } = old;
      old.succ.prec = replacement[replen - 1];
      // Sus
      for (let np of Array.from(replacement)) {
        np.owner = this.owner;

        np.at = at;
        np.prec = prec;
        np.succ = succ;
        prec.succ = np;
        prec = np;
        at += 1;
      }

      this.points = this.points.replace(old, replacement);

      for (let p of Array.from(this.points.slice(at))) {
        p.at += (replen - 1);
      }
    }

    return replacement;
  }

  validateLinks() {
    // Sortova debug tool <3
    console.log(this.points.map(p => `${p.prec.at} ${p.at} ${p.succ.at}`));
    let prev = this.points.length - 1;
    for (let i of Object.keys(this.points || {})) {
      let p = this.points[i];
      i = parseInt(i, 10);
      if (!(p.prec === this.points[prev])) {
        console.log(p, "prec wrong. Expecting", prev);
        debugger;
        return false;
        break;
      }
      let succ = i === (this.points.length - 1) ? 0 : i + 1;
      if (!(p.succ === this.points[succ])) {
        console.log(p, "succ wrong");
        return false;
        break;
      }
      prev = i;
    }

    return true;
  }


  // THIS IS FUCKED UP
  reverse() {
    this.removeMoveTo();

    let positions = [];
    let stack = [];

    for (let index of Object.keys(this.points || {})) {
      let point = this.points[index];
      stack.push(point);
      positions.push({
        x: point.x,
        y: point.y
      });
    }

    let tailRev = stack.slice(1).reverse().map(p => p instanceof CurvePoint ? p.reverse() : p);

    positions = positions.reverse();

    stack = stack.slice(0, 1).concat(tailRev);

    stack = stack.map(function(p, i) {
      let c = positions[0];
      p.x = c.x;
      p.y = c.y;

      // Relink: swap succ and prec
      let { succ } = p;
      p.succ = p.prec;
      p.prec = succ;

      p.at = i;
      // Cut the head off as we go, this should be faster than just going positions[i] ^_^
      positions = positions.slice(1);
      return p;
    });
    return new PointsSegment(stack, this.list);
  }


  removeMoveTo() {
    return this.points = this.points.filter(p => !(p instanceof MoveTo));
  }


  ensureMoveTo() {
    let lastPoint = this.points.last();
    let firstPoint = this.points.first();

    let moveTo = new MoveTo(lastPoint.x, lastPoint.y, lastPoint.owner, lastPoint);
    moveTo.at = 0;

    lastPoint.succ = (firstPoint.prec = moveTo);
    moveTo.succ = firstPoint;
    this.points.unshift(moveTo);

    return this;
  }
}




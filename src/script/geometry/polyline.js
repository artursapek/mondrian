import Polygon from 'script/geometry/polygon'

// Exactly like a polygon, but not closed

class Polyline extends Polygon {

  convertToPath() {
    let path = new Path({
      d: `M${this.points.at(0).x},${this.points.at(0).y}`
    });
    path.eyedropper(this);

    let old = path.points.at(0);
    for (let p of Array.from(this.points.all().slice(1))) {
      let lt = new LineTo(p.x, p.y, path, old, false);
      path.points.push(lt);
      old = lt;
    }

    return path;
  }
}



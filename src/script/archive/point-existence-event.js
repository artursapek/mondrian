/*

  PointExistenceEvent

*/

class PointExistenceEvent extends Event {
  constructor(ei, point, at) {
    // Given an elem's z-index and a point (index or value) this
    // acts just like the ExistenceEvent.
    //
    // elem: int - z-index of elem being affected
    //
    // point: int (for deletion) or string (for creation)
    //        The point we are changing.

    this.ei = ei;
    this.point = point;
    let elem = this.getElem();

    if (typeof this.point === "number") {
      // Deleting the point
      this.mode = "remove";
      this.point = elem.points.at(this.point);
      this.pointIndex = this.point;

    } else {
      this.mode = "create";

      if (typeof this.point === "string") {
        // Adding the point
        this.point = new Point(this.point);
      }

      if (at != null) {
        this.pointIndex = at;
      } else {
        this.pointIndex = elem.points.all().length - 1;
      }
    }
  }

  do() {
    if (this.mode === "remove") { return this.remove(); } else { return this.add(); }
  }

  undo() {
    if (this.mode === "remove") { return this.add(); } else { return this.remove(); }
  }

  getElem() { return queryElemByZIndex(this.ei); }

  add() {
    // Clone the point so our copy of the point can never be edited in the UI
    let clonedPoint = this.point.clone();

    let elem = this.getElem();
    elem.hidePoints();
    // Push it into the points linked list
    elem.points.push(clonedPoint);

    // If this point's coordinates are the same as the elem's first point's
    // but it's not actually the same point object
    if ((clonedPoint.equal(elem.points.first)) && !(clonedPoint === elem.points.first)) {
      //
      elem.points.close();
    }
    elem.commit();
    clonedPoint.draw();
    if (!archive.simulating) {
      ui.selection.elements.deselectAll();
      ui.selection.points.select(clonedPoint);
    }
    return this.getElem().redrawHoverTargets();
  }

  remove() {
    let elem = this.getElem();
    elem.points.remove(this.pointIndex);

    // Show the most recent point
    elem.hidePoints();
    if (!archive.simulating) {
      ui.selection.elements.deselectAll();
      ui.selection.points.select(elem.points.last);
    }
    return elem.commit();
  }

  toJSON() {
    return {
      t: `p:${ { "remove": "d", "create": "c" }[this.mode] }`,
      e: this.ei,
      p: this.point.toString(),
      i: this.pointIndex
    };
  }
}






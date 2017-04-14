/*

  Z-Index event

  Shift elements up or down in the z-axis

*/



class ZIndexEvent extends Event {
  constructor(indexesBefore, indexesAfter, direction) {

    this.indexesBefore = indexesBefore;
    this.indexesAfter = indexesAfter;
    this.direction = direction;
    let mf = e => e.moveForward();
    let mb = e => e.moveBack();
    let mff = e => e.bringToFront();
    let mbb = e => e.sendToBack();

    console.log(this.direction);

    switch (this.direction) {
      case "mf":
        this._do = mf;
        this._undo = mb;
        break;
      case "mb":
        this._do = mb;
        this._undo = mf;
        break;
      case "mff":
        this._do = mff;
        this._undo = mbb;
        break;
      case "mbb":
        this._do = mbb;
        this._undo = mff;
        break;
    }
  }

  do() {
    for (let index of Array.from(this.indexesBefore)) {
      this._do(queryElemByZIndex(index));
    }
    return ui.elements.sortByZIndex();
  }

  undo() {
    for (let index of Array.from(this.indexesAfter)) {
      this._undo(queryElemByZIndex(index));
    }
    return ui.elements.sortByZIndex();
  }

  toJSON() {
    return {
      t: "z",
      ib: this.indexesBefore,
      ia: this.indexesAfter,
      d: this.direction
    };
  }
}



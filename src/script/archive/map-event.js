/*


  MapEvent

  An efficient way to store a nudge, scale, or rotate
  of an entire shape's points


*/

class MapEvent extends Event {
  constructor(funKey, indexes, args) {
    // funKey: str, which method we're mapping
    //   "nudge"
    //   "scale"
    //   "rotate"
    //
    // indexes: array OR object
    //   if we're mapping on elements, an array of zindex numbers
    //   if we're mapping on points, an object where the keys are
    //   the element's zindex and the value is an array of point indexes
    //
    // args:
    //   args given to the method we're mapping
    //
    //   for nudge ("n")
    //     x: number
    //     y: number
    //
    //   for scale ("s")
    //     x: number
    //     y: number
    //     origin: posn
    //
    //   for rotate ("r")
    //     a: number
    //     origin: posn
    //

    // Determine whether this event happens to points or elements
    // This depends on if we're given input in the
    // form of [1,2,3,4] or { 4: [1,2,3,4] }
    this.funKey = funKey;
    this.indexes = indexes;
    this.args = args;
    this.operatingOn = this.indexes instanceof Array ? "elems" : "points";


    switch (this.funKey) {
      // Build the private undo and do map functions
      // that will get called on each member of elements

      case "nudge":
        this._undo = e => {
          return e.nudge(-this.args.x, -this.args.y, true);
        };
        this._do = e => {
          return e.nudge(this.args.x, this.args.y, true);
        };
        break;

      case "scale":
        // Damn NaN bugs
        this.args.x = Math.max(this.args.x, 1e-5);
        this.args.y = Math.max(this.args.y, 1e-5);

        this._undo = e => {
          return e.scale(1 / this.args.x, 1 / this.args.y, new Posn(this.args.origin));
        };
        this._do = e => {
          return e.scale(this.args.x, this.args.y, new Posn(this.args.origin));
        };
        break;

      case "rotate":
        this._undo = e => {
          return e.rotate(-this.args.angle, new Posn(this.args.origin));
        };
        this._do = e => {
          return e.rotate(this.args.angle, new Posn(this.args.origin));
        };
        break;
    }
  }


  undo() {
    return this._execute(this._undo);
  }

  do() {
    return this._execute(this._do);
  }

  _execute(method) {
    // method
    //   _do or _undo
    //
    // Abstraction on mapping over given elements of points

    let elem, index;
    if (this.operatingOn === "elems") {
      // Get elem at each index in @indexes
      // and run method on it
      if (!archive.simulating) {
        ui.selection.points.deselectAll();
        ui.selection.elements.deselectAll();
      }

      return (() => {
        let result = [];
        for (index of Array.from(this.indexes)) {
          elem = queryElemByZIndex(parseInt(index, 10));
          if (!archive.simulating) {
            ui.selection.elements.selectMore(elem);
          }
          method(elem);
          result.push(elem.redrawHoverTargets());
        }
        return result;
      })();


    } else {
      // Get elem for each key value and the list of point indexes for it
      // Then get the point in the elem for each point index and run the method on it
      return (() => {
        let result1 = [];
        for (index of Object.keys(this.indexes || {})) {
          let pointIndexes = this.indexes[index];
          elem = queryElemByZIndex(parseInt(index, 10));
          if (!archive.simulating) {
            ui.selection.elements.deselectAll();
            ui.selection.points.deselectAll();
          }
          for (let pointIndex of Array.from(pointIndexes)) {
            let point = elem.points.at(parseInt(pointIndex, 10));
            if (this.args.antler != null) {
              var newAngle, oldAngle;
              switch (this.args.antler) {
                case "p2":
                  if (point.antlers.succp2 != null) {
                    oldAngle = point.antlers.succp2.angle360(point);
                    method(point.antlers.succp2);
                    newAngle = point.antlers.succp2.angle360(point);

                    if (point.antlers.lockAngle) {
                      point.antlers.basep3.rotate(newAngle - oldAngle, point);
                    }

                    if (point.antlers.visible) { point.antlers.redraw(); }
                  } else {
                    console.log("wtf");
                  }
                  break;

                case "p3":
                  oldAngle = point.antlers.basep3.angle360(point);
                  method(point.antlers.basep3);
                  newAngle = point.antlers.basep3.angle360(point);

                  if (point.antlers.lockAngle) {
                    point.antlers.succp2.rotate(newAngle - oldAngle, point);
                  }

                  if (point.antlers.visible) { point.antlers.redraw(); }
                  break;
              }

              point.antlers.commit();
            } else {
              method(point);
            }
            if (!archive.simulating) {
              ui.selection.points.selectMore(point);
            }
          }
          elem.commit();
          result1.push(elem.redrawHoverTargets());
        }
        return result1;
      })();
    }
  }


  toJSON() {
    // t = type, "m:" = map:
    //   "n" = nudge, "s" = scale, "r" = rotate
    // i = z-indexes of elements mapping on
    // a = args
    return {
      t: `m:${ { nudge: "n", scale: "s", rotate: "r" }[this.funKey] }`,
      i: this.indexes,
      a: this.args
    };
  }
}


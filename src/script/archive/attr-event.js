/*

  AttrEvent

  Set the values of various attributes of various elements.
  Very flexible.

*/


class AttrEvent extends Event {
  constructor(indexes, changes, oldValues) {
    let attr, elem, i;
    this.indexes = indexes;
    this.changes = changes;
    this.oldValues = oldValues;
    super();
    // indexes: array of ints
    //          OR, when recreated from a serialized copy,
    // changes: an object where the keys
    //          are attrs and values are the values

    // If we were just given a single int as an index for
    // a single element, just put that into an array
    if (typeof this.indexes === "number") {
      this.indexes = [this.indexes];
    }

    // If we are just given a single attribute
    // just do the same thing as above.
    if (typeof this.changes === "string") {
      this.changes = [this.changes];
    }

    // So here's the deal. We can give this event lots of different inputs.
    // CASE 1: We can give it an array of attribute names.
    //
    //   ["fill", "stroke"]
    //
    // In this case it will set all of the elements to the same value:
    // the value held by the element at indexes[0].
    //
    // CASE 2: We can also give it an object of attributes and values.
    //
    //   {
    //     fill: "#FF0000"
    //     stroke: "#000000"
    //   }
    //
    // In this case it will assume nothing and use those values.
    //
    // CASE 3: We can also give it an object of objects of attributes and values.
    // The outer-most object is the indexes.
    //
    //   {
    //     2: {
    //       fill: "#CC00FF"
    //       stroke: "#000000"
    //     }
    //     6: {
    //       fill: "#DD0077"
    //       stroke: "#FFFFFF"
    //     }
    //   }
    //
    // In this case, we are actually assigning different values to different
    // elements. It's the ultimate level of micromanagement that we can do.
    //
    // When we serialize this, we keep changes in the form expected
    // for either CASE 2 or CASE 3. If we originally got CASE 1, we
    // will be saving it as CASE 2.

    let createOldValues = ((this.oldValues == null));

    // This object stores the old values for the undo
    if (createOldValues) {
      this.oldValues = {};
    }

    // Helper variable - just an array of the attr names we're changing
    // (to be defined). Ignored in CASE 3
    this.attrs = [];

    // This is true if we're in CASE 3. We will set this to true if
    // we detect that a few blocks down
    this.microManMode = false;

    if (this.changes instanceof Array) {
      // Array of attribute names. CASE 1.
      this.attrs = this.changes;
      this.changes = {};

      let firstElem = queryElemByZIndex(this.indexes[0]);
      // Sample the first elem for the assumed values
      for (attr of Array.from(this.attrs)) {
        this.changes[attr] = firstElem.data[attr].toString();
      }

      if (createOldValues) {
        // Save the old values for each of the elements for each of
        // the attrs we've defined
        for (i of Array.from(this.indexes)) {
          elem = queryElemByZIndex(i);
          this.oldValues[i] = {};
          for (attr of Array.from(this.attrs)) {
            this.oldValues[i][attr] = elem.dataArchived[attr].toString();
            elem.updateDataArchived(attr);
          }
        }
      }

    } else if (typeof this.changes === "object") {
      // Now we have to distinguish between CASEs 2 and 3

      let keys = Object.keys(this.changes);
      let numKeys = keys.filter(k => /\d+/gi.test(k));
      if (keys.length === numKeys.length) {
        // Oh shit! All the keys are digits, so this is CASE 3, where we
        // are assigning different values to different elements!
        this.microManMode = true;

        if (createOldValues) {
          // Since each element has its own attr/value object we don't
          // care about setting attrs anymore.
          for (i of Array.from(this.indexes)) {
            elem = queryElemByZIndex(i);
            this.oldValues[i] = {};
            for (attr of Object.keys(this.changes[i] || {})) {
              let _ = this.changes[i][attr];
              this.oldValues[i][attr] = elem.dataArchived[attr].toString();
              elem.updateDataArchived(attr);
            }
          }
        }

      } else {
        // Simply a key of attributes and values. CASE 2.

        // The attrs are the keys of @changes, so set that.
        this.attrs = Object.keys(this.changes);

        if (createOldValues) {
          for (i of Array.from(this.indexes)) {
            elem = queryElemByZIndex(i);
            this.oldValues[i] = {};
            for (attr of Array.from(this.attrs)) {
              this.oldValues[i][attr] = elem.dataArchived[attr].toString();
              elem.updateDataArchived(attr);
            }
          }
        }
      }
    }
  }



  do() {
    return this.applyValues(this.changes, this.microManMode);
  }

  undo() {
    return this.applyValues(this.oldValues, true);
  }

  applyValues(from, elemSpecific) {
    // An abstraction for do/undo. Sets the values from the object given.
    //
    // A note on elemSpecific:
    // This is always true when we are undoing, because this event always stores old
    // values seperately for each element. (If you change a blue and red circle both to be green,
    // you need to set each one back to blue or red individually)
    //
    // So @undo always calls this as true, because the input is a z-index -> attr -> value object
    // as opposed to just an attr -> value object like we have when this event is not called
    // with CASE 3 input. (See above)
    //
    // This is a bit confusing but it's effective.
    let attr, elem;
    return Array.from(this.indexes).map((i) =>
      ((elem = queryElemByZIndex(parseInt(i, 10))),

      elemSpecific ?
        (() => {
          let result = [];
          for (attr of Object.keys(from[i] || {})) {
            let val = from[i][attr];
            result.push(elem[`set${attr.camelCase().capitalize()}`](val));
          }
          return result;
        })()
      :
        (() => {
          let result1 = [];
          for (attr of Array.from(this.attrs)) {
            result1.push(elem[`set${attr.camelCase().capitalize()}`](from[attr]));
          }
          return result1;
        })(),

      elem.commit()));
  }


  toJSON() {
    return {
      t: "a",
      i: this.indexes,
      c: this.changes,
      o: this.oldValues
    };
  }
}


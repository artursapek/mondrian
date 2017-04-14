/*

  ExistenceEvent

  Created when a new element is created, or an element is deleted.
  Create and deletes elements in either direction for do/undo.
  Capable of handling many elements in one event.

*/

class ExistenceEvent extends Event {
  constructor(elem) {
    // Given elem, which can be either
    //
    //   int or array of ints:
    //     we're deleting the elem(s) at the z-index(s)
    //
    //   an SVG element or array of SVG elements:
    //     we're creating the element(s) at the highest z-index
    //     IN THE ORDER IN WHICH THEY APPEAR
    //
    // IMPORTANT: This should be called AFTER the element has actually been created


    // What we want to end up with is an object that looks like this:
    // {
    //   4: "<path d=\"....\"></path>"
    //   7: "<ellipse cx=\"...\"></ellipse>"
    // }
    //
    // And we need to save a @mode ("create" or "delete") that says which should
    // happen on DO. The opposite happens on UNDO. They are opposites after all.

    let e;
    this.args = {};

    if ((elem instanceof Object) && !(elem instanceof Array)) {
      // If it's an object, it might just be a set of args
      // from a serialized copy of this event, so let's check
      // if it is.
      let keys = Object.keys(elem);
      let numberKeys = keys.filter(k => k.match(/^[\d]*$/gi) !== null);
      if (keys.length === numberKeys.length) {
        // All the keys are just strings of digits,
        // so this is a previously serialized version of this event.
        this.args = elem;
        return this;
      }
    }

    // Check if elem is a number
    if (typeof elem === "number") {
      // Get the element at that z-index. We're deleting it.
      e = __guard__(queryElemByZIndex(elem), x => x.repToString());
      if (e != null) {
        this.args[elem] = this.cleanUpStringElem(e);
        this.mode = "delete";
      } else {
        ui.selection.elements.all.map(e => e.delete());
        return;
      }

    } else if (!(elem instanceof Array)) {
      // Must be a string or DOM element now

      // If it's a DOM element, serialize it to a string
      if (isSVGElement(elem)) {
        elem = new XMLSerializer().serializeToString(elem);
      }

      // We're creating it, at the newest z-index.
      // Since we're just creating one this is simple.
      this.args[ui.elements.length - 1] = this.cleanUpStringElem(elem);
      this.mode = "create";

    // Otherwise it must be an array, so do the same thing as above but with for-loops
    } else {
      // All the same checks
      if (typeof elem[0] === "number") {
        // Add many zindexes and query the element at that index every time
        for (let ind of Array.from(elem)) {
          e = __guard__(queryElemByZIndex(elem), x1 => x1.repToString());
          if (e != null) {
            this.args[ind] = this.cleanUpStringElem(e);
            this.mode = "delete";
          } else {
            ui.selection.elements.all.map(e => e.delete());
            return;
          }
        }

        this.mode = "delete";

      } else {
        // Must be strings or DOM elements now

        // If it's DOM elements, turn them all into strings
        let onCanvasAlready;
        if (isSVGElement(elem[0])) {
          onCanvasAlready = !!elem[0].parentNode;
          let serializer = new XMLSerializer();
          elem = elem.map(e => serializer.serializeToString(e));
        }

        // Increment new z-indexes starting at the first available one
        // Add the elements to args in the order in which they appear,
        // under the incrementing z-indexes

        // If they're already on the canvas
        let newIndex = ui.elements.length;

        if (onCanvasAlready) {
          newIndex -= elem.length;
        }

        for (e of Array.from(elem)) {
          this.args[newIndex] = this.cleanUpStringElem(e);
          ++ newIndex;
        }
        this.mode = "create";
      }
    }
  }


  cleanUpStringElem(s) {
    // Get rid of that shit we don't like
    s = s.replace(/uuid\=\"\w*\"/gi, "");
    return s;
  }


  draw() {
    // For each element in args, parse it and append it
    return (() => {
      let result = [];
      for (var index of Object.keys(this.args || {})) {
        let elem = this.args[index];
        let item;
        index = parseInt(index, 10);
        var parsed = io.parseElement($(elem));
        parsed.appendTo("#main");
        if (!archive.simulating) {
          ui.selection.elements.deselectAll();
          ui.selection.elements.select([parsed]);
        }
        var zi = parsed.zIndex();
        // Then adjust its z-index
        if (zi !== index) {
          var i;
          if (zi > index) {
            item = (() => {
              let result1 = [];
              for (i = 1, end = zi - index, asc = 1 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
                var asc, end;
                result1.push(parsed.moveBack());
              }
              return result1;
            })();
          } else if (zi < index) {
            // This should never happen but why not
            item = (() => {
              let result2 = [];
              for (i = 1, end1 = index - zi, asc1 = 1 <= end1; asc1 ? i <= end1 : i >= end1; asc1 ? i++ : i--) {
                var asc1, end1;
                result2.push(parsed.moveForward());
              }
              return result2;
            })();
          }
        }
        result.push(item);
      }
      return result;
    })();
  }

  delete() {
    // Build an object of which elements we want to delete before
    // we start deleting them,
    // because this fucks with the z-indexes
    let elem;
    let plan = {};
    for (let index of Object.keys(this.args || {})) {
      elem = this.args[index];
      index = parseInt(index, 10);
      plan[index] = queryElemByZIndex(index);
    }

    for (elem of Array.from(objectValues(plan))) {
      elem.delete();
    }

    if (!archive.simulating) {
      return ui.selection.elements.validate();
    }
  }

  undo() {
    if (this.mode === "delete") { return this.draw(); } else { return this.delete(); }
  }

  do() {
    if (this.mode === "delete") { return this.delete(); } else { return this.draw(); }
  }

  toJSON() {
    // t = type, "e:" = existence:
    //   "d" = delete, "c" = create
    // i = z-index to create or delete at
    // e = elem data
    return {
      t: `e:${ { "delete": "d", "create": "c" }[this.mode] }`,
      a: this.args
    };
  }
}




function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
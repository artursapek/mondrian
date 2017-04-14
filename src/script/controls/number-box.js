import Control from 'script/controls/control';
/*

  NumberBox

  _______________
  | 542.3402 px |
  ---------------

  An input:text that only accepts floats and can be adjusted with
  up/down arrows (alt/shift modifiers to change rate)

*/

class NumberBox extends Control {

  constructor(attrs) {
    // I/P:
    //   object of:
    //     rep:   HTML rep
    //     value: default value ^_^
    //     commit: callback for every change of value, given event and @read()
    //     [onDown]: callback for every keydown, given event and @read()
    //     [onUp]:   callback for every keyup, given event and @read()
    //     [onDone]: callback for every time the user seems to be done
    //               incrementally editing with arrow keys / typing in
    //               a value. Happens on arrowUp and enter
    //     [min]:    min value allowed
    //     [max]:    max value allowed
    //     [places]: round to this many places whenever it's changed

    super(attrs);

    if (attrs.addVal != null) {
      this.addVal = attrs.addVal;
    } else {
      this.addVal = this._addVal;
    }

    this.rep.setAttribute("h", "");

    // This has to be defined in the constructor and not as part of the class itself,
    // because we want the scope to be the object instnace and not the object constructor.
    this.hotkeys = $.extend({
      context: this,
      down: {
        always(e) {
          return (typeof this.onDown === 'function' ? this.onDown(e, this.read()) : undefined);
        },

        enter(e) {
          this.write(this.read());
          this.commit();
          return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined);
        },

        upArrow(e) {
          return this.addVal(e, 1);
        },

        downArrow(e) {
          return this.addVal(e, -1);
        },

        "shift-upArrow"(e) {
          return this.addVal(e, 10);
        },

        "shift-downArrow"(e) {
          return this.addVal(e, -10);
        },

        "alt-upArrow"(e) {
          return this.addVal(e, 0.1);
        },

        "alt-downArrow"(e) {
          return this.addVal(e, -0.1);
        }
      },

      up: {

        // Specific onDone events with arrow keys
        upArrow(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },
        downArrow(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },
        "shift-upArrow"(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },
        "shift-downArrow"(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },
        "alt-upArrow"(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },
        "alt-downArrow"(e) { return (typeof this.onDone === 'function' ? this.onDone(e, this.read()) : undefined); },

        always(e) {
          return (typeof this.onUp === 'function' ? this.onUp(e, this.read()) : undefined);
        }
      },

      blacklist: /^[A-Z]$/gi,

      inheritFromApp: [
        'V',
        'P',
        'M',
        'L',
        '\\',
        'O',
        'R'
      ]
    }, attrs.hotkeys);
  }

  read() {
    return parseFloat(this.$rep.val());
  }


  write(value) {
    this.value = value;
    if (this.places != null) {
      this.value = parseFloat(this.value).places(this.places);
    }
    if (this.max != null) {
      this.value = Math.min(this.max, this.value);
    }
    if (this.min != null) {
      this.value = Math.max(this.min, this.value);
    }
    return this.$rep.val(this.value);
  }


  _addVal(e, amt) {
    e.preventDefault();
    let oldVal = this.read();
    if ((oldVal == null)) {
      oldVal = 0;
    }
    let newVal = this.read() + amt;
    this.write(newVal);
    return this.commit();
  }
}


window.NumberBox = NumberBox;



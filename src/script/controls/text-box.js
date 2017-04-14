import Control from 'script/controls/control';
/*

  TestBox

  ___________
  | #FF0000 |
  -----------

*/

class TextBox extends Control {

  constructor(attrs) {
    // I/P:
    //   object of:
    //     rep:   HTML rep
    //     value: default value ^_^
    //     commit: callback for every change of value, given event and @read()
    //     maxLength: maximum str length for value
    //     [onDown]: callback for every keydown, given event and @read()
    //     [onUp]:   callback for every keyup, given event and @read()
    //     [onDone]: callback for every time the user seems to be done
    //               incrementally editing with arrow keys / typing in
    //               a value. Happens on arrowUp and enter

    super(attrs);

    this.rep.setAttribute("h", "");

    if (attrs.maxLength != null) {
      this.rep.setAttribute("maxLength", attrs.maxLength);
    }

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
        }
      },

      up: {
        always(e) {
          return (typeof this.onUp === 'function' ? this.onUp(e, this.read()) : undefined);
        }
      },

      blacklist: null,

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
    return this.$rep.val();
  }


  write(value) {
    this.value = value;
    return this.$rep.val(this.value);
  }
}

window.TextBox = TextBox;


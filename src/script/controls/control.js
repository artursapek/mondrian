/*

  UI Control

  A superclass for custom input controls such as smart text boxes and sliders.

*/


export default class Control {
  static initClass() {
  
    this.prototype.focused = false;
  
    this.prototype.value = null;
  
    this.prototype.valueWhenFocused = undefined;
  
  
    // Standard objects to fill in
  
    this.prototype.hotkeys = {};
  }

  constructor(attrs) {
    // I/P:
    //   object of:
    //     id:     the id for HTML rep
    //     value:  default value
    //     commit: a function that takes the value and does whatever with it!
    // Call the class extension's unique build method,
    // which builds the DOM elements for this control and
    // puts them in the @rep namespace.

    for (let key in attrs) {
      let val = attrs[key];
      this[key] = val;
    }
    this;

    this.$rep = $(this.rep);

    // Endpoints that we can use to interface with this Control object
    // via its DOM representation. Although in most cases you should just
    // keep track of the actual Control object and interface with it directly.

    this.$rep.bind("focus", () => this.focus());
    this.$rep.bind("blur", () => this.blur());
    this.$rep.bind("read", callback => callback(this.read()));
    this.$rep.bind("set", value => this.set(value));

    this.commitFunc = attrs.commit;
    this.commit = function() {
      return this.commitFunc(this.read());
    };
  }

  appendTo(selector) {
    // Should only be called once. Appends control's
    // DOM elements to wherever we want them.
    return q(selector).appendChild(this.rep);
  }

  focus() {
    // Make sure there's not more than one focused control at a time
    if (ui.controlFocused != null) {
      ui.controlFocused.blur();
    }

    this.valueWhenFocused = this.read();

    // Set this control up as self-aware and turn on its hotkey control
    this.focused = true;
    ui.controlFocused = this;
    return ui.hotkeys.use(this.hotkeys);
  }

  blur() {
    ui.controlFocused = undefined;
    this.focused = false;
    // Commit if they changed anything
    if (this.read() !== this.valueWhenFocused) { return this.commit(); }
  }

  update() {
    return this.rep.setAttribute("value", this.value);
  }


  // Standard methods to fill in when making subclasses:

  commit() {}
    // Apply the value to whatever it's supposed to do.

  build() {}
    // Defines @rep

  read() {}
    // Reads the DOM elements for the current value and returns it

  write(value) {}
    // Sets the DOM elements to reflect a certain value

  set(value) {
    // Set the value to whatever.
    // It should super into this to automatically run @update and set @value
    this.value = value;
    this.write(this.value); // Reflec the change in the DOM
    return this.update();
  }
}
Control.initClass();






import ui from 'script/ui/ui';
import setup from 'script/setup';

ui.utilities = {};

export default class Utility {

  constructor(attrs) {
    for (let i of Object.keys(attrs || {})) {
      let x = attrs[i];
      this[i] = x;
    }
    if (this.setup != null) {
      setup.push(() => this.setup());
    }
    this.$rep = $(this.root);

    setup.push(() => this.shouldBeOpen() ? this.show() : this.hide());
  }

  shouldBeOpen() {}

  show() {
    if (ui.canvas.petrified) { return; }
    this.visible = true;
    if (this.rep != null) {
      this.rep.style.display = "block";
    }
    if (typeof this.onshow === 'function') {
      this.onshow();
    }
    return this;
  }

  hide() {
    this.visible = false;
    this.$rep.find('input').blur();
    if (this.rep != null) {
      this.rep.style.display = "none";
    }
    return this;
  }

  toggle() {
    if (this.visible) { return this.hide(); } else { return this.show(); }
  }

  position(x, y) {
    this.x = x;
    this.y = y;
    if (this.rep != null) {
      this.rep.style.left = x.px();
    }
    if (this.rep != null) {
      this.rep.style.top = y.px();
    }
    return this;
  }

  saveOffset() {
    this.offset = new Posn($(this.rep).offset());
    return this;
  }
}



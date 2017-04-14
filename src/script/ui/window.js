import setup from 'script/setup';

ui.window = {

  setup() {
    window.onfocus = e => this.trigger('focus', [e]);
    window.onblur = e => this.trigger('blur', [e]);
    window.onerror = (msg, url, ln) => this.trigger('error', [msg, url, ln]);
    window.onresize = e => this.trigger('resize', [e]);
    window.onscroll = e => this.trigger('scroll', [e]);
    return window.onmousewheel = e => this.trigger('mousewheel', [e]);
  },

  listeners: {},

  listenersOne: {},

  on(event, action) {
    let listeners = this.listeners[event];
    if (listeners === undefined) {
      listeners = (this.listeners[event] = []);
    }
    return listeners.push(action);
  },

  one(event, action) {
    let listeners = this.listenersOne[event];
    if (listeners === undefined) {
      listeners = (this.listenersOne[event] = []);
    }
    return listeners.push(action);
  },

  trigger(event, args) {
    let a;
    let l = this.listeners[event];
    if (l != null) {
      for (a of Array.from(l)) {
        a.apply(this, args);
      }
    }
    let lo = this.listenersOne[event];
    if (lo != null) {
      for (a of Array.from(lo)) {
        a.apply(this, args);
      }
      return delete this.listenersOne[event];
    }
  },

  width() {
    return window.innerWidth;
  },

  height() {
    return window.innerHeight;
  },

  halfw() {
    return this.width() / 2;
  },

  halfh() {
    return this.height() / 2;
  },

  center() {
    return new Posn(this.width() / 2, this.height() /2);
  },

  centerOn(p) {
    let x = (this.width() / 2) - (p.x * ui.canvas.zoom);
    let y = (this.height() / 2) - (p.y * ui.canvas.zoom);
    ui.canvas.normal = new Posn(x, y);
    return ui.canvas.refreshPosition();
  }
};


setup.push(() => ui.window.setup());

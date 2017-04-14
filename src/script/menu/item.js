/*

  A button in a menu dropdown.

  Simple shit. Just has a handful of methods.

    text
      Change what it says.

    action
      Change what it does.

    refresh
      Change other things about it
      when its dropdown gets opened.

    disable
      Disable it

    enable
      Enable it

*/



class MenuItem {
  static initClass() {
  
  
    this.prototype.closeOnClick = true;
  }
  constructor(attrs) {
    for (let i in attrs) {
      let x = attrs[i];
      this[i] = x;
    }

    this.$rep = $(`#${this.itemid}`);
    this.rep = this.$rep[0];

    if (this.hotkey != null) {
      ui.hotkeys.sets.app.down[this.hotkey] = e => {
        e.preventDefault();
        this._refresh();
        if (this.disabled) { return; }
        this.action(e);
        trackEvent(`Menu item ${this.itemid}`, "Action (hotkey)");
        __guard__(this.owner(), x1 => x1.refresh());
        this.$rep.addClass("down");
        __guard__(this.owner(), x2 => x2.$rep.addClass("down"));

        if (this.hotkey.mentions("cmd")) {
          return setTimeout(() => {
            this.$rep.removeClass("down");
            __guard__(this.owner(), x3 => x3.$rep.removeClass("down"));
            return this._refresh();
          }
          , 50);
        }
      };

      if (!(this.hotkey.mentions("cmd"))) {
        if (this.disabled) { return; }
        ui.hotkeys.sets.app.up[this.hotkey] = e => {
          this.$rep.removeClass("down");
          __guard__(this.owner(), x1 => x1.$rep.removeClass("down"));
          if (typeof this.after === 'function') {
            this.after();
          }
          return this._refresh();
        };
      }
    }
  }



  _click(e) {
    this._refresh();
    if (this.disabled) { return; }
    if (this.closeOnClick) { __guard__(this.owner(), x => x.closeDropdown()); }
    __guard__(this.owner(), x1 => x1.$rep.find("[selected]").removeAttr("selected"));
    if (typeof this.action === 'function') {
      this.action(e);
    }
    __guard__(this.owner(), x2 => x2.refreshEnabledItems());
    return trackEvent(`Menu item ${this.itemid}`, "Action (click)");
  }


  save() {}
    // Fill in


  _refresh() {
    if (typeof this.refresh === 'function') {
      this.refresh();
    }
    if (this.enableWhen != null) {
      if (this.enableWhen()) { return this.enable(); } else { return this.disable(); }
    }
  }


  refresh() {}
    // Fill in


  owner() {
    return ui.menu.menu(this.$rep.closest(".menu").attr("id"));
  }


  show() {
    this.$rep.show();
    $(`.separator[visiblewith=\"${this.itemid}\"]`).show();
    return this;
  }


  hide() {
    this.$rep.hide();
    $(`.separator[visiblewith=\"${this.itemid}\"]`).hide();
    return this;
  }


  disable() {
    this.disabled = true;
    this.$rep.addClass("disabled");
    return this;
  }


  enable() {
    this.disabled = false;
    this.$rep.removeClass("disabled");
    return this;
  }


  text(val) {
    return this.$rep.find("[buttontext]").text(val);
  }


  group() {
    return this.$rep.closest(".menu-group");
  }


  groupHide() {
    return __guard__(this.group(), x => x.hide());
  }


  groupShow() {
    return __guard__(this.group(), x => x.css("display", "inline-block"));
  }
}
MenuItem.initClass();



function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
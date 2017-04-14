import ui from 'script/ui/ui';
/*

  Menubar, which manage MenuItems

*/

ui.menu = {

  // MenuItems
  menus: {},

  // MenuItems
  items: {},

  menu(id) {
    return objectValues(this.menus).filter(menu => menu.itemid === id)[0];
  },

  item(id) {
    return objectValues(this.items).filter(item => item.itemid === id)[0];
  },

  closeAllDropdowns() {
    return (() => {
      let result = [];
      for (let k of Object.keys(this.menus || {})) {
        let item = this.menus[k];
        result.push(item.closeDropdown());
      }
      return result;
    })();
  },

  refresh() {
    return (() => {
      let result = [];
      for (let key of Object.keys(this.menus || {})) {
        let menu = this.menus[key];
        result.push(menu.refresh());
      }
      return result;
    })();
  }
};


/*

  MenuItem

  An item on the top program menu, like Open, Save... etc
  Template.

*/

class Menu {
  static initClass() {
  
    this.prototype.disabled = false;
  
    this.prototype.dropdownOpen = false;
  }
  constructor(attrs) {
    for (let i in attrs) {
      let x = attrs[i];
      this[i] = x;
    }

    this.$rep = $(`#${this.itemid}`);
    this.rep = this.$rep[0];

    this.$dropdown = $(`#${this.itemid}-dropdown`);
    this.dropdown = this.$dropdown[0];

    // Save this neffew in ui.menu. This is how we're gonna access it from now on.
    this.dropdownSetup();

    if (this.onlineOnly) {
      this.bindOnlineListeners();
    }
  }

  refresh() {
    return this.items().map(function() { return this._refresh(); });
  }

  refreshEnabledItems() {
    return this.items().map(function() {
      if (this.enableWhen != null) {
        if (this.enableWhen()) { return this.enable(); } else { return this.disable(); }
      }
    });
  }

  refreshAfterVisible() {
    // Slower operations get called in here
    // to prevent visible lag.
    return this.items().map(function() { return (typeof this.refreshAfterVisible === 'function' ? this.refreshAfterVisible() : undefined); });
  }

  items() {
    return this.$rep.find('.menu-item').map(function() {
      return ui.menu.item(this.id);
    });
  }

  bindOnlineListeners() {
    if (!navigator.onLine) {
      this.hide();
    }

    window.addEventListener("offline", this.hide.bind(this));
    return window.addEventListener("online", this.show.bind(this));
  }

  text(val) {
    this.$rep.find("> [buttontext]").text(val);
    return this;
  }

  _click() {
    // This is standard for MenuItems: they open their dropdown.
    // You can also give it an onOpen method, which gets called
    // after the dropdown has opened.
    this.toggleDropdown();
    ui.refreshUtilities();
    return (typeof this.click === 'function' ? this.click() : undefined);
  }

  openDropdown() {
    if (this.dropdownOpen) { return; }

    // You can't have more than one dropdown open at the same time
    ui.menu.closeAllDropdowns();

    // Make this button highlighted unconditionally
    // while the dropdown is open
    this.$rep.attr("selected", "");

    this.refresh();

    // Open the dropdown
    this.$dropdown.show();
    this.dropdownOpen = true;

    trackEvent(`Menu ${this.itemid}`, "Action (click)");

    // Call the refresh method
    async(() => this.refreshAfterVisible());
    return this;
  }

  closeDropdown() {
    if (!this.dropdownOpen) { return; }

    this.$rep.removeAttr("selected");
    this.$rep.find("input:focus").blur();
    this.$dropdown.hide();
    this.dropdownOpen = false;
    if (typeof this.onClose === 'function') {
      this.onClose();
    }
    return this;
  }

  toggleDropdown() {
    if (this.dropdownOpen) { return this.closeDropdown(); } else { return this.openDropdown(); }
  }

  show() {
    if (this.onlineOnly && !navigator.onLine) { return this; }
    if (this.$rep != null) {
      this.$rep.removeClass("hidden");
    }
    return this;
  }

  hide() {
    if (this.$rep != null) {
      this.$rep.addClass("hidden");
    }
    return this;
  }

  dropdownSetup() {}
    // Fill in
    // Use this to bind listeners/special things to special elements in the dropdown.
    // Basically, do special weird things in here.

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
Menu.initClass();



function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

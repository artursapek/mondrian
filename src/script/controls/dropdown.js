import Control from 'script/controls/control';
/*

  Dropdown control

*/

class Dropdown extends Control {
  static initClass() {
  
    this.prototype.opened = false;
  }
  constructor(attrs) {

    super(attrs);

    this.$chosen = this.$rep.find('.dropdown-chosen');
    this.$list = this.$rep.find('.dropdown-list');

    this.options.map(o => {
      return this.$list.append(o.$rep);
    });

    if (attrs.default != null) {
      this.$chosen.empty().append();
    }

    this.select(this.options[0]);

    this.close();

    this.$chosen.click(() => this.toggle());
  }

  select(selected) {
    // the ol reddit switch a roo
    this.selected = selected;
    this.$chosen.children().first().appendTo(this.$list);
    this.$chosen.append(this.selected.$rep);
    this.refreshListeners();
    return this.callback(this.selected.val);
  }

  open() {
    // Fucking beautiful plugin
    this.$list.find('div').tsort();

    this.opened = true;
    this.$list.show();
    return this.refreshListeners();
  }

  close() {
    this.opened = false;
    return this.$list.hide();
  }

  refreshListeners() {
    this.$list.find('div').off('click');
    return this.$list.find('div').on('click', e => {
      this.select(this.getOption(e.target.innerHTML));
      return this.close();
    });
  }

  toggle() {
    if (this.opened) {
      return this.close();
    } else {
      return this.open();
    }
  }

  getOption(value) {
    return this.options.filter(o => o.val === value)[0];
  }
}
Dropdown.initClass();


class DropdownOption {
  constructor(val) {
    this.val = val;
    this.$rep = $(`<div class=\"dropdown-item\">${this.val}</div>`);
  }
}


class FontFaceOption extends DropdownOption {
  constructor(name) {
    this.name = name;
    super(...arguments);

    this.$rep.css({
      'font-family': this.name,
      'font-size': '14px'
    });
  }
}




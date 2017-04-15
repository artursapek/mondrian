import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(function() {

  ui.menu.items.save = new MenuItem({
    itemid: "save-item",

    action(e) {
      if (e != null) {
        e.preventDefault();
      }

      ui.file.save(() => {
        this.enable();
        return this.text("Save");
      });

      trackEvent("Local files", "Save");

      this.disable();
      return this.text("Saving...");
    },

    hotkey: 'cmd-S',

    refresh() {
      if (ui.file.readonly) {
          this.disable();
          return this.text("This file is read-only");
      } else {
        if (ui.file.hasChanges()) {
          this.enable();
          return this.text("Save");
        } else {
          this.disable();
          return this.text("All changes saved");
        }
      }
    }
  });


  return ui.menu.items.saveAs = new MenuItem({
    itemid: "save-as-item",

    action(e) {
      if (e != null) {
        e.preventDefault();
      }

      return ui.browser.open();
    },

    hotkey: 'cmd-shift-S',

    refresh() {
      return this.enable();
    }
  });
});



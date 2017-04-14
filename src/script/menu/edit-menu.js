setup.push(function() {

  ui.menu.menus.edit = new Menu({
    itemid: "edit-menu"});

  ui.menu.items.undo = new MenuItem({
    itemid: "undo-item",

    action(e) {
      e.preventDefault();
      return archive.undo();
    },

    hotkey: "cmd-Z",

    closeOnClick: false,

    enableWhen() {
      return !archive.currentlyAtBeginning();
    }
  });


  ui.menu.items.redo = new MenuItem({
    itemid: "redo-item",

    action(e) {
      e.preventDefault();
      return archive.redo();
    },

    hotkey: "cmd-shift-Z",

    closeOnClick: false,

    enableWhen() {
      return !archive.currentlyAtEnd();
    }
  });


  ui.menu.items.visualHistory = new MenuItem({
    itemid: "visual-history",

    action(e) {
      return ui.utilities.history.toggle();
    },

    hotkey: "0",

    closeOnClick: false,

    enableWhen() {
      return archive.events.length > 0;
    }
  });


  ui.menu.items.selectAll = new MenuItem({
    itemid: "select-all-item",

    action(e) {
      e.preventDefault();
      return ui.selection.elements.selectAll();
    },

    hotkey: "cmd-A",

    closeOnClick: false,

    enableWhen() {
      return ui.elements.length > 0;
    }
  });


  ui.menu.items.cut = new MenuItem({
    itemid: "cut-item",

    action(e) {
      e.preventDefault();
      return ui.clipboard.cut();
    },

    hotkey: "cmd-X",

    closeOnClick: false,

    enableWhen() {
      return ui.selection.elements.all.length > 0;
    }
  });


  ui.menu.items.copy = new MenuItem({
    itemid: "copy-item",

    action(e) {
      e.preventDefault();
      return ui.clipboard.copy();
    },

    hotkey: "cmd-C",

    closeOnClick: false,

    enableWhen() {
      return ui.selection.elements.all.length > 0;
    }
  });


  ui.menu.items.paste = new MenuItem({
    itemid: "paste-item",

    action(e) {
      e.preventDefault();
      return ui.clipboard.paste();
    },

    hotkey: "cmd-V",

    closeOnClick: false,

    enableWhen() {
      return (ui.clipboard.data != null);
    }
  });


  return ui.menu.items.delete = new MenuItem({
    itemid: "delete-item",

    action(e) {
      e.preventDefault();
      archive.addExistenceEvent(ui.selection.elements.all.map(e => e.zIndex()));
      ui.selection.delete();
      return ui.selection.elements.validate();
    },


    hotkey: "backspace",

    closeOnClick: false,

    enableWhen() {
      return ui.selection.elements.all.length > 0;
    }
  });
});





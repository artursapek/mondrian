import setup from 'script/setup';

setup.push(function() {

  ui.menu.menus.view = new Menu({
    itemid: "view-menu"});

  ui.menu.items.zoomOut = new MenuItem({
    itemid: "zoom-out-item",
    action(e) {
      e.preventDefault();
      ui.canvas.zoomOut();
      return false;
    },
    after() {
      return ui.refreshAfterZoom();
    },
    hotkey: "-",
    closeOnClick: false
  });


  ui.menu.items.zoomIn = new MenuItem({
    itemid: "zoom-in-item",
    action(e) {
      e.preventDefault();
      ui.canvas.zoomIn();
      return false;
    },
    after() {
      return ui.refreshAfterZoom();
    },

    hotkey: "+",
    closeOnClick: false
  });


  ui.menu.items.zoom100 = new MenuItem({
    itemid: "zoom-100-item",
    action(e) {
      e.preventDefault();
      ui.canvas.zoom100();
      return false;
    },
    after() {
      return ui.refreshAfterZoom();
    },
    hotkey: "1",
    closeOnClick: false
  });


  return ui.menu.items.grid = new MenuItem({
    itemid: "show-grid-item",
    hotkey: "shift-'",
    action() {
      return ui.grid.toggle();
    },
    closeOnClick: false
  });
});



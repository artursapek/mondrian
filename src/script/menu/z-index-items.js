import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(function() {
  ui.menu.items.moveBack = new MenuItem({
    itemid: 'move-back-item',

    hotkey: '[',

    action() {
      let zIndexesBefore = ui.selection.elements.zIndexes();
      ui.selection.elements.all.map(e => e.moveBack());
      return archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mb');
    },

    enableWhen() { return ui.selection.elements.all.length > 0; },

    closeOnClick: false
  });


  ui.menu.items.moveForward = new MenuItem({
    itemid: 'move-forward-item',

    hotkey: ']',

    action() {
      let zIndexesBefore = ui.selection.elements.zIndexes();
      ui.selection.elements.all.map(e => e.moveForward());
      return archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mf');
    },

    enableWhen() { return ui.selection.elements.all.length > 0; },

    closeOnClick: false
  });


  ui.menu.items.sendToBack = new MenuItem({
    itemid: 'send-to-back-item',

    hotkey: 'shift-[',

    action() {
      let zIndexesBefore = ui.selection.elements.zIndexes();
      ui.selection.elements.all.map(e => e.sendToBack());
      return archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mbb');
    },

    enableWhen() { return ui.selection.elements.all.length > 0; },

    closeOnClick: false
  });


  return ui.menu.items.bringToFront = new MenuItem({
    itemid: 'bring-to-front-item',

    hotkey: 'shift-]',

    action() {
      let zIndexesBefore = ui.selection.elements.zIndexes();
      ui.selection.elements.all.map(e => e.bringToFront());
      return archive.addZIndexEvent(zIndexesBefore, ui.selection.elements.zIndexes(), 'mff');
    },

    enableWhen() { return ui.selection.elements.all.length > 0; },

    closeOnClick: false
  });
});



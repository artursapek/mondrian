import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(function() {

  ui.menu.menus.share = new Menu({
    itemid: "share-menu",

    onlineOnly: true
  });

  return ui.menu.items.shareAsLink = new MenuItem({
    itemid: "share-permalink-item",

    action() {
      return services.permalink.put();
    }
  });
});


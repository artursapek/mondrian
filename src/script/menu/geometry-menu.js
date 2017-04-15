import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(() =>

  ui.menu.menus.geometry = new Menu({
    itemid: "geometry-menu"})
);


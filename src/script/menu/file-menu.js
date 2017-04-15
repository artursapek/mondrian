import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';

setup.push(() =>
  ui.menu.menus.file = new Menu({
    itemid: "file-menu"})
);




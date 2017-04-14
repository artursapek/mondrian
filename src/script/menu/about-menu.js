import setup from 'script/setup';

setup.push(() =>

  ui.menu.menus.about = new Menu({
    itemid: "about-menu",

    refreshAfterVisible() {}
  })
);


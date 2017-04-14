import setup from 'script/setup';

setup.push(() =>

  ui.menu.items.logout = new MenuItem({
    itemid: "logout-item",

    action() {
      return ui.account.logout();
    }
  })
);



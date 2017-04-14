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


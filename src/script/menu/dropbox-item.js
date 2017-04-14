import setup from 'script/setup';

setup.push(function() {

  return ui.menu.items.dropboxConnect = new MenuItem({
    itemid: "connect-to-dropbox-item",

    enableWhen() { return navigator.onLine; },

    refresh() {
      if (ui.account.session_token) {
        this.enable();
        this.rep.parentNode.setAttribute("href", `${SETTINGS.MEOWSET.ENDPOINT}/poletto/connect-to-dropbox?session_token=${ui.account.session_token}`);
        return this.$rep.parent().off('click').on('click', () =>
          ui.window.one("focus", function() {
            ui.menu.menus.file.closeDropdown();
            ui.account.checkServices();
            return trackEvent("Dropbox", "Connect Account");
        })
      );

      } else {
        this.disable();
        return this.$rep.parent().click(e => e.preventDefault());
      }
    }
  });
});




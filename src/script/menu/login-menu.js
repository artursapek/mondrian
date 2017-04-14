import setup from 'script/setup';

setup.push(function() {

  ui.menu.menus.login = new Menu({
    itemid: "login-menu",

    onlineOnly: true,

    refreshAfterVisible() {
      return $("#login-email-input").focus();
    },

    submit($self) {
      let email = $("#login-email-input").val();
      let passwd = $("#login-passwd-input").val();

      if (email === "") {
        return $self.error("email required");
      } else if (passwd === "") {
        return $self.error("password required");
      } else {
        return ui.account.login(email, passwd);
      }
    }
  });
      //@closeDropdown()


  $("#submit-login").click(function() {
    return ui.menu.menus.login.submit($(this));
  });

  return $("#login-passwd-input").hotkeys({
    down: {
      enter() {
        return ui.menu.menus.login.submit();
      }
    }
  });
});



import setup from 'script/setup';

setup.push(function() {

  ui.menu.menus.register = new Menu({
    itemid: "register-menu",

    onlineOnly: true,

    refreshAfterVisible() {
      return $("#register-name").focus();
    },

    submit() {
      let name =   $("#register-name").val();
      let email =  $("#register-email").val();
      let passwd = $("#register-passwd").val();

      //return if name == "" or email == "" or passwd == ""

      return ui.account.create(name, email, passwd, function(data) {}
        // pass
      );
    }
  });

  $("#submit-registration").click(() => ui.menu.menus.register.submit());

  return $("#register-passwd").hotkeys({
    down: {
      enter() {
        return ui.menu.menus.register.submit();
      }
    }
  });
});


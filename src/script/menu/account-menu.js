import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';

setup.push(function() {

  return ui.menu.menus.account = new Menu({
    itemid: "account-menu",

    onlineOnly: true,

    showAndFillIn(email) {
      this.group().style.display = "inline-block";
      return this.$rep.find("span#logged-in-email").text(email);
    },

    onClose() {
      return this.$dropdown.attr("mode", "normal");
    }
  });
});
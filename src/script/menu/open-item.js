import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(function() {


  // Open...

  ui.menu.items.open = new MenuItem({
    itemid: "open-item",

    action() {
      return ui.file.service.open();
    },

    hotkey: 'cmd-O'
  });


  // Open from hard drive...

  ui.menu.items.openHD = new MenuItem({
    itemid: "open-from-hd-item",

    action() {},

    refresh() {
      let $input = $("#hd-file-loader");
      let reader = new FileReader;
      let name = null;

      reader.onload = e => {
        new LocalFile(name).set(e.target.result).use(true).save();
        return this.owner().closeDropdown();
      };

      return $input.change(function() {
        this.setAttribute("value", "");
        let file = this.files[0];
        if ((file == null)) { return; }
        ({ name } = file);
        reader.readAsText(file);
        return trackEvent("Local files", "Open from HD");
      });
    }
  });


  // Open from URL...

  return ui.menu.items.openURL = new MenuItem({
    itemid: "open-from-url-item",

    action() {
      this.inputMode();
      return setTimeout(() => ui.cursor.reset()
      , 1);
    },

    openURL(url) {
      let name = url.match(/[^\/]*\.svg$/gi);
      name = name ? name[0] : services.local.nextDefaultName();

      return $.ajax({
        url: `${SETTINGS.BONITA.ENDPOINT}/curl/?url=${url}`,
        type: 'GET',
        data: {},
        success(data) {
          data = new XMLSerializer().serializeToString(data);
          let file = new LocalFile(name).set(data).use(true);
          return trackEvent("Local files", "Open from URL");
        },
        error(data) {
          return console.log("error");
        }
      });
    },

    clickMeMode() {
      this.$rep.find("input").blur();
      this.$rep.removeClass("input-mode");
      return this.$rep.removeAttr("selected");
    },

    inputMode() {
      let self = this;
      this.$rep.addClass("input-mode");
      this.$rep.attr("selected", "");
      return this.$rep.find('input').val("").focus().on("paste", e => {
        return setTimeout((() => {
          this.openURL($(e.target).val());
          this.clickMeMode();
          return this.owner().closeDropdown();
        }
        ), 10);
      });
    },

    closeOnClick: false,

    refresh() {
      return this.clickMeMode();
    }
  });
});


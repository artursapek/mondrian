import ui from 'script/ui/ui';
import setup from 'script/setup';
import Menu from 'script/menu/menu';
import MenuItem from 'script/menu/item';

setup.push(function() {
  return ui.menu.menus.embed = new Menu({
    itemid: "embed-menu",

    template() {
      let height = ((ui.canvas.height / ui.canvas.width) * this.width) + 31; // 3px for border above footer
      height = Math.ceil(height);
      return `<iframe width=\"${this.width}\" height=\"${height}\" frameborder=\"0\" src=\"${SETTINGS.EMBED.ENDPOINT}/files/permalinks/${ui.file.key}/embed\"></iframe>`;
    },

    onlineOnly: true,

    refreshAfterVisible() {
      if (ui.file.constructor === PermalinkFile) {
        this.generateCode();
        return this.$textarea.select();
      } else {
        // Save it to s3 if we haven't yet
        this.$textarea.val("Saving, please wait...");
        this.$textarea.disable();
        return services.permalink.put(undefined, io.makeFile(), () => {
          this.generateCode();
          this.$textarea.enable();
          return this.$textarea.select();
        });
      }
    },

    dropdownSetup() {
      this.width = 500;
      this.$textarea = this.$rep.find("textarea");

      return this.widthControl = new NumberBox({
        rep:   this.$rep.find('input')[0],
        value: this.width,
        min: 100,
        max: 1600,
        places: 0,
        hotkeys: {
          up: {
            always() {
              return this.commit();
            }
          }
        },

        commit: val => {
          this.width = val;
          return this.generateCode();
        }
      });
    },


    generateCode() {
      return this.$textarea.val(this.template());
    }
  });
});


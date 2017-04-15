import setup from 'script/setup';
import ui from 'script/ui/ui';

let url = {
  actions: {
    p(public_key) {
      ui.canvas.hide();
      return services.permalink.get(public_key, function(response) {
        ui.canvas.show();
        io.parseAndAppend(response.contents);

        let permalink = new PermalinkFile(public_key);
        permalink.use();
        permalink.readonly = response.readonly;

        //ui.file.define(services.permalink, public_key, response.file_name)
        return ui.canvas.centerOn(ui.window.center());
      });
    },

    url(targetURL) {
      return ui.menu.items.openURL.openURL(targetURL);
    }
  },

  parse() {
    let key, val;
    let url_parameters = document.location.search.replace(/\/$/, "");
    let parameters = url_parameters.substring(1).split("&");
    return Array.from(parameters).map((param) =>
      ((param = param.split("=")),
      (key = param[0]),
      (val = param[1]),
      (typeof this.actions[key] === 'function' ? this.actions[key](val) : undefined)));
  }
};

setup.push(() => url.parse());

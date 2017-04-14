import setup from 'script/setup';

setup.push(function() {

  ui.menu.items.downloadSVG = new MenuItem({
    itemid: "download-as-SVG-item",

    refreshAfterVisible() {
      // TODO refactor these variable names, theyre silly
      let $link = q("#download-svg-link");
      if (this.disabled) {
        $link.removeAttribute("href");
        $link.removeAttribute("download");
      } else {
        $link.setAttribute("href", io.makeBase64URI());
        $link.setAttribute("download", ui.file.name);
      }
      return $($link).one('click', () => trackEvent("Download", "SVG", ui.file.name));
    }
  });


  return ui.menu.items.downloadPNG = new MenuItem({
    itemid: "download-as-PNG-item",

    refreshAfterVisible() {
      let $link = q("#download-png-link");
      if (this.disabled) {
        $link.removeAttribute("href");
        $link.removeAttribute("download");
      } else {
        $link.setAttribute("href", io.makePNGURI());
        $link.setAttribute("download", ui.file.name.replace("svg", "png"));
      }
      return $($link).one('click', () => trackEvent("Download", "PNG", ui.file.name));
    }
  });
});


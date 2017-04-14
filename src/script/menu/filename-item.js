setup.push(function() {

  return ui.menu.items.filename = new MenuItem({
    itemid: "filename-item",

    refresh(name, path, service) {
      this.$rep.find("#file-name-with-extension").text(ui.file.name);
      this.$rep.find("#service-logo-for-filename").show().attr("class", `service-logo-small ${ui.file.service.name}`);

      return this.$rep.find("#service-path-for-filename").html(ui.file.path);
    },

    action(e) {
      return e.stopPropagation();
    }
  });
});


setup.push ->

  ui.menu.items.filename = new MenuItem
    itemid: "filename-item"

    refresh: (name, path, service) ->
      @$rep.find("#file-name-with-extension").text(ui.file.name)
      @$rep.find("#service-logo-for-filename").show().attr("class", "service-logo-small #{ui.file.service.name}")

      @$rep.find("#service-path-for-filename").html(ui.file.path)

    action: (e) ->
      e.stopPropagation()


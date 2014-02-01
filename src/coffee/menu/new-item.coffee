setup.push ->

  ui.menu.items.new = new MenuItem
    itemid: "new-item"

    action: (e) ->
      ui.new(1000, 750, new Posn(0,0), 1.0)

      switch ui.file.service
        when services.permalink, services.local
          f = new LocalFile(services.local.nextDefaultName()).use()
          ui.file.save()
          archive.setup()
        when services.dropbox
          services.dropbox.defaultName ui.file.path, (name) ->
            new DropboxFile("#{ui.file.path}#{name}").use()

    hotkey: 'N'




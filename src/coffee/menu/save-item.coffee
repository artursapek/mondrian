setup.push ->

  ui.menu.items.save = new MenuItem
    itemid: "save-item"

    action: (e) ->
      e?.preventDefault()

      ui.file.save =>
        @enable()
        @text("Save")

      trackEvent "Local files", "Save"

      @disable()
      @text("Saving...")

    hotkey: 'cmd-S'

    refresh: ->
      if ui.file.readonly
          @disable()
          @text("This file is read-only")
      else
        if ui.file.hasChanges()
          @enable()
          @text("Save")
        else
          @disable()
          @text("All changes saved")


  ui.menu.items.saveAs = new MenuItem
    itemid: "save-as-item"

    action: (e) ->
      e?.preventDefault()

      ui.browser.open()

    hotkey: 'cmd-shift-S'

    refresh: ->
      @enable()



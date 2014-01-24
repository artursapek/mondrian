setup.push ->
  ui.menu.menus.embed = new Menu
    itemid: "embed-menu"

    template: () ->
      height = ((ui.canvas.height / ui.canvas.width) * @width) + 31 # 3px for border above footer
      height = Math.ceil(height)
      "<iframe width=\"#{@width}\" height=\"#{height}\" frameborder=\"0\" src=\"#{SETTINGS.EMBED.ENDPOINT}/files/permalinks/#{ui.file.key}/embed\"></iframe>"

    refreshAfterVisible: ->
      if ui.file.constructor is PermalinkFile
        @generateCode()
        @$textarea.select()
      else
        # Save it to s3 if we haven't yet
        @$textarea.val "Saving, please wait..."
        @$textarea.disable()
        services.permalink.put(undefined, io.makeFile(), =>
          @generateCode()
          @$textarea.enable()
          @$textarea.select()
        )

    dropdownSetup: ->
      @width = 500
      @$textarea = @$rep.find("textarea")

      @widthControl = new NumberBox
        rep:   @$rep.find('input')[0]
        value: @width
        min: 100
        max: 1600
        places: 0
        hotkeys:
          up:
            always: ->
              @commit()

        commit: (val) =>
          @width = val
          @generateCode()


    generateCode: ->
      @$textarea.val @template()


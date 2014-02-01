setup.push ->


  # Open...

  ui.menu.items.open = new MenuItem
    itemid: "open-item"

    action: ->
      ui.file.service.open()


  # Open from hard drive...

  ui.menu.items.openHD = new MenuItem
    itemid: "open-from-hd-item"

    action: ->

    refresh: ->
      $input = $("#hd-file-loader")
      reader = new FileReader
      name = null

      reader.onload = (e) =>
        new LocalFile(name).set(e.target.result).use(true).save()
        @owner().closeDropdown()

      $input.change ->
        @setAttribute("value", "")
        file = @files[0]
        return if not file?
        name = file.name
        reader.readAsText file
        trackEvent "Local files", "Open from HD"


  # Open from URL...

  ui.menu.items.openURL = new MenuItem
    itemid: "open-from-url-item"

    action: ->
      @inputMode()
      setTimeout ->
        ui.cursor.reset()
      , 1

    openURL: (url) ->
      name = url.match(/[^\/]*\.svg$/gi)
      name = if name then name[0] else services.local.nextDefaultName()

      $.ajax
        url: "#{SETTINGS.BONITA.ENDPOINT}/curl/?url=#{url}"
        type: 'GET'
        data: {}
        success: (data) ->
          data = new XMLSerializer().serializeToString(data)
          file = new LocalFile(name).set(data).use(true)
          trackEvent "Local files", "Open from URL"
        error: (data) ->
          console.log "error"

    clickMeMode: ->
      @$rep.find("input").blur()
      @$rep.removeClass("input-mode")
      @$rep.removeAttr("selected")

    inputMode: ->
      self = @
      @$rep.addClass("input-mode")
      @$rep.attr("selected", "")
      @$rep.find('input').val("").focus().on("paste", (e) =>
        setTimeout (=>
          @openURL $(e.target).val()
          @clickMeMode()
          @owner().closeDropdown()
        ), 10
      )

    closeOnClick: false

    refresh: ->
      @clickMeMode()


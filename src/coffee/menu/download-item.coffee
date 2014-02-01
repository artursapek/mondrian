setup.push ->

  ui.menu.items.downloadSVG = new MenuItem
    itemid: "download-as-SVG-item"

    refreshAfterVisible: ->
      # TODO refactor these variable names, theyre silly
      $link = q("#download-svg-link")
      if @disabled
        $link.removeAttribute("href")
        $link.removeAttribute("download")
      else
        $link.setAttribute("href", io.makeBase64URI())
        $link.setAttribute("download", ui.file.name)
      $($link).one 'click', ->
        trackEvent "Download", "SVG", ui.file.name


  ui.menu.items.downloadPNG = new MenuItem
    itemid: "download-as-PNG-item"

    refreshAfterVisible: ->
      $link = q("#download-png-link")
      if @disabled
        $link.removeAttribute("href")
        $link.removeAttribute("download")
      else
        $link.setAttribute("href", io.makePNGURI())
        $link.setAttribute("download", ui.file.name.replace("svg", "png"))
      $($link).one 'click', ->
        trackEvent "Download", "PNG", ui.file.name



url =
  actions:
    p: (public_key) ->
      ui.canvas.hide()
      services.permalink.get(public_key, (response) ->
        ui.canvas.show()
        io.parseAndAppend(response.contents)

        permalink = new PermalinkFile(public_key)
        permalink.use()
        permalink.readonly = response.readonly

        #ui.file.define(services.permalink, public_key, response.file_name)
        ui.canvas.centerOn(ui.window.center())
      )

    url: (targetURL) ->
      ui.menu.items.openURL.openURL(targetURL)

  parse: ->
    url_parameters = document.location.search.replace(/\/$/, "")
    parameters = url_parameters.substring(1).split "&"
    for param in parameters
      param = param.split "="
      key = param[0]
      val = param[1]
      @actions[key]?(val)

setup.push -> url.parse()

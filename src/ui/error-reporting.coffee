setup.push ->
  ui.window.on("error", (msg, url, ln) ->
    trackEvent "Javascript", "Error", "#{msg}"
  )

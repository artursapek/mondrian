###

  Google Analytics tracking.

###

trackEvent = (category, event, lbl) ->
  # Abstraction for _gaq _trackEvent
  label = "#{ui.account}"
  label += ": #{lbl}" if lbl?
  if SETTINGS.PRODUCTION
    _gaq.push ['_trackEvent', category, event, label]
  else
    #print "track", category, event, label


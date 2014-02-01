###

  Setup

  Bind $(document).ready
  Global exports

###

appLoaded = false

setup = []

# For state preservation, run setup functions
# after everything is initialized with the DOM
secondRoundSetup = []

$(document).ajaxSend -> ui.logo.animate()

$(document).ajaxComplete -> ui.logo.stopAnimating()

$(document).ready ->
  for procedure in setup
    procedure()

  appLoaded = true

  for procedure in secondRoundSetup
    procedure()

  # Make damn sure the window isnt off somehow because
  # they wont be able to undo it
  setTimeout ->
    window.scrollTo 0, 0
  , 500


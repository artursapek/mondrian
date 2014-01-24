###

  Commonly accessed DOM elements

###

dom =

  setup: ->
    @$body = $('body')
    @body = @$body[0]

    @$main = $('#main')
    @main = @$main[0]

    @$ui = $('#ui')
    @ui = @$ui[0]

    @$bg = $('#bg')
    @bg = @$bg[0]

    @$annotations = $('#annotations')
    @annotations = @$annotations[0]

    @$hoverTargets = $('#hover-targets')
    @hoverTargets = @$hoverTargets[0]

    @$grid = $('#grid')
    @grid = @$grid[0]

    @$utilities = $('#utilities')
    @utilities = @$utilities[0]

    @$selectionBox = $('#selection-box')
    @selectionBox = @$selectionBox[0]

    @$dragSelection = $('#drag-selection')
    @dragSelection = @$dragSelection[0]

    @$menuBar = $('#menu-bar')
    @menuBar = @$menuBar[0]

    @$currentSwatches = $('#current-swatches')
    @currentSwatches = @$currentSwatches[0]

    @$toolPalette = $('#tool-palette')
    @toolPalette = @$toolPalette[0]

    @$toolCursorPlaceholder = $('#tool-cursor-placeholder')
    @toolCursorPlaceholder = @$toolCursorPlaceholder[0]

    @$canvas = $('#canvas')
    @canvas = @$canvas[0]

    @$logoLeft = $("#logo #left-bar")
    @$logoMiddle = $("#logo #middle-bar")
    @$logoRight = $("#logo #right-bar")
    @logoLeft = @$logoLeft[0]
    @logoMiddle = @$logoMiddle[0]
    @logoRight = @$logoRight[0]

    @$filename = $("#filename-menu")
    @filename = @$filename[0]

    @$login = $("#login-mg")
    @login = @$login[0]

    @$tmpPaste = $('#tmp-paste')
    @tmpPaste = @$tmpPaste[0]

    @$pngSandbox = $('#png-download-sandbox')
    @pngSandbox = @$pngSandbox[0]

    @$currentService = $('#current-service')
    @currentService = @$currentService[0]

    @$serviceLogo = $('.service-logo')
    @serviceLogo = @$serviceLogo[0]

    @$serviceGallery = $('#service-file-gallery')
    @serviceGallery = @$serviceGallery[0]

    @$serviceGalleryThumbs = $('#service-file-gallery-thumbnails')
    @serviceGalleryThumbs = @$serviceGalleryThumbs[0]

    @$serviceBrowser = $('#service-file-browser')
    @serviceBrowser = @$serviceBrowser[0]

    @$registerButton = $('#register-mg')
    @registerButton = @$registerButton[0]

    @$dialogTitle = $("#dialog-title")
    @dialogTitle = @$dialogTitle[0]

setup.push -> dom.setup()

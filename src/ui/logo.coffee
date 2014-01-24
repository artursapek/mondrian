###

  Animated Mondy logo for indicating progress

###

ui.logo =
  animate: ->
    @_animateRequests += 1

    if @_animateRequests is 1
      clearInterval(@animateLogoInterval)
      @animateLogoInterval = setInterval =>
        if @_animateRequests == 0
          @_reset()
        else
          vals = [ui.colors.logoRed, ui.colors.logoYellow, ui.colors.logoBlue]
          a = parseInt(Math.random() * 3)
          dom.$logoLeft.css("background-color", vals[a])
          vals = vals.slice(0, a).concat(vals.slice(a + 1))
          a = parseInt(Math.random() * 2)
          dom.$logoMiddle.css("background-color", vals[a])
          vals = vals.slice(0, a).concat(vals.slice(a + 1))
          dom.$logoRight.css("background-color", vals[0])
      , 170

  stopAnimating: ->
    @_animateRequests -= 1

    if @_animateRequests < 0
      @_animateRequests = 0

  _animateRequests: 0

  _reset: ->
    clearInterval(@animateLogoInterval)
    dom.$logoLeft.css("background-color", ui.colors.logoRed)
    dom.$logoMiddle.css("background-color", ui.colors.logoYellow)
    dom.$logoRight.css("background-color", ui.colors.logoBlue)





class Slider extends Control

  constructor: (attrs) ->
    # I/P:
    #   object of:
    #     rep: div containing slider elements:
    #       %div.slider.left-icon
    #       %div.slider.right-icon
    #       %div.slider.track
    #     commit: callback for every change of value
    #     inverse: goes max to min instead
    #     onRelease: callback for when the user stops dragging
    #     valueTipFormatter: a method that returns a string
    #                        given the value of @read().
    #                        If defined, a live tip will
    #                        appear under the slider that shows
    #                        the current value when it's being moved.

    super attrs

    @hotkeys = {}

    @$knob = @$rep.find('.knob')
    @$track = @$rep.find('.track')
    if @valueTipFormatter?
      @$knob.append(@$tip = $("<div class=\"slider tip\"></div>"))

    @knobWidth = @$knob.width()

    @trackMin = parseFloat(@$track.css("left"))
    @trackWidth = parseFloat(@$track.css("width")) - @knobWidth
    @trackMax = @trackMin + @trackWidth

    @$knob.on("nudge", =>
      @commit()
      @$tip?.show().text(@valueTipFormatter(@read()))
    )
    .on("stopDrag", =>
      @onRelease?(@read())
      @$tip?.hide()
      )
    .attr("drag-x", "#{@trackMin} #{@trackMax}")

    @set 0.0

    @$iconLeft = @$rep.find(".left-icon")
    @$iconRight = @$rep.find(".right-icon")

    @$knob.on("click", (e) => e.stopPropagation())

    @$iconLeft.on "click", (e) =>
      e.stopPropagation()
      @set 0.0
      @commit()

    @$iconRight.on "click", (e) =>
      e.stopPropagation()
      @set 1.0
      @commit()

    @$track = @$rep.find(".track")

    @$rep.on "release", =>
      @onRelease?(@read())



  read: ->
    @leftCSSToFloat(parseFloat(@$knob.css("left")))


  write: (value) ->
    @$knob.css("left", @floatToLeftCSS(value))


  floatToLeftCSS: (value) ->
    value = Math.min(1.0, (Math.max(0.0, value)))
    if @inverse
      value = 1.0 - value

    l = ((@trackWidth * value) + @trackMin).px()


  leftCSSToFloat: (left) ->
    f = (parseFloat(left) - @trackMin) / @trackWidth
    if @inverse
      return 1.0 - f
    else
      return f





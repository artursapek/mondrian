###

  HoverTarget

###


class HoverTarget extends Monsvg
  type: 'path'

  constructor: (@a, @b, @width) ->
    # I/P: a: First point
    #      b: Second point
    #      width: stroke-width to be added to

    # Default width is always 1
    if not @width?
      @width = 1

    @owner = @b.owner

    # Convert SmoothTo's to independent CurveTo's
    b = if @b instanceof SmoothTo then @b.toCurveTo() else @b


    # Standalone path. MoveTo precessor point, and make the current one.
    # This way it exactly represents a single line-segment between two points on the path.
    @d = "M#{@a.x * ui.canvas.zoom},#{@a.y * ui.canvas.zoom} #{b.toStringWithZoom()}"

    # Build the data object, just a bunch of defaults.
    @data =
      fill: "none"
      stroke: "rgba(75, 175, 255, 0.0)"
      "stroke-width": 4 / ui.canvas.zoom
      d: @d

    # Store under second point.
    @b.hoverTarget = @

    super @data

    # This class should be as easy to use as possible, so just append it right away.
    # False for don't track.
    @appendTo '#hover-targets', false

    # Keeping track of a few things for the cursor-tracking events.

    @rep.setAttribute 'a', @a.at
    @rep.setAttribute 'b', @b.at
    @rep.setAttribute 'owner', @owner.metadata.uuid


  highlight: ->
    ui.unhighlightHoverTargets()
    @a.hover()
    @b.hover()
    @attr
      "stroke-width": 5
      stroke: "#4981e0"
    ui.hoverTargetsHighlighted.push @
    @commit()


  unhighlight: ->
    @attr
      "stroke-width": 5
      stroke: "rgba(75, 175, 255, 0.0)"
    @commit()


  active: ->
    @a.baseHandle.setAttribute 'active', ''
    @b.baseHandle.setAttribute 'active', ''


  nudge: (x, y) ->
    @a.nudge(x, y)
    @b.nudge(x, y)

    @owner.commit()
    @unhighlight()
    @constructor(@a, @b, @width)





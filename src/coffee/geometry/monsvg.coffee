###

    Mondrian SVG library

    Artur Sapek 2012 - 2013

###


class Monsvg

  # MonSvg
  #
  # Over-arching class for all vector objects
  #
  # I/P : data Object of SVG element's attributes
  #
  # O/P : self
  #
  # Subclasses:
  #   Line
  #   Rect
  #   Circle
  #   Polygon
  #   Path


  constructor: (@data = {}) ->

    # Create SVG element representation
    # Set up metadata
    #
    # No I/P
    #
    # O/P : self

    @rep = @toSVG()
    @$rep = $(@rep)

    @metadata =
      angle: 0
      locked: false

    unless @data.dontTrack
      @metadata.uuid = uuid()

    @rep.setAttribute 'uuid', @metadata.uuid

    @validateColors()

    if @type isnt "text"
      @data = $.extend
        fill:   new Color("none")
        stroke: new Color("none")
      , @data

    # This is used to track landmark changes to @data
    # for the archive. Consider a user selecting a few elements
    # and dragging around on the color picker until they like what
    # they see. There's no way in hell we're gonna store every
    # single color they hovered over while happily dragging around.
    #
    # So we keep two copies of @data. The second is called @dataArchived.
    # Here we set it for the first time.

    @updateDataArchived()

    # Apply
    if @data["mondrian:angle"]?
      @metadata.angle = parseFloat(@data["mondrian:angle"], 10)


    ###
    if @data.transform?
      attrs = @data.transform.split(" ")
      for attr in attrs
        key = attr.match(/[a-z]+/gi)?[0]
        val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")
      @transform[key] = val.replace(/[\(\)]/gi, "")
      #console.log "saved #{attr} as #{key} #{val}"
  ###


  commit: ->
    # Commit any changes to its representation in the DOM
    #
    # No I/P
    # O/P: self

    ###
    newTransform = []

    for own key, val of @transform
      if key is "translate"
        newTransform.push "#{key}(#{val.x},#{val.y})"
      else
        newTransform.push "#{key}(#{val})"

    @data.transform = newTransform.join(" ")
    ###

    for key, val of @data
      if key is ""
        delete @data[""]
      else
        if "#{val}".mentions "NaN"
          throw new Error "NaN! Ack. Attribute = #{key}, Value = #{val}"
        @rep.setAttribute(key, val)

    if @metadata.angle is 0
      @rep.removeAttribute('mondrian:angle')
    else
      if @metadata.angle < 0
        @metadata.angle += 360
      @rep.setAttribute('mondrian:angle', @metadata.angle)

    @

  updateDataArchived: (attr) ->
    # If no attr is provided simply copy the new values in @data to @dataArchived
    # If there is, only copy over that one attribute.
    if attr?
      @dataArchived[attr] = @data[attr]
    else
      @dataArchived = cloneObject @data


  toSVG: ->
    # Return the SVG DOM element that this Monsvg object represents
    # We need to use the svg namespace for the element to behave properly
    self = document.createElementNS('http://www.w3.org/2000/svg', @type)
    for key, val of @data
      self.setAttribute(key, val) unless key is ""
    self


  validateColors: ->
    # Convert color strings to Color objects
    if @data.fill? and not (@data.fill instanceof Color)
      @data.fill = new Color @data.fill
    if @data.stroke? and not (@data.stroke instanceof Color)
      @data.stroke = new Color @data.stroke
    if not @data["stroke-width"]?
      @data["stroke-width"] = 1



  points: []


  center: ->
    # Returns the center of a cluster of posns
    #
    # O/P: Posn

    xr = @xRange()
    yr = @yRange()
    new Posn(xr.min + (xr.max - xr.min) / 2, yr.min + (yr.max - yr.min) / 2)

  queryPoint: (rep) ->
    @points.filter((a) -> a.baseHandle is rep)[0]

  queryAntlerPoint: (rep) ->
    @antlerPoints.filter((a) -> a.baseHandle is rep)[0]

  show: -> @rep.style.display = "block"

  hide: -> @rep.style.display = "none"

  showPoints: ->
    @points.map (point) -> point.show()
    @

  hidePoints: ->
    @points.map (point) -> point.hide()
    @

  unhoverPoints: ->
    @points.map (point) -> point.unhover()
    @

  removePoints: ->
    @points.map (point) -> point.clear()
    @

  unremovePoints: ->
    @points.map (point) -> point.unclear()
    @


  destroyPoints: ->
    @points.map (p) -> p.remove()


  removeHoverTargets: ->
    existent = qa("svg#hover-targets [owner='#{@metadata.uuid}']")
    for ht in existent
      ht.remove()


  redrawHoverTargets: ->
    @removeHoverTargets()
    @points.map (p) => new HoverTarget(p.prec, p)
    @



  topLeftBound: ->
    new Posn(@xRange().min, @yRange().min)

  topRightBound: ->
    new Posn(@xRange().max, @yRange().min)

  bottomRightBound: ->
    new Posn(@xRange().max, @yRange().max)

  bottomLeftBound: ->
    new Posn(@xRange().min, @yRange().max)

  attr: (data) ->
    for key, val of data
      if typeof val == 'function'
        @data[key] = val(@data[key])
      else
        @data[key] = val


  appendTo: (selector, track = true) ->
    if typeof selector is "string"
      target = q(selector)
    else
      target = selector
    target.appendChild(@rep)
    if track
      if not ui.elements.has @
        ui.elements.push @
    @

  clone: ->
    #@commit()
    cloneData = cloneObject @data
    cloneTransform = cloneObject @transform
    delete cloneData.id
    clone = new @constructor(cloneData)
    clone.transform = cloneTransform
    clone

  delete: ->
    @rep.remove()
    ui.elements = ui.elements.remove @
    async =>
      @destroyPoints()
      @removeHoverTargets()
      if @group
        @group.delete()

  zIndex: ->
    zi = 0
    dom.$main.children().each (ind, elem) =>
      if elem.getAttribute("uuid") == @metadata.uuid
        zi = ind
        return false
    zi


  moveForward: (n = 1) ->
    for x in [1..n]
      next = @$rep.next()
      break if next.length is 0
      next.after(@$rep)
    @


  moveBack: (n = 1) ->
    for x in [1..n]
      prev = @$rep.prev()
      break if prev.length is 0
      prev.before(@$rep)
    @


  bringToFront: ->
    dom.$main.append @$rep


  sendToBack: ->
    dom.$main.prepend @$rep


  transform: {}


  swapFillAndStroke: ->
    swap = @data.stroke
    @attr
      'stroke': @data.fill
      'fill': swap
    @commit()


  eyedropper: (sample) ->
    @data.fill = sample.data.fill
    @data.stroke = sample.data.stroke
    @data['stroke-width'] = sample.data['stroke-width']
    @commit()


  bounds: ->
    cached = @boundsCached
    if cached isnt null and @caching
      return cached
    else
      xr = @xRange()
      yr = @yRange()
      @boundsCached = new Bounds(
        xr.min,
        yr.min,
        xr.length(),
        yr.length())


  boundsCached: null


  hideUI: ->
    ui.removePointHandles()


  refreshUI: ->
    @points.map (p) -> p.updateHandle()
    @redrawHoverTargets()

  overlaps: (other) ->

    # Checks for overlap with another shape.
    # Redirects to appropriate method.

    # I/P: Polygon/Circle/Rect
    # O/P: true or false

    @['overlaps' + other.type.capitalize()](other)


  lineSegmentsIntersect: (other) ->
    # Returns bool, whether or not this shape and that shape intersect or overlap
    # Short-circuits as soon as it finds true.
    #
    # I/P: Another shape that has lineSegments()
    # O/P: Boolean

    ms = @lineSegments() # My lineSegments
    os = other.lineSegments() # Other's lineSegments

    for mline in ms

      # The true parameter on bounds() tells mline to use its cached bounds.
      # It saves a lot of time and is okay to do in a situation like this where we're just going
      # through a for-loop and not changing the lines at all.
      #
      # Admittedly, it really only saves time below when it calls it for oline since
      # each mline is only being looked at once, but why not cache as much as possible? :)

      if mline instanceof CubicBezier
        mbounds = mline.bounds(true)

      a = if mline instanceof LineSegment then mline.a else mline.p1
      b = if mline instanceof LineSegment then mline.b else mline.p2

      if (other.contains a) or (other.contains b)
        return true

      for oline in os

        if mline instanceof CubicBezier or oline instanceof CubicBezier
          obounds = oline.bounds(true)
          continueChecking = mbounds.overlapsBounds(obounds)
        else
          continueChecking = true

        if continueChecking
          if mline.intersects(oline)
            return true
    return false


  lineSegmentIntersections: (other) ->
    # Returns an Array of tuple-Arrays of [intersection, point]
    intersections = []

    ms = @lineSegments() # My lineSegments
    os = other.lineSegments() # Other's lineSegments

    for mline in ms
      mbounds = mline.bounds(true) # Accept cached bounds since these aren't changing.

      for oline in os
        obounds = oline.bounds(true)

        # Only run the intersection algorithms for lines whose BOUNDS overlap.
        # This check makes lineSegmentIntersections an order of magnitude faster - most pairs never pass this point.

        #if mbounds.overlapsBounds(obounds)

        inter = mline.intersection oline

        if inter instanceof Posn
          # mline.source is the original point that makes up that line segment.
          intersections.push
            intersection: [inter],
            aline: mline
            bline: oline
            a: mline.source
            b: oline.source
        else if (inter instanceof Array and inter.length > 0)
          intersections.push
            intersection: inter
            aline: mline
            bline: oline
            a: mline.source
            b: oline.source

    intersections


  remove: ->
    @rep.remove()
    if @points isnt []
      @points.map (p) ->
        p.baseHandle?.remove()


  convertTo: (type) ->
    result = @["convertTo#{type}"]()
    result.eyedropper @
    result

  toString: ->
    "(#{@type} Monsvg object)"

  repToString: ->
    new XMLSerializer().serializeToString(@rep)


  carryOutTransformations: (transform = @data.transform, center = new Posn(0, 0)) ->

    ###
      We do things this way because fuck the transform attribute.

      Basically, when we commit shapes for the first time from some other file,
      if they have a transform attribute we effectively just alter the data
      that makes those shapes up so that they still look the same, but they no longer
      have a transform attr.
    ###

    attrs = transform.replace(", ", ",").split(" ").reverse()

    for attr in attrs
      key = attr.match(/[a-z]+/gi)?[0]
      val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")

      switch key
        when "scale"
          # A scale is a scale, but we also scale the stroke-width
          factor = parseFloat val
          @scale(factor, factor, center)
          @data["stroke-width"] *= factor

        when "translate"
          # A translate is simply a nudge
          val = val.split ","
          x = parseFloat val[0]
          y = if val[1]? then parseFloat(val[1]) else 0
          @nudge(x, -y)

        when "rotate"
          # Duh
          @rotate(parseFloat(val), center)
          @metadata.angle = 0




  applyTransform: (transform) ->

    console.log "apply transform"

    for attr in transform.split(" ")
      key = attr.match(/[a-z]+/gi)?[0]
      val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")

      switch key
        when "scale"
          val = parseFloat val
          if @transform.scale?
            @transform.scale *= val
          else
            @transform.scale = val

        when "translate"
          val = val.split ","
          x = parseFloat val[0]
          y = parseFloat val[1]
          x = parseFloat x
          y = parseFloat y
          if @transform.translate?
            @transform.translate.x += x
            @transform.translate.y += y
          else
            @transform.translate = { x: x, y: y }

        when "rotate"
          val = parseFloat val
          if @transform.rotate?
            @transform.rotate += val
            @transform.rotate %= 360
          else
            @transform.rotate = val

    @commit()


  setFill: (val) ->
    @data.fill = new Color val

  setStroke: (val) ->
    @data.stroke = new Color val

  setStrokeWidth: (val) ->
    @data['stroke-width'] = val


  setupToCanvas: (context) ->
    context.beginPath()
    context.fillStyle = "#{@data.fill}"
    if (@data['stroke-width']? > 0) and (@data.stroke?.hex != "none")
      context.strokeStyle = "#{@data.stroke}"
      context.lineWidth = parseFloat @data['stroke-width']
    else
      context.strokeStyle = "none"
      context.lineWidth = "0"
    context


  finishToCanvas: (context) ->
    context.closePath() if @points?.closed
    context.fill()# if @data.fill?
    context.stroke() if (@data['stroke-width'] > 0) and (@data.stroke?.hex != "none")
    context

  clearCachedObjects: ->

  lineSegments: ->



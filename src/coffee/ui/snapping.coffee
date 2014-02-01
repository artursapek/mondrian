###

  Snapping

        /
       /
      O
     /    o
    /
   /
  /

  Provides four main endpoints:
    toAnyOf
    toOneOf
    toThis
    toNothing

  ...with which you should be able to implement any sort of snapping behavior.

  Call any of these within a tool use snapping. Usually within the tool's activateModifier method.

  NOTE: toNothing gets called in all tearDown methods, so undoing snapping is usually already taken care of.
        It's more the calling it to begin with that has to be done.

###



ui.snap =


  toNothing: ->
    # Reset snapping to nothing
    @removeAnnotationLine()
    @supplementEvent = (e) -> e


  toAnyOf: (lines, tolerance, onUpdate = ->) ->
    # Snap to any or none of the given lines
    # When you do snap, it's because the cursor is within
    # the given tolerance of a certain line.
    #
    # If two or more lines are found to match,
    # take the closer one.
    @removeAnnotationLine()
    @supplementEvent = (e) -> e
    # Need to finish this.


  toOneOf: (lines, posnLevel = "client", onUpdate = ->) ->
    # Always snap to the closest of these lines
    @removeAnnotationLine()
    @supplementEvent = (e) ->
      e = cloneObject e
      distances = {}
      lines.map (l) ->
        perpDist = new Posn(e["#{posnLevel}X"], e["#{posnLevel}Y"]).perpendicularDistanceFrom(l)
        if perpDist?
          distances[perpDist[0]] = perpDist[1]

      snap = distances[Math.min.apply(@, Object.keys(distances).map(parseFloat))]
      e["#{posnLevel}X"] = snap.x
      e["#{posnLevel}Y"] = snap.y
      ui.cursor.currentPosn = snap
      onUpdate(e)
      e

  supplementForGrid: (e) ->
    e = cloneObject e
    cp = e.canvasPosnZoomed
    cp = @snapPointToGrid cp
    e

  snapPointToGrid: (p) ->
    freq = ui.grid.frequency
    p.x = p.x.toNearest freq.x, freq.x / 3
    p.y = p.y.toNearest freq.y, freq.y / 3
    p

  toThis: (line, onUpdate = ->) ->
    @removeAnnotationLine()
    # Always always always snap to this one line

  annotationLine: null

  removeAnnotationLine: ->
    # This just removes the old annotation line. It gets called every time the snapping method changes.
    @annotationLine?.remove()
    @annotationLine = null

  updateAnnotationLine: (a, b) ->
    if not @annotationLine?
      @annotationLine = ui.annotations.drawLine(a, b, 'rgba(73,130,224,0.3)')
    else
      @annotationLine.absorbA a
      @annotationLine.absorbB b
      @annotationLine.commit()

  presets:
    every45: (op, posnLevel) ->
      ui.snap.toOneOf([
        new Ray(op, 0)
        new Ray(op, 45)
        new Ray(op, 90)
        new Ray(op, 135)
        new Ray(op, 180)
        new Ray(op, 225)
        new Ray(op, 270)
        new Ray(op, 315)], posnLevel)



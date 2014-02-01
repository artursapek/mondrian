###

  Swatch is to Color as Point is to Posn

###


class Swatch extends Color
  constructor: (@r, @g, @b, @a = 1.0) ->
    if @r instanceof Color
      @g = @r.g
      @b = @r.b
      @a = @r.a
      @r = @r.r
    super @r, @g ,@b, @a
    @$rep = $("<div class=\"swatch\"></div>")
    @rep = @$rep[0]
    @refresh()
    @$rep.on "set", (event, color) =>
      @absorb color
      @refresh()
    @

  refresh: ->
    # TODO investigate this being called unnecessarily (select all shapes and see)
    if @r is null
      @rep.style.backgroundColor = ""
      @rep.style.border = ""
      @rep.setAttribute("empty", "")
      @rep.setAttribute("val", "empty")
    else
      @rep.style.backgroundColor = @toString()
      @rep.style.border = "1px solid #{@clone().darken(1.5).toHexString()}"
      @rep.removeAttribute("empty")
      @rep.setAttribute("val", @toString())

    if @type?
      @rep.setAttribute("type", @type)

      tiedTo = @tiedTo()
      if tiedTo instanceof Array
        for elem in @tiedTo()
          elem.data[@type] = @clone()
          elem.commit()

      else
        tiedTo.data[@type] = @clone()
        tiedTo.commit()


  tiedTo: -> ui.selection.elements.all

  type: null # "fill" or "stroke"

  appendTo: (selector) ->
    q(selector).appendChild(@rep)
    @

window.Swatch = Swatch




class SwatchDuo
  constructor: (@fill, @stroke) ->
    # I/P: two Swatch objects

    if @fill instanceof Monsvg
      if @fill.data.stroke is undefined
        @stroke = new Swatch(null)
      else
        @stroke = new Swatch @fill.data.stroke

      if @fill.data.fill is undefined
        @fill = new Swatch(null)
      else
        @fill = new Swatch @fill.data.fill

    @fill.type = "fill"
    @stroke.type = "stroke"

    @$rep = $("<div class=\"swatch-duo\"></div>")

    @$rep.append(@fill.$rep)
    @$rep.append(@stroke.$rep)
    @$rep.attr("key", @toString())

    @rep = @$rep[0]

  tiedTo: ->

  toString: ->
    "#{@fill.toHexString()}/#{@stroke.toHexString()}"



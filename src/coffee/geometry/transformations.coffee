class Transformations
  constructor: (@owner, @transformations) ->
    transform = @owner.rep.getAttribute "transform"
    @transformations.map (t) => t.family = @
    @parseExisting transform if transform?

  commit: ->
    @owner.data.transform = @toAttr()

  toAttr: ->
    @transformations.map((t) -> t.toAttr()).join " "

  toCSS: ->
    @transformations.map((t) -> t.toCSS()).join " "

  get: (key) ->
    f = @transformations.filter (t) -> t.key is key
    return f[0] if f.length > 0

  parseExisting: (transform) ->
    operations = transform.match /\w+\([^\)]*\)/g
    for op in operations
      # get the keyword, like "rotate" from "rotate(10)"
      keyword = op.match(/^\w+/g)[0]
      alreadyDefined = @get keyword
      if alreadyDefined?
        alreadyDefined.parse op
      else
        representative = {
          rotate: RotateTransformation
          scale:  ScaleTransformation
        }[keyword]
        if representative?
          newlyDefined = new representative().parse(op)
          newlyDefined.family = @
          @transformations.push newlyDefined

  applyAsCSS: (rep) ->
    og = "-#{@owner.origin.x} -#{@owner.origin.y}"
    tr = @toCSS()
    rep.style.transformOrigin = og
    rep.style.webkitTransformOrigin = og
    rep.style.mozTransformOrigin = og
    rep.style.transform = tr
    rep.style.webkitTransformOrigin = og
    rep.style.webkitTransform = tr
    rep.style.mozTransformOrigin = og
    rep.style.mozTransform = tr

class RotateTransformation
  constructor: (@deg, @family) ->

  key: "rotate"

  toAttr: ->
    "rotate(#{@deg.places 3} #{@family.owner.center().x.places 3} #{@family.owner.center().y.places 3})"

  toCSS: ->
    "rotate(#{@deg.places 3}deg)"

  rotate: (a) ->
    @deg += a
    @deg %= 360
    @

  parse: (op) ->
    [@deg, x, y] = op.match(/[\d\.]+/g).map parseFloat


class ScaleTransformation
  constructor: (@x = 1, @y = 1) ->

  key: "scale"

  toAttr: ->
    "scale(#{@x} #{@y})"

  toCSS: ->
    "scale(#{@x}, #{@y})"

  parse: (op) ->
    [@x, @y] = op.match(/[\d\.]+/g).map parseFloat

  scale: (x = 1, y = 1) ->
    @x *= x
    @y *= y

class TranslateTransformation
  constructor: (@x = 0, @y = 1) ->

  key: "translate"

  toAttr: ->
    "translate(#{@x} #{@y})"

  toCSS: ->
    "translate(#{@x}px, #{@y}px)"

  parse: (op) ->
    [@x, @y] = op.match(/[\-\d\.]+/g).map parseFloat

  nudge: (x, y) ->
    console.log x, y
    @x += x
    @y -= y



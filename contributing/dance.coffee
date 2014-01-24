$logo = $('#dancing-logo')

prefixer = (attr, val) ->
  attrs = {}
  attrs["-webkit-#{attr}"] = val
  attrs["-moz-#{attr}"]    = val
  attrs["-ms-#{attr}"]     = val
  attrs

setTransform = (vals) ->
  transform = ["X", "Y"].map (axis) ->
    "skew#{axis}(#{vals[axis]}deg)"
  transform.push("scaleX(#{Math.random() + 0.5})")
  transform.push("scaleY(#{Math.random() + 0.5})")

  $logo.css prefixer "transform", transform.join " "
  $logo.css
    left: (Math.random() * 200) - 100
    top: (Math.random() * 100) - 50



randomDeg = ->
  ((Math.random() * 80) - 40) / 2



randomValues = ->
  X: randomDeg()
  Y: randomDeg()

setInterval ->
  setTransform randomValues()
, 2300

setTransform randomValues()

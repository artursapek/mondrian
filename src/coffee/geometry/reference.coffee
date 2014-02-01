###

  Reference class

###

class Reference

  constructor: (attrs) ->
    for own k, x or attrs
      @[k] = x

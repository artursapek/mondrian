class Range
  constructor: (@min, @max) ->

  length: -> @max - @min

  contains: (n) ->
    n > @min and n < @max

  containsInclusive: (n, tolerance = 0) ->
    n >= @min - tolerance and n <= @max + tolerance

  intersects: (n) ->
    n == @min or n == @max

  fromList: (alon) ->
    @min = Math.min.apply(@, alon)
    @max = Math.max.apply(@, alon)
    @

  fromRangeList: (alor) ->
    mins = alor.map (r) -> r.min
    maxs = alor.map (r) -> r.max
    @min = Math.min.apply @, mins
    @max = Math.max.apply @, maxs
    @

  nudge: (amt) ->
    @min += amt
    @max += amt

  scale: (amt, origin) ->
    # Amt is an integer
    # Origin is also an integer
    @min += (@min - origin) * (amt - 1)
    @max += (@max - origin) * (amt - 1)

  toString: ->
    "[#{@min.places(4)},#{@max.places(4)}]"

  percentageOfValue: (v) ->
    (v - @min) / @length()



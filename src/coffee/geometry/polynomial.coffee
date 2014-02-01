###

  Polynomial

###

class Polynomial

  constructor: (@coefs) ->
    l = @coefs.length
    for own i, v of @coefs
      @["p#{l - i - 1}"] = v
    @coefs = @coefs.reverse()
    @


  tolerance: 1e-6


  accuracy: 6


  degrees: ->
    @coefs.length - 1


  interpolate: (xs, xy, n, offset, x) ->
    # I have no fucking idea what this does or how it does it.
    y = 0
    dy = 0
    ns = 0

    c = [n]
    d = [n]

    diff = Math.abs(x - xs[offset])
    for i in [0..n + 1]
      dift = Math.abs(x - xs[offset + i])

      if (dift < diff)
        ns = i
        diff = dift

      c[i] = d[i] = ys[offset + i]

    y = ys[offset + ns]
    ns -= 1

    for i in [1..m + 1]
      for i in [0.. n - m + 1]
        ho = xs[offset + i] - x
        hp = xs[offset + i + m] - x
        w = c[i + 1] - d[i]
        den = ho - hp

        if den is 0.0
          result =
            y: 0
            dy: 0
          break

        den = w / den
        d[i] = hp * den
        c[i] = ho * den

      dy = if (2 * (ns + 1) < (n - m)) then c[ns + 1] else d[ns -= 1]
      y += dy

    { y: y, dy: dy}


  eval: (x) ->
    result = 0
    for i in [@coefs.length - 1 .. 0]
      result = result * x + @coefs[i]

    result


  add: (that) ->
    newCoefs = []
    d1 = @degrees()
    d2 = that.degrees()
    dmax = Math.max(d1, d2)

    for i in [0..dmax]
      v1 = if (i <= d1) then @coefs[i] else 0
      v2 = if (i <= d2) then that.coefs[i] else 0

      newCoefs[i] = v1 + v2

    newCoefs = newCoefs.reverse()

    return new Polynomial(newCoefs)


  roots: ->
    switch (@coefs.length - 1)
      when 0
        return []
      when 1
        return @linearRoot()
      when 2
        return @quadraticRoots()
      when 3
        return @cubicRoots()
      when 4
        return @quarticRoots()
      else
        return []


  derivative: ->
    newCoefs = []

    for i in [1..@degrees()]
      newCoefs.push(i * @coefs[i])

    new Polynomial(newCoefs.reverse())


  bisection: (min, max) ->
    minValue = @eval(min)
    maxValue = @eval(max)

    if Math.abs(minValue) <= @tolerance
      return min
    else if Math.abs(maxValue) <= @tolerance
      return max
    else if (minValue * maxValue <= 0)
      tmp1 = Math.log(max - min)
      tmp2 = Math.LN10 * @accuracy
      iters = Math.ceil((tmp1 + tmp2) / Math.LN2)

      for i in [0..iters - 1]
        result = 0.5 * (min + max)
        value = @eval(result)

        if Math.abs(value) <= @tolerance
          break

        if (value * minValue < 0)
          max = result
          maxValue = value
        else
          min = result
          minValue = value

    result


  rootsInterval: (min, max) ->
    results = []

    if @degrees() is 1
      root = @bisection(min, max)
      if root?
        results.push root
    else
      deriv = @derivative()

      droots = deriv.rootsInterval(min, max)
      dlen = droots.length

      if dlen > 0
        root = @bisection(min, droots[0])
        results.push root if root?

        for i in [0..dlen - 2]
          r = droots[i]
          root = @bisection(r, droots[i + 1])
          results.push root if root?

        root = @bisection(droots[dlen - 1], max)
        results.push root if root?
      else
        root = @bisection(min, max)
        results.push root if root?

    results


  # Root functions
  # linear, quadratic, cubic

  linearRoot: ->
    result = []

    if @p1 isnt 0
      result.push -@p0 / @p1

    result


  quadraticRoots: ->
    results = []

    a = @p2
    b = @p1 / a
    c = @p0 / a
    d = b * b - 4 * c

    if d > 0
      e = Math.sqrt d
      results.push(0.5 * (-b + e))
      results.push(0.5 * (-b - e))
    else if d is 0
      results.push(0.5 * -b)

    results


  cubicRoots: ->
    results = []
    c3 = @p3
    c2 = @p2 / c3
    c1 = @p1 / c3
    c0 = @p0 / c3

    a = (3 * c1 - c2 * c2) / 3
    b = (2 * c2 * c2 * c2 - 9 * c1 * c2 + 27 * c0) / 27
    offset = c2 / 3
    discrim = b * b / 4 + a * a * a / 27
    halfB = b/2

    if (Math.abs(discrim)) <= 1e-6
      discrim = 0

    if discrim > 0
      e = Math.sqrt discrim

      tmp = -halfB + e

      root = if tmp >= 0 then Math.pow(tmp, 1/3) else -Math.pow(-tmp, 1/3)

      tmp = -halfB - e

      root += if tmp >= 0 then Math.pow(tmp, 1/3) else -Math.pow(-tmp, 1/3)

      results.push (root - offset)

    else if discrim < 0

      distance = Math.sqrt(-a/3)
      angle = Math.atan2(Math.sqrt(-discrim), -halfB) / 3
      cos = Math.cos angle
      sin = Math.sin angle
      sqrt3 = Math.sqrt(3)

      results.push(2*distance*cos - offset)
      results.push(-distance * (cos + sqrt3 * sin) - offset)
      results.push(-distance * (cos - sqrt3 * sin) - offset)
    else
      if halfB >= 0
        tmp = -Math.pow(halfB, 1/3)
      else
        tmp = Math.pow(-halfB, 1/3)

      results.push(2 * tmp - offset)

      results.push(-tmp - offset)

    return results


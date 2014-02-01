###

  Color

  A nice lil' class for representing and manipulating colors.

###



class Color

  constructor: (@r, @g, @b, @a = 1.0) ->

    if @r instanceof Color
      return @r
    if @r is null
      @hex = "none"
    else if @r is "none"
      @hex = "none"
      @r = null
      @g = null
      @b = null
    else
      if typeof @r is "string"
        if @r.charAt(0) == "#" or @r.length == 6
          # Convert hex to rgba
          @hex = @r.toUpperCase().replace("#", "")
          rgb = @hexToRGB @hex
          @r = rgb.r
          @g = rgb.g
          @b = rgb.b
        else if @r.match(/rgba?\(.*\)/gi)?
          # rgb(r,g,b)
          vals = @r.match(/[\d\.]+/gi)
          @r = vals[0]
          @g = vals[1]
          @b = vals[2]
          if vals[3]?
            @a = parseFloat vals[3]
          @hex = @rgbToHex @r, @g, @b


      else
        if not @g? and not @b?
          @g = @r
          @b = @r
        @hex = @rgbToHex @r, @g, @b

      @r = Math.min(@r, 255)
      @g = Math.min(@g, 255)
      @b = Math.min(@b, 255)

      @r = Math.max(@r, 0)
      @g = Math.max(@g, 0)
      @b = Math.max(@b, 0)

    if isNaN @r or isNaN @g or isNaN @b
      @r = 0 if isNaN @r
      @g = 0 if isNaN @g
      @b = 0 if isNaN @b
      debugger
      @updateHex()



  clone: -> new Color(@r, @g, @b)


  absorb: (color) ->
    @r = color.r
    @g = color.g
    @b = color.b
    @a = color.a
    @hex = color.hex
    @refresh?()
    @


  min: ->
    [@r, @g, @b].sort((a, b) -> a - b)[0]


  mid: ->
    [@r, @g, @b].sort((a, b) -> a - b)[1]


  max: ->
    [@r, @g, @b].sort((a, b) -> a - b)[2]


  midpoint: -> @max() / 2


  valToHex: (val) ->
    chars = '0123456789ABCDEF'
    chars.charAt((val - val % 16) / 16) + chars.charAt(val % 16)


  hexToVal: (hex) ->
    chars = '0123456789ABCDEF'
    chars.indexOf(hex.charAt(0)) * 16 + chars.indexOf(hex.charAt(1))


  rgbToHex: (r, g, b) ->
    "#{@valToHex r}#{@valToHex g}#{@valToHex b}"


  hexToRGB: (hex) ->
    r = @hexToVal hex.substring(0, 2)
    g = @hexToVal hex.substring(2, 4)
    b = @hexToVal hex.substring(4, 6)
    r: r
    g: g
    b: b


  recalculateHex: ->
    @hex = @rgbToHex(@r, @g, @b)


  darken: (amt) ->
    macro = (val) ->
      val / amt
    new Color(macro(@r), macro(@g), macro(@b))


  lightness: ->
    # returns float 0.0 - 1.0
    ((@min() + @max()) / 2) / 255


  saturation: ->
    max = @max()
    min = @min()
    d = max - min

    sat = if @lightness() >= 0.5 then d / (510 - max - min) else d / (max + min)
    sat = 1.0 if isNaN sat
    sat


  desaturate: (amt = 1.0) ->
    mpt = @midpoint()
    @r -= (@r - mpt) * amt
    @g -= (@g - mpt) * amt
    @b -= (@b - mpt) * amt
    @hex = @rgbToHex @r, @g, @b
    @


  lighten: (amt = 0.5) ->
    amt *= 255
    @r = Math.min(255, @r + amt)
    @g = Math.min(255, @g + amt)
    @b = Math.min(255, @b + amt)
    @hex = @rgbToHex @r, @g, @b
    @


  toRGBString: ->
    if @r is null
      return "none"
    else
      return "rgba(#{@r}, #{@g}, #{@b}, #{@a})"


  toHexString: ->
    "##{@hex}"


  toString: ->
    @removeNaNs() # HACK
    @toRGBString()


  removeNaNs: ->
    # HACK BUT IT WORKS FOR NOW LOL FUCK NAN
    if isNaN @r
      @r = 0
    if isNaN @g
      @g = 0
    if isNaN @b
      @b = 0


  equal: (c) ->
    @toHexString() == c.toHexString()


  updateHex: ->
    @hex = @rgbToHex @r, @g, @b





window.Color = Color




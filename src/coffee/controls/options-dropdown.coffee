###

  Options Dropdown

  ----------
  | 5px  V |
  ----------
  | 1px    |
  ----------
  | 2px    |
  ----------
  | 5px    |
  ----------
  | 10px   |
  ----------

###


# I started this for the stroke width control,
# and then I realized that a number-box would be better anyway.
# So this is sitting here now. Maybe I'll find a use for it.
# Excluding it from the source for now.

class OptionsDropdown

  constructor: (attrs) ->
    super attrs

    @$label = @$rep.find(".label")
    @$ul = @$rep.find("ul").first()

    @draw()




  draw: ->
    @$ul.empty()
    for option in @options
      @$ul.append $("<li>#{option}</li>")


  setOptions: (@options) ->
    @draw()


  read: ->
    @$label.text()


  write: (value) ->
    @$label.text value





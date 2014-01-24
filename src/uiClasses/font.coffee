###

  Management class for fontfaces

###

class Font
  constructor: (@name) ->

  toListItem: ->
    $("""
      <div class="dropdown-item" style="font-family: '#{@name}'">
        #{@name}
      </div>
    """)




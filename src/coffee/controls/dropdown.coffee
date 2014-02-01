###

  Dropdown control

###

class Dropdown extends Control
  constructor: (attrs) ->

    super attrs

    @$chosen = @$rep.find('.dropdown-chosen')
    @$list = @$rep.find('.dropdown-list')

    @options.map (o) =>
      @$list.append o.$rep

    if attrs.default?
      @$chosen.empty().append()

    @select @options[0]

    @close()

    @$chosen.click => @toggle()

  select: (@selected) ->
    # the ol reddit switch a roo
    @$chosen.children().first().appendTo(@$list)
    @$chosen.append(@selected.$rep)
    @refreshListeners()
    @callback(@selected.val)

  opened: false

  open: ->
    # Fucking beautiful plugin
    @$list.find('div').tsort()

    @opened = true
    @$list.show()
    @refreshListeners()

  close: ->
    @opened = false
    @$list.hide()

  refreshListeners: ->
    @$list.find('div').off('click')
    @$list.find('div').on('click', (e) =>
      @select @getOption e.target.innerHTML
      @close()
    )

  toggle: ->
    if @opened
      @close()
    else
      @open()

  getOption: (value) ->
    @options.filter((o) -> o.val is value)[0]


class DropdownOption
  constructor: (@val) ->
    @$rep = $("<div class=\"dropdown-item\">#{@val}</div>")


class FontFaceOption extends DropdownOption
  constructor: (@name) ->
    super

    @$rep.css
      'font-family': @name
      'font-size': '14px'




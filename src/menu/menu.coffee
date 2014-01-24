###

  Menubar, which manage MenuItems

###

ui.menu =

  # MenuItems
  menus: {}

  # MenuItems
  items: {}

  menu: (id) ->
    objectValues(@menus).filter((menu) -> menu.itemid == id)[0]

  item: (id) ->
    objectValues(@items).filter((item) -> item.itemid == id)[0]

  closeAllDropdowns: ->
    for own k, item of @menus
      item.closeDropdown()

  refresh: ->
    for own key, menu of @menus
      menu.refresh()


###

  MenuItem

  An item on the top program menu, like Open, Save... etc
  Template.

###

class Menu
  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

    @$rep = $("##{@itemid}")
    @rep = @$rep[0]

    @$dropdown = $("##{@itemid}-dropdown")
    @dropdown = @$dropdown[0]

    # Save this neffew in ui.menu. This is how we're gonna access it from now on.
    @dropdownSetup()

  refresh: ->
    @items().map -> @_refresh()

  refreshEnabledItems: ->
    @items().map ->
      if @enableWhen?
        if @enableWhen() then @enable() else @disable()


  refreshAfterVisible: ->
    # Slower operations get called in here
    # to prevent visible lag.
    @items().map -> @refreshAfterVisible?()

  items: ->
    @$rep.find('.menu-item').map ->
      ui.menu.item(@id)

  disabled: false

  dropdownOpen: false

  text: (val) ->
    @$rep.find("> [buttontext]").text(val)
    @

  _click: ->
    # This is standard for MenuItems: they open their dropdown.
    # You can also give it an onOpen method, which gets called
    # after the dropdown has opened.
    @toggleDropdown()
    ui.refreshUtilities()
    @click?()

  openDropdown: ->
    return if @dropdownOpen

    # You can't have more than one dropdown open at the same time
    ui.menu.closeAllDropdowns()

    # Make this button highlighted unconditionally
    # while the dropdown is open
    @$rep.attr("selected", "")

    @refresh()

    # Open the dropdown
    @$dropdown.show()
    @dropdownOpen = true

    trackEvent "Menu #{@itemid}", "Action (click)"

    # Call the refresh method
    async => @refreshAfterVisible()
    @

  closeDropdown: ->
    return if not @dropdownOpen

    @$rep.removeAttr("selected")
    @$rep.find("input:focus").blur()
    @$dropdown.hide()
    @dropdownOpen = false
    @onClose?()
    @

  toggleDropdown: ->
    if @dropdownOpen then @closeDropdown() else @openDropdown()

  show: ->
    @rep?.style.display = "block"
    @

  hide: ->
    @rep?.style.display = "none"
    @

  dropdownSetup: ->
    # Fill in
    # Use this to bind listeners/special things to special elements in the dropdown.
    # Basically, do special weird things in here.

  group: ->
    @$rep.closest(".menu-group")

  groupHide: ->
    @group()?.hide()

  groupShow: ->
    @group()?.css("display", "inline-block")



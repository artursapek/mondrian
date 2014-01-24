###

  A button in a menu dropdown.

  Simple shit. Just has a handful of methods.

    text
      Change what it says.

    action
      Change what it does.

    refresh
      Change other things about it
      when its dropdown gets opened.

    disable
      Disable it

    enable
      Enable it

###



class MenuItem
  constructor: (attrs) ->
    for i, x of attrs
      @[i] = x

    @$rep = $("##{@itemid}")
    @rep = @$rep[0]

    if @hotkey?
      ui.hotkeys.sets.app.down[@hotkey] = (e) =>
        e.preventDefault()
        @_refresh()
        return if @disabled
        @action(e)
        trackEvent "Menu item #{@itemid}", "Action (hotkey)"
        @owner()?.refresh()
        @$rep.addClass("down")
        @owner()?.$rep.addClass("down")

        if @hotkey.mentions "cmd"
          setTimeout =>
            @$rep.removeClass("down")
            @owner()?.$rep.removeClass("down")
            @_refresh()
          , 50

      if not (@hotkey.mentions "cmd")
        return if @disabled
        ui.hotkeys.sets.app.up[@hotkey] = (e) =>
          @$rep.removeClass("down")
          @owner()?.$rep.removeClass("down")
          @after?()
          @_refresh()



  _click: (e) ->
    @_refresh()
    return if @disabled
    @owner()?.closeDropdown() if @closeOnClick
    @owner()?.$rep.find("[selected]").removeAttr("selected")
    @action?(e)
    @owner()?.refreshEnabledItems()
    trackEvent "Menu item #{@itemid}", "Action (click)"


  closeOnClick: true


  save: ->
    # Fill in


  _refresh: ->
    @refresh?()
    if @enableWhen?
      if @enableWhen() then @enable() else @disable()


  refresh: ->
    # Fill in


  owner: ->
    ui.menu.menu(@$rep.closest(".menu").attr("id"))


  show: ->
    @$rep.show()
    $(".separator[visiblewith=\"#{@itemid}\"]").show()
    @


  hide: ->
    @$rep.hide()
    $(".separator[visiblewith=\"#{@itemid}\"]").hide()
    @


  disable: ->
    @disabled = true
    @$rep.addClass "disabled"
    @


  enable: ->
    @disabled = false
    @$rep.removeClass "disabled"
    @


  text: (val) ->
    @$rep.find("[buttontext]").text val


  group: ->
    @$rep.closest(".menu-group")


  groupHide: ->
    @group()?.hide()


  groupShow: ->
    @group()?.css("display", "inline-block")



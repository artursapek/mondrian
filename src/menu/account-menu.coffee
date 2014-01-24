setup.push ->

  ui.menu.menus.account = new Menu
    itemid: "account-menu"

    showAndFillIn: (email) ->
      @group().style.display = "inline-block"
      @$rep.find("span#logged-in-email").text email

    onClose: ->
      @$dropdown.attr("mode", "normal")

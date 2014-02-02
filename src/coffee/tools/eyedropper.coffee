###

  Eyedropper

###


tools.eyedropper = new Tool

  offsetX: 1
  offsetY: 15

  cssid: 'eyedropper'
  id: 'eyedropper'

  hotkey: 'I'

  click:
    elem_hoverTarget_point: (e) ->
      ui.utilities.color.sample e.elem
      for elem in ui.selection.elements.all
        elem.eyedropper e.elem
    background: (e) ->
      for elem in ui.selection.elements.all
        elem.data.fill = ui.colors.white
        elem.data.stroke = ui.colors.null
        elem.commit()


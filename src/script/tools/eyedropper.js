/*

  Eyedropper

*/


tools.eyedropper = new Tool({

  offsetX: 1,
  offsetY: 15,

  cssid: 'eyedropper',
  id: 'eyedropper',

  hotkey: 'I',

  click: {
    elem_hoverTarget_point(e) {
      ui.utilities.color.sample(e.elem);
      return (() => {
        let result = [];
        for (let elem of Array.from(ui.selection.elements.all)) {
          result.push(elem.eyedropper(e.elem));
        }
        return result;
      })();
    },
    background(e) {
      return Array.from(ui.selection.elements.all).map((elem) =>
        ((elem.data.fill = ui.colors.white),
        (elem.data.stroke = ui.colors.null),
        elem.commit()));
    }
  }
});


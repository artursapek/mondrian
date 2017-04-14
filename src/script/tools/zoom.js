/*

  Zoom tool

*/


tools.zoom = new Tool({

  offsetX: 5,
  offsetY: 5,

  cssid: 'zoom',
  id: 'zoom',

  hotkey: 'Z',

  ignoreDoubleclick: true,

  click: {
    all(e) {
      if (ui.hotkeys.modifiersDown.has("alt")) {
        ui.canvas.zoomOut(e.clientPosn);
      } else {
        ui.canvas.zoomIn(e.clientPosn);
      }
      return ui.refreshAfterZoom();
    }
  },

  rightClick: {
    all(e) { return ui.canvas.zoom100(); }
  },

  startDrag: {
    all(e) {
      return ui.dragSelection.start(new Posn(e));
    }
  },


  continueDrag: {
    all(e) {
      return ui.dragSelection.move(new Posn(e));
    }
  },


  stopDrag: {
    all(e) {
      if (ui.hotkeys.modifiersDown.has("alt")) {
        ui.dragSelection.end( () => ui.canvas.zoom100());
      } else if (e.which === 1) {
        ui.dragSelection.end(r => ui.canvas.zoomToFit(r));
      } else if (e.which === 3) {
        ui.dragSelection.end(() => ui.canvas.zoomOut());
      }
        //ui.dragSelection.end((r) -> ui.canvas.zoomToFit r)

      return Array.from(ui.elements).map((elem) =>
        elem.refreshUI());
    }
  }
});



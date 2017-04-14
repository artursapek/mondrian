/*

  Paw tool

  Pan around.

*/

tools.paw = new Tool({

  offsetX: 8,
  offsetY: 8,

  id:    'paw',
  cssid: 'paw',

  hotkey: 'space',

  setup() {
    // Ran into a crazy bug where the canvas normal suddenly had NaN
    // as its X value. Prevent that from happening

    if (isNaN(ui.canvas.normal.x)) {
      ui.canvas.normal.x = 0;
    }
    if (isNaN(ui.canvas.normal.y)) {
      return ui.canvas.normal.y = 0;
    }
  },

  tearDown() {},

  continueDrag: {
    all(e) {
      return ui.canvas.nudge(
        e.changeX * ui.canvas.zoom,
        e.changeY * ui.canvas.zoom);
    }
  },

  mousedown: {
    all() {
      return dom.toolCursorPlaceholder.setAttribute('tool', 'paw-clutch');
    }
  },

  mouseup: {
    all() {
      return dom.toolCursorPlaceholder.setAttribute('tool', 'paw');
    }
  }
});


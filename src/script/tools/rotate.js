/*

  Rotate

*/

tools.rotate = new Tool({

  cssid: 'crosshair',

  id: 'rotate',

  offsetX: 7,
  offsetY: 7,

  hotkey: 'R',

  setup() {
    this.$rndo = $("#r-nd-o");
    ui.transformer.onRotatingMode();
    this.setCenter(ui.transformer.center());
    return ui.selection.elements.on('changed', () => {
      return this.$rndo.hide();
    });
  },


  tearDown() {
    this.setCenter(undefined);
    return ui.transformer.offRotatingMode();
  },



  lastAngle: undefined,


  setCenter(center) {
    this.center = center;
    if (ui.selection.elements.all.length === 0) { return; }
    if (this.center != null) {
      return this.$rndo.show().css({
        left: (this.center.x - 6).px(),
        top: (this.center.y - 6).px()
      });
    } else {
      return this.$rndo.hide();
    }
  },



  click: {
    all(e) {
      return this.setCenter(new Posn(e.canvasX, e.canvasY));
    }
  },


  startDrag: {
    all(e) {
      if (this.center === undefined) {
        this.setCenter(ui.transformer.center());
      }
      return this.lastAngle = new Posn(e.canvasX, e.canvasY);
    }
  },


  continueDrag: {
    all(e) {
      let currentAngle = new Posn(e.canvasX, e.canvasY).angle360(this.center);
      let change = currentAngle - this.lastAngle;

      if (!isNaN(change)) {
        ui.selection.rotate(change, this.center);
      }

      return this.lastAngle = currentAngle;
    }
  },


  stopDrag: {
    all(e) {
      this.lastAngle = undefined;
      ui.selection.elements.all.map(p => p.redrawHoverTargets());

      archive.addMapEvent("rotate", ui.selection.elements.zIndexes(), {
        angle: ui.transformer.accumA,
        origin: ui.transformer.origin
      });

      // A rotation has stopped so reset the accumulated values
      return ui.transformer.resetAccum();
    }
  }
});


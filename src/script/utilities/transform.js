import ui from 'script/ui/ui';
import Utility from 'script/utilities/utility';

/*

  Transform utility

  Allows you to read and input changes to
  selected elements' dimensions and position.

*/



ui.utilities.transform = new Utility({

  setup() {
    this.rep = q("#transform-ut");

    this.canvas = q("#transform-ut canvas#preview-canvas");
    this.$canvas = $(this.canvas);

    this.origin = q("#transform-ut #origin-icon");
    this.$origin = $(this.origin);

    this.widthBracket  = q("#transform-ut #width-bracket");
    this.$widthBracket = $(this.widthBracket);

    this.heightBracket  = q("#transform-ut #height-bracket");
    this.$heightBracket = $(this.heightBracket);

    this.outline  = q("#transform-ut #subtle-blue-outline");
    this.$outline = $(this.outline);

    this.inputs = {
      originX: q("#transform-ut #origin-x-val"),
      originY: q("#transform-ut #origin-y-val"),
      width:   q("#transform-ut #width-val"),
      height:  q("#transform-ut #height-val")
    };

    this.context = this.canvas.getContext("2d");

    this.widthControl = new NumberBox({
      rep:   this.inputs.width,
      value: 0,
      min: 0.00001,
      places: 5,
      commit: val => {
        return this.alterVal("width", val);
      }
    });

    this.heightControl = new NumberBox({
      rep:   this.inputs.height,
      value: 0,
      min: 0.00001,
      places: 5,
      commit: val => {
        return this.alterVal("height", val);
      }
    });

    this.originXControl = new NumberBox({
      rep:   this.inputs.originX,
      value: 0,
      commit: val => {
        return this.alterVal("origin-x", val);
      }
    });

    this.originYControl = new NumberBox({
      rep:   this.inputs.originY,
      value: 0,
      commit: val => {
        return this.alterVal("origin-y", val);
      }
    });

    return this.hide();
  },

  shouldBeOpen() { return ui.selection.elements.all.length > 0; },

  trueVals: {
    x: 0,
    y: 0,
    width: 0,
    height: 0
  },

  alterVal(which, val) {
    // Ayyyy. Take the changes in the text box and make them to the elements.
    let center = ui.transformer.tl;

    switch (which) {
      case "width":
        let scale = val / this.trueVals.width;

        // NaN/Infinity check
        scale = scale.ensureRealNumber();
        ui.transformer.scale(scale, 1, center).redraw();
        ui.selection.scale(scale, 1, center);
        archive.addMapEvent("scale", ui.selection.elements.zIndexes(), { x: scale, y: 1, origin: center });
        return this.trueVals.width = val;
      case "height":
        scale = val / this.trueVals.height;

        // NaN/Infinity check
        scale = scale.ensureRealNumber();
        ui.transformer.scale(1, scale, center).redraw();
        ui.selection.scale(1, scale, center);
        archive.addMapEvent("scale", ui.selection.elements.zIndexes(), { x: 1, y: scale, origin: center });
        return this.trueVals.height = val;
      case "origin-x":
        let change = val - this.trueVals.x;
        ui.selection.nudge(change, 0);
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: change, y: 0 });
        return this.trueVals.x = val;
      case "origin-y":
        change = val - this.trueVals.y;
        ui.selection.nudge(0, -change);
        archive.addMapEvent("nudge", ui.selection.elements.zIndexes(), { x: 0, y: -change });
        return this.trueVals.y = val;
    }
  },


  refresh() {
    if (ui.selection.elements.empty()) { return; }
    let png = ui.selection.elements.exportAsPNG({trim: true});
    this.drawPreview(png.maxDimension(105).exportAsDataURI());
    return png.destroy();
  },


  refreshValues() {
    if (!this.visible) { return; }

    this.trueVals.x = ui.transformer.tl.x;
    this.trueVals.y = ui.transformer.tl.y;
    this.trueVals.width = ui.transformer.width;
    this.trueVals.height = ui.transformer.height;

    $(this.inputs.originX).val(this.trueVals.x.places(4));
    $(this.inputs.originY).val(this.trueVals.y.places(4));
    $(this.inputs.width).val(this.trueVals.width.places(4));
    return $(this.inputs.height).val(this.trueVals.height.places(4));
  },


  onshow() {
    return this.refreshValues();
  },


  clearPreview() {
    this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.origin.style.display = "none";
    this.widthBracket.style.display = "none";
    return this.heightBracket.style.display = "none";
  },


  drawPreview(datauri, bounds) {
    this.clearPreview();

    // This means we've selected nothing.
    if (datauri === "data:image/svg+xml;base64,") { return this.hide(); }

    this.show();

    let img = new Image();

    img.onload = () => {
      return this.context.drawImage(img,0,0);
    };

    img.src = datauri;

    let twidth = ui.transformer.width + 2;
    let theight = ui.transformer.height + 2;

    this.refreshValues();

    let scale = Math.min(105 / twidth, 105 / theight);

    let topOffset = (125 - (theight * scale)) / 2;
    let leftOffset = (125 - (twidth * scale)) / 2;

    this.$canvas.css({
      top: `${topOffset}px`,
      left: `${leftOffset}px`}).attr({
      height: (theight * scale) +  2,
      width: (twidth * scale) + 2
    });

    this.$origin.show().css({
      top: `${Math.round(topOffset) - 3}px`,
      left: `${Math.round(leftOffset) - 3}px`
    });

    this.$widthBracket.show().css({
      left: `${Math.round(leftOffset)}px`,
      width: `${(twidth * scale) - 2}px`
    });

    this.$heightBracket.show().css({
      top: `${Math.round(topOffset)}px`,
      height: `${(theight * scale) - 2}px`
    });

    return this.$outline.show().css({
      top: `${Math.round(topOffset)}px`,
      left: `${Math.round(leftOffset)}px`,
      height: (theight * scale) - 2,
      width: (twidth * scale) - 2
    });
  }
});




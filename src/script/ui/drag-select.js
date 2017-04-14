import ui from 'script/ui/ui';
// ui.dragSelection
//
// Drag rectangle over elements to select many
// Sort of a ghost-tool/utility


ui.dragSelection = {

  origin: {
    x: 0,
    y: 0
  },

  tl: {
    x: 0,
    y: 0
  },

  width: 0,
  height: 0,

  asRect() {
    return new Rect({
      x: dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x,
      y: dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y,
      width: this.width,
      height: this.height
    });
  },

  bounds() {
    return new Bounds(
      dom.$dragSelection.css('left').toFloat() - ui.canvas.normal.x,
      dom.$dragSelection.css('top').toFloat() - ui.canvas.normal.y,
      this.width, this.height);
  },

  start(posn) {
    this.origin.x = posn.x;
    this.origin.y = posn.y;
    return dom.$dragSelection.show();
  },

  move(posn) {
    this.tl = new Posn(Math.min(posn.x, this.origin.x), Math.min(posn.y, this.origin.y));
    this.width = Math.max(posn.x, this.origin.x) - this.tl.x - 1;
    this.height = Math.max(posn.y, this.origin.y) - this.tl.y;

    return dom.$dragSelection.css({
      top: this.tl.y,
      left: this.tl.x,
      width: this.width,
      height: this.height
    });
  },

  end(resultFunc, fuckingStopRightNow) {
    if (fuckingStopRightNow == null) { fuckingStopRightNow = false; }
    dom.$dragSelection.hide();

    if (fuckingStopRightNow) { return; }

    // Don't bother checking all the elements, this is
    // essentially a click on the background turned
    // to an accidental drag.
    if ((this.width < 3) && (this.height < 3)) {
      return ui.selection.elements.deselectAll();
    }

    let iz = 1 / ui.canvas.zoom;

    resultFunc(this.bounds().scale(iz, iz, ui.canvas.origin));

    // Selection bounds should disappear right away
    return dom.$dragSelection.hide().css({
      left: '',
      top: '',
      width: '',
      height: ''
    });
  }
};



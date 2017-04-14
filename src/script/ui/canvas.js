import setup from 'script/setup';
import Posn from 'script/geometry/posn';
/*

  The canvas

   _______________
  |               |
  |               |
  |               |
  |               |
  |               |
  |_______________|

  Manages canvas panning/zooming

*/


ui.canvas = {

  /*

  A note about zoom:

  There are three categories of elements in Mondrian regarding zoom:


  1 Annotation
    Elements who scale with zoom, but retain certain aesthetic features.
    They don't literally stretch with the zoom.

    Examples:
      HoverTargets: their position and size changes, but not their strokeWidth
      Points:       their position changes, but stay the same size
      The canvas:   its size changes but its 1px outline remains 1px


  2 Canvas
    Elements who scale with zoom entirely, meaning "real" zoom. Their stroke gets
    thicker, their position gets larger.

    Examples:
      The actual SVG elements being drawn.


  3 Client
    Elements who don't give a flying fuck how far you've zoomed in.
    These guys still alter their functionality a bit but 10,10 will always
    mean 10,10 visually. Sole difference between this and Annotation
    is the position of this relies not on the SVG Elements but the cursor/client.

    Examples:
      Drag selection
      Cursor

  */


  zoom: 1.0,

  width: 1000,
  height: 800,

  panLimitX() {
    return Math.max(500, ((ui.window.width() - (this.width * this.zoom)) / 2) + (ui.window.width() / 3));
  },

  panLimitY() {
    return Math.max(500, ((ui.window.height() - (this.height * this.zoom)) / 2) + (ui.window.height() / 3));
  },

  origin: new Posn(0, 0),

  normal: new Posn(-1, -1),

  show() {
    return dom.canvas.style.display = "block";
  },

  hide() {
    return dom.canvas.style.display = "none";
  },

  redraw(centering) {
    // Ay sus

    if (centering == null) { centering = false; }
    if (dom.main != null) {
      dom.main.style.width = (this.width).px();
    }
    if (dom.main != null) {
      dom.main.style.height = (this.height).px();
    }

    if (dom.main != null) {
      dom.main.setAttribute("width", this.width);
    }
    if (dom.main != null) {
      dom.main.setAttribute("height", this.height);
    }

    if (dom.main != null) {
      dom.main.setAttribute("viewbox", `0 0 ${this.width} ${this.height}`);
    }
    if (dom.main != null) {
      dom.main.setAttribute("enable-background", `new 0 0 ${this.width} ${this.height}`);
    }

    if (dom.grid != null) {
      dom.grid.setAttribute("width", this.width);
    }
    if (dom.grid != null) {
      dom.grid.setAttribute("height", this.height);
    }

    let transformScaleRule = {
      "transform": `scale(${ui.canvas.zoom})`,
      "-webkit-transform": `scale(${ui.canvas.zoom})`,
      "-moz-transform": `scale(${ui.canvas.zoom})`
    };

    dom.$main.css(transformScaleRule);
    dom.$grid.css(transformScaleRule);

    let stretch = e => {
      e.style.width = (this.width * ui.canvas.zoom).px();
      return e.style.height = (this.height * ui.canvas.zoom).px();
    };

    [dom.bg, dom.annotations, dom.hoverTargets].map(stretch);

    let ww = ui.window.width();
    let wh = ui.window.height();

    if (centering) {
      let diff;
      if (this.width < ww) {
        diff = ww - this.width;
        this.normal.x = diff / 2;
      }

      if (this.height < wh) {
        diff = wh - this.height;
        this.normal.y = diff / 2;
      }
    }

    this.refreshPosition();
    return this;
  },

  nudge(x, y) {
    // Nudge the canvas a certain amount.
    //
    // I/P:
    //   x: number
    //   y: number
    //
    // No O/P

    this.normal = this.normal.add(new Posn(x, -y));
    this.ensureVisibility();
    this.snapToIntegers();
    return this.refreshPosition();
  },

  snapToIntegers() {
    this.normal.x = Math.round(this.normal.x);
    return this.normal.y = Math.round(this.normal.y);
  },

  ensureVisibility() {
    let limitX = this.panLimitX();
    let limitY = this.panLimitY();

    let width = ui.window.width();
    let height = ui.window.height();

    if (this.normal.x > limitX) {
      this.normal.x = limitX;
    }
    if (this.normal.x < ((-limitX - (this.width * this.zoom)) + width)) {
      this.normal.x = (-limitX - (this.width * this.zoom)) + width;
    }
    if (this.normal.y > limitY) {
      this.normal.y = limitY;
    }
    if (this.normal.y < ((-limitY - (this.height * this.zoom)) + height)) {
      this.normal.y = (-limitY - (this.height * this.zoom)) + height;
    }
    return this.refreshPosition();
  },


  refreshPosition() {
    if (dom.canvas != null) {
      dom.canvas.style.left = this.normal.x;
    }
    if (dom.canvas != null) {
      dom.canvas.style.top = this.normal.y;
    }
    ui.uistate.set('normal', this.normal);
    return this;
  },


  setZoom(zoom, origin) {
    // Set the zoom level, sus
    //
    // I/P:
    //   amt: float (1.0 == 100%)
    //   origin: client-level posn origin for the transformation
    //
    // No O/P
    //
    // NOTE: For things to work properly, you must call
    // ui.refreshAfterZoom() when you're done zooming.
    //
    // This doesn't do it automatically because often the user will
    // zoom more than once before even touching the cursor again,
    // so we don't want to do unnecessary work redrawing the hover
    // targets at each interval.
    //
    // This should just always be called at the appropriate
    // time in every tool/utility which can zoom (not many)

    if (origin == null) { origin = ui.window.center(); }
    let canvasPosnAtOrigin = lab.conversions.posn.clientToCanvasZoomed(origin);

    ui.selection.points.hide();

    // Change the zoom level
    this.zoom = zoom;
    this.redraw();
    ui.transformer.redraw(true);

    // Realign the image so the same posn is under the cursor as before we zoomed
    this.alignWithClient(canvasPosnAtOrigin, origin);

    // Make sure the canvas is within the visible limits in any direction
    return this.ensureVisibility();
  },


  center() {
    return this.normal.add(new Posn((this.width * this.zoom) / 2, (this.height * this.zoom) / 2));
  },


  centerOn(posn) {
    posn = posn.subtract(this.center());
    this.normal.x += posn.x;
    this.normal.y += posn.y;
    return this.refreshPosition();
  },


  alignWithClient(canvasZoomedPosn, clientPosn) {
    let canvasEquivalentOfGivenPosn = lab.conversions.posn.clientToCanvasZoomed(clientPosn);
    return this.nudge((canvasEquivalentOfGivenPosn.x - canvasZoomedPosn.x) * this.zoom,
           (canvasZoomedPosn.y - canvasEquivalentOfGivenPosn.y) * this.zoom);
  },

  posnInCenterOfWindow() {
    return ui.window.center().subtract(this.normal).setZoom(ui.canvas.zoom);
  },


  zoomIn(o) {
    return this.setZoom(this.zoom * 1.15, o);
  },


  zoomOut(o) {
    return this.setZoom(this.zoom * 0.85, o);
  },


  zoom100() {
    this.setZoom(1);
    return this.centerOn(ui.window.center());
  },


  zoomToFit(bounds) {
    let oldnormal = this.normal.clone();
    let center = bounds.center();

    let widthChange = (ui.window.width() / this.zoom) / bounds.width;
    let heightChange = (ui.window.height() / this.zoom) / bounds.height;

    let zoomAmt = Math.min(widthChange, heightChange);
    this.setZoom(ui.canvas.zoom * zoomAmt);

    ui.window.centerOn(center);

    return async(() => ui.refreshAfterZoom());
  },

  petrified: false,

  petrify() {
    this.petrified = true;
    let $mainpetrified = dom.$main.clone();
    $mainpetrified.attr('id', 'main-petrified');
    dom.$hoverTargets.hide();
    dom.$annotations.hide();
    return dom.$main.hide().after($mainpetrified);
  },

  depetrify() {
    this.petrified = false;
    dom.$hoverTargets.show();
    dom.$annotations.show();
    return dom.$main.show().next().remove();
  }
};


setup.push(() => ui.canvas.redraw());


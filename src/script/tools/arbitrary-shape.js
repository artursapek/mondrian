import tools from 'script/tools/tools';
import Tool from 'script/tools/tool';
import Path from 'script/geometry/path';
import Bounds from 'script/geometry/bounds';
import ui from 'script/ui/ui';
/*

  Arbitrary Shape Tool

  A subclass of Tool that performs a simple action: draw a hard-coded shape
  from the startDrag point to the endDrag point.

  Basically this is an abstraction. It's used by the Ellipse and Rectangle tools.

*/


export default class ArbitraryShapeTool extends Tool {
  static initClass() {
  
    this.prototype.drawing = false;
    this.prototype.cssid = 'crosshair';
  
    this.prototype.offsetX = 7;
    this.prototype.offsetY = 7;
  
    this.prototype.ignoreDoubleclick = true;
  
    this.prototype.started = null;
  
    // This is what gets defined as the shape it draws.
    // It should be a string of points
    this.prototype.template = null;
  
    this.prototype.startDrag = {
      all(e) {
        this.started = e.canvasPosnZoomed;
  
        this.drawing = new Path({
          stroke: ui.stroke.clone(),
          fill: ui.fill.clone(),
          'stroke-width': ui.uistate.get('strokeWidth'),
          d: this.template
        });
  
        this.drawing.virgin = this.virgin();
  
        this.drawing.hide();
        this.drawing.appendTo("#main");
        return this.drawing.commit();
      }
    };
  
  
    this.prototype.continueDrag = {
      all(e) {
        let ftb = new Bounds(e.canvasPosnZoomed, this.started);
        if (e.shiftKey) {
          ftb = new Bounds(this.started, e.canvasPosnZoomed.squareUpAgainst(this.started));
        }
        if (e.altKey) {
          ftb.centerOn(this.started);
          ftb.scale(2, 2, this.started);
        }
  
        this.drawing.show();
        this.drawing.fitToBounds(ftb);
        return this.drawing.commit();
      }
    };
  
    this.prototype.stopDrag = {
      all() {
        this.drawing.cleanUpPoints();
        archive.addExistenceEvent(this.drawing.rep);
  
        this.drawing.redrawHoverTargets();
  
        ui.selection.elements.select(this.drawing);
  
        return this.drawing = false;
      }
    };
  }

  constructor(attrs) {
    super(attrs);
  }

  tearDown() {
    return this.drawing = false;
  }
}
ArbitraryShapeTool.initClass();




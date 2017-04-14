import Monsvg from 'script/geometry/monsvg'

/*

  HoverTarget

*/


class HoverTarget extends Monsvg {
  static initClass() {
    this.prototype.type = 'path';
  }

  constructor(a, b1, width) {
    // I/P: a: First point
    //      b: Second point
    //      width: stroke-width to be added to

    // Default width is always 1
    this.a = a;
    this.b = b1;
    this.width = width;
    if ((this.width == null)) {
      this.width = 1;
    }

    this.owner = this.b.owner;

    // Convert SmoothTo's to independent CurveTo's
    let b = this.b instanceof SmoothTo ? this.b.toCurveTo() : this.b;


    // Standalone path. MoveTo precessor point, and make the current one.
    // This way it exactly represents a single line-segment between two points on the path.
    this.d = `M${this.a.x * ui.canvas.zoom},${this.a.y * ui.canvas.zoom} ${b.toStringWithZoom()}`;

    // Build the data object, just a bunch of defaults.
    this.data = {
      fill: "none",
      stroke: "rgba(75, 175, 255, 0.0)",
      "stroke-width": 4 / ui.canvas.zoom,
      d: this.d
    };

    // Store under second point.
    this.b.hoverTarget = this;

    super(this.data);

    // This class should be as easy to use as possible, so just append it right away.
    // False for don't track.
    this.appendTo('#hover-targets', false);

    // Keeping track of a few things for the cursor-tracking events.

    this.rep.setAttribute('a', this.a.at);
    this.rep.setAttribute('b', this.b.at);
    this.rep.setAttribute('owner', this.owner.metadata.uuid);
  }


  highlight() {
    ui.unhighlightHoverTargets();
    this.a.hover();
    this.b.hover();
    this.attr({
      "stroke-width": 5,
      stroke: "#4981e0"
    });
    ui.hoverTargetsHighlighted.push(this);
    return this.commit();
  }


  unhighlight() {
    this.attr({
      "stroke-width": 5,
      stroke: "rgba(75, 175, 255, 0.0)"
    });
    return this.commit();
  }


  active() {
    this.a.baseHandle.setAttribute('active', '');
    return this.b.baseHandle.setAttribute('active', '');
  }


  nudge(x, y) {
    this.a.nudge(x, y);
    this.b.nudge(x, y);

    this.owner.commit();
    this.unhighlight();
    return this.constructor(this.a, this.b, this.width);
  }
}
HoverTarget.initClass();





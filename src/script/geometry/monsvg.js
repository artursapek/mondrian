import ui from 'script/ui/ui';
import Bounds from 'script/geometry/bounds';
import Range from 'script/geometry/range';
/*

    Mondrian SVG library

    Artur Sapek 2012 - 2017

*/

export default class Monsvg {
  static initClass() {
    this.prototype.points = [];
    this.prototype.transform = {};
    this.prototype.boundsCached = null;
  }

  // MonSvg
  //
  // Over-arching class for all vector objects
  //
  // I/P : data Object of SVG element's attributes
  //
  // O/P : self
  //
  // Subclasses:
  //   Line
  //   Rect
  //   Circle
  //   Polygon
  //   Path


  constructor(data) {

    // Create SVG element representation
    // Set up metadata
    //
    // No I/P
    //
    // O/P : self

    if (data == null) { data = {}; }
    this.data = data;
    this.rep = this.toSVG();
    this.$rep = $(this.rep);

    this.metadata = {
      angle: 0,
      locked: false
    };

    if (!this.data.dontTrack) {
      this.metadata.uuid = uuid();
    }

    this.rep.setAttribute('uuid', this.metadata.uuid);

    this.validateColors();

    if (this.type !== "text") {
      this.data = $.extend({
        fill:   new Color("none"),
        stroke: new Color("none")
      }
      , this.data);
    }

    // This is used to track landmark changes to @data
    // for the archive. Consider a user selecting a few elements
    // and dragging around on the color picker until they like what
    // they see. There's no way in hell we're gonna store every
    // single color they hovered over while happily dragging around.
    //
    // So we keep two copies of @data. The second is called @dataArchived.
    // Here we set it for the first time.

    this.updateDataArchived();

    // Apply
    if (this.data["mondrian:angle"] != null) {
      this.metadata.angle = parseFloat(this.data["mondrian:angle"], 10);
    }


    /*
    if @data.transform?
      attrs = @data.transform.split(" ")
      for attr in attrs
        key = attr.match(/[a-z]+/gi)?[0]
        val = attr.match(/\([\-\d\,\.]*\)/gi)?[0].replace(/[\(\)]/gi, "")
      @transform[key] = val.replace(/[\(\)]/gi, "")
      *console.log "saved #{attr} as #{key} #{val}"
  */
  }


  commit() {
    // Commit any changes to its representation in the DOM
    //
    // No I/P
    // O/P: self

    /*
    newTransform = []

    for own key, val of @transform
      if key is "translate"
        newTransform.push "#{key}(#{val.x},#{val.y})"
      else
        newTransform.push "#{key}(#{val})"

    @data.transform = newTransform.join(" ")
    */

    for (let key in this.data) {
      let val = this.data[key];
      if (key === "") {
        delete this.data[""];
      } else {
        if (`${val}`.mentions("NaN")) {
          throw new Error(`NaN! Ack. Attribute = ${key}, Value = ${val}`);
        }
        this.rep.setAttribute(key, val);
      }
    }

    if (this.metadata.angle === 0) {
      this.rep.removeAttribute('mondrian:angle');
    } else {
      if (this.metadata.angle < 0) {
        this.metadata.angle += 360;
      }
      this.rep.setAttribute('mondrian:angle', this.metadata.angle);
    }

    return this;
  }

  updateDataArchived(attr) {
    // If no attr is provided simply copy the new values in @data to @dataArchived
    // If there is, only copy over that one attribute.
    if (attr != null) {
      return this.dataArchived[attr] = this.data[attr];
    } else {
      return this.dataArchived = cloneObject(this.data);
    }
  }


  toSVG() {
    // Return the SVG DOM element that this Monsvg object represents
    // We need to use the svg namespace for the element to behave properly
    let self = document.createElementNS('http://www.w3.org/2000/svg', this.type);
    for (let key in this.data) {
      let val = this.data[key];
      if (key !== "") { self.setAttribute(key, val); }
    }
    return self;
  }


  validateColors() {
    // Convert color strings to Color objects
    if ((this.data.fill != null) && !(this.data.fill instanceof Color)) {
      this.data.fill = new Color(this.data.fill);
    }
    if ((this.data.stroke != null) && !(this.data.stroke instanceof Color)) {
      this.data.stroke = new Color(this.data.stroke);
    }
    if ((this.data["stroke-width"] == null)) {
      return this.data["stroke-width"] = 1;
    }
  }


  center() {
    // Returns the center of a cluster of posns
    //
    // O/P: Posn

    let xr = this.xRange();
    let yr = this.yRange();
    return new Posn(xr.min + ((xr.max - xr.min) / 2), yr.min + ((yr.max - yr.min) / 2));
  }

  queryPoint(rep) {
    return this.points.filter(a => a.baseHandle === rep)[0];
  }

  queryAntlerPoint(rep) {
    return this.antlerPoints.filter(a => a.baseHandle === rep)[0];
  }

  show() { return this.rep.style.display = "block"; }

  hide() { return this.rep.style.display = "none"; }

  showPoints() {
    this.points.map(point => point.show());
    return this;
  }

  hidePoints() {
    this.points.map(point => point.hide());
    return this;
  }

  unhoverPoints() {
    this.points.map(point => point.unhover());
    return this;
  }

  removePoints() {
    this.points.map(point => point.clear());
    return this;
  }

  unremovePoints() {
    this.points.map(point => point.unclear());
    return this;
  }


  destroyPoints() {
    return this.points.map(p => p.remove());
  }


  removeHoverTargets() {
    return; // TODO
    let existent = qa(`svg#hover-targets [owner='${this.metadata.uuid}']`);
    return Array.from(existent).map((ht) =>
      ht.remove());
  }


  redrawHoverTargets() {
    return; // TODO
    this.removeHoverTargets();
    this.points.map(p => new HoverTarget(p.prec, p));
    return this;
  }



  topLeftBound() {
    return new Posn(this.xRange().min, this.yRange().min);
  }

  topRightBound() {
    return new Posn(this.xRange().max, this.yRange().min);
  }

  bottomRightBound() {
    return new Posn(this.xRange().max, this.yRange().max);
  }

  bottomLeftBound() {
    return new Posn(this.xRange().min, this.yRange().max);
  }

  attr(data) {
    return (() => {
      let result = [];
      for (let key in data) {
        let val = data[key];
        if (typeof val === 'function') {
          result.push(this.data[key] = val(this.data[key]));
        } else {
          result.push(this.data[key] = val);
        }
      }
      return result;
    })();
  }


  appendTo(selector, track) {
    let target;
    if (track == null) { track = true; }
    if (typeof selector === "string") {
      target = q(selector);
    } else {
      target = selector;
    }
    target.appendChild(this.rep);
    if (track) {
      if (!ui.elements.has(this)) {
        ui.elements.push(this);
      }
    }
    return this;
  }

  clone() {
    //@commit()
    let cloneData = cloneObject(this.data);
    let cloneTransform = cloneObject(this.transform);
    delete cloneData.id;
    let clone = new this.constructor(cloneData);
    clone.transform = cloneTransform;
    return clone;
  }

  delete() {
    this.rep.remove();
    ui.elements = ui.elements.remove(this);
    return async(() => {
      this.destroyPoints();
      this.removeHoverTargets();
      if (this.group) {
        return this.group.delete();
      }
    });
  }

  zIndex() {
    let zi = 0;
    dom.$main.children().each((ind, elem) => {
      if (elem.getAttribute("uuid") === this.metadata.uuid) {
        zi = ind;
        return false;
      }
    });
    return zi;
  }


  moveForward(n) {
    if (n == null) { n = 1; }
    for (let x = 1, end = n, asc = 1 <= end; asc ? x <= end : x >= end; asc ? x++ : x--) {
      let next = this.$rep.next();
      if (next.length === 0) { break; }
      next.after(this.$rep);
    }
    return this;
  }


  moveBack(n) {
    if (n == null) { n = 1; }
    for (let x = 1, end = n, asc = 1 <= end; asc ? x <= end : x >= end; asc ? x++ : x--) {
      let prev = this.$rep.prev();
      if (prev.length === 0) { break; }
      prev.before(this.$rep);
    }
    return this;
  }


  bringToFront() {
    return dom.$main.append(this.$rep);
  }


  sendToBack() {
    return dom.$main.prepend(this.$rep);
  }


  swapFillAndStroke() {
    let swap = this.data.stroke;
    this.attr({
      'stroke': this.data.fill,
      'fill': swap
    });
    return this.commit();
  }


  eyedropper(sample) {
    this.data.fill = sample.data.fill;
    this.data.stroke = sample.data.stroke;
    this.data['stroke-width'] = sample.data['stroke-width'];
    return this.commit();
  }


  bounds() {
    let cached = this.boundsCached;
    if ((cached !== null) && this.caching) {
      return cached;
    } else {
      let xr = this.xRange();
      let yr = this.yRange();
      return this.boundsCached = new Bounds(
        xr.min,
        yr.min,
        xr.length(),
        yr.length());
    }
  }


  hideUI() {
    return ui.removePointHandles();
  }


  refreshUI() {
    this.points.map(p => p.updateHandle());
    return this.redrawHoverTargets();
  }

  overlaps(other) {

    // Checks for overlap with another shape.
    // Redirects to appropriate method.

    // I/P: Polygon/Circle/Rect
    // O/P: true or false

    return this[`overlaps${other.type.capitalize()}`](other);
  }


  lineSegmentsIntersect(other) {
    // Returns bool, whether or not this shape and that shape intersect or overlap
    // Short-circuits as soon as it finds true.
    //
    // I/P: Another shape that has lineSegments()
    // O/P: Boolean

    let ms = this.lineSegments(); // My lineSegments
    let os = other.lineSegments(); // Other's lineSegments

    for (let mline of Array.from(ms)) {

      // The true parameter on bounds() tells mline to use its cached bounds.
      // It saves a lot of time and is okay to do in a situation like this where we're just going
      // through a for-loop and not changing the lines at all.
      //
      // Admittedly, it really only saves time below when it calls it for oline since
      // each mline is only being looked at once, but why not cache as much as possible? :)

      var mbounds;
      if (mline instanceof CubicBezier) {
        mbounds = mline.bounds(true);
      }

      let a = mline instanceof LineSegment ? mline.a : mline.p1;
      let b = mline instanceof LineSegment ? mline.b : mline.p2;

      if ((other.contains(a)) || (other.contains(b))) {
        return true;
      }

      for (let oline of Array.from(os)) {

        var continueChecking;
        if (mline instanceof CubicBezier || oline instanceof CubicBezier) {
          let obounds = oline.bounds(true);
          continueChecking = mbounds.overlapsBounds(obounds);
        } else {
          continueChecking = true;
        }

        if (continueChecking) {
          if (mline.intersects(oline)) {
            return true;
          }
        }
      }
    }
    return false;
  }


  lineSegmentIntersections(other) {
    // Returns an Array of tuple-Arrays of [intersection, point]
    let intersections = [];

    let ms = this.lineSegments(); // My lineSegments
    let os = other.lineSegments(); // Other's lineSegments

    for (let mline of Array.from(ms)) {
      let mbounds = mline.bounds(true); // Accept cached bounds since these aren't changing.

      for (let oline of Array.from(os)) {
        let obounds = oline.bounds(true);

        // Only run the intersection algorithms for lines whose BOUNDS overlap.
        // This check makes lineSegmentIntersections an order of magnitude faster - most pairs never pass this point.

        //if mbounds.overlapsBounds(obounds)

        let inter = mline.intersection(oline);

        if (inter instanceof Posn) {
          // mline.source is the original point that makes up that line segment.
          intersections.push({
            intersection: [inter],
            aline: mline,
            bline: oline,
            a: mline.source,
            b: oline.source
          });
        } else if (inter instanceof Array && (inter.length > 0)) {
          intersections.push({
            intersection: inter,
            aline: mline,
            bline: oline,
            a: mline.source,
            b: oline.source
          });
        }
      }
    }

    return intersections;
  }


  remove() {
    this.rep.remove();
    if (this.points !== []) {
      return this.points.map(p => p.baseHandle != null ? p.baseHandle.remove() : undefined);
    }
  }


  convertTo(type) {
    let result = this[`convertTo${type}`]();
    result.eyedropper(this);
    return result;
  }

  toString() {
    return `(${this.type} Monsvg object)`;
  }

  repToString() {
    return new XMLSerializer().serializeToString(this.rep);
  }


  carryOutTransformations(transform, center) {

    let key, val;
    if (transform == null) { ({ transform } = this.data); }
    if (center == null) { center = new Posn(0, 0); }
    /*
      We do things this way because fuck the transform attribute.

      Basically, when we commit shapes for the first time from some other file,
      if they have a transform attribute we effectively just alter the data
      that makes those shapes up so that they still look the same, but they no longer
      have a transform attr.
    */

    let attrs = transform.replace(", ", ",").split(" ").reverse();

    return Array.from(attrs).map((attr) =>
      ((key = __guard__(attr.match(/[a-z]+/gi), x1 => x1[0])),
      (val = __guard__(attr.match(/\([\-\d\,\.]*\)/gi), x2 => x2[0].replace(/[\(\)]/gi, ""))),

      (() => { switch (key) {
        case "scale":
          // A scale is a scale, but we also scale the stroke-width
          let factor = parseFloat(val);
          this.scale(factor, factor, center);
          return this.data["stroke-width"] *= factor;

        case "translate":
          // A translate is simply a nudge
          val = val.split(",");
          let x = parseFloat(val[0]);
          let y = (val[1] != null) ? parseFloat(val[1]) : 0;
          return this.nudge(x, -y);

        case "rotate":
          // Duh
          this.rotate(parseFloat(val), center);
          return this.metadata.angle = 0;
      } })()));
  }




  applyTransform(transform) {

    console.log("apply transform");

    for (let attr of Array.from(transform.split(" "))) {
      let key = __guard__(attr.match(/[a-z]+/gi), x1 => x1[0]);
      let val = __guard__(attr.match(/\([\-\d\,\.]*\)/gi), x2 => x2[0].replace(/[\(\)]/gi, ""));

      switch (key) {
        case "scale":
          val = parseFloat(val);
          if (this.transform.scale != null) {
            this.transform.scale *= val;
          } else {
            this.transform.scale = val;
          }
          break;

        case "translate":
          val = val.split(",");
          let x = parseFloat(val[0]);
          let y = parseFloat(val[1]);
          x = parseFloat(x);
          y = parseFloat(y);
          if (this.transform.translate != null) {
            this.transform.translate.x += x;
            this.transform.translate.y += y;
          } else {
            this.transform.translate = { x, y };
          }
          break;

        case "rotate":
          val = parseFloat(val);
          if (this.transform.rotate != null) {
            this.transform.rotate += val;
            this.transform.rotate %= 360;
          } else {
            this.transform.rotate = val;
          }
          break;
      }
    }

    return this.commit();
  }


  setFill(val) {
    return this.data.fill = new Color(val);
  }

  setStroke(val) {
    return this.data.stroke = new Color(val);
  }

  setStrokeWidth(val) {
    return this.data['stroke-width'] = val;
  }


  setupToCanvas(context) {
    context.beginPath();
    context.fillStyle = `${this.data.fill}`;
    if (((this.data['stroke-width'] != null) > 0) && ((this.data.stroke != null ? this.data.stroke.hex : undefined) !== "none")) {
      context.strokeStyle = `${this.data.stroke}`;
      context.lineWidth = parseFloat(this.data['stroke-width']);
    } else {
      context.strokeStyle = "none";
      context.lineWidth = "0";
    }
    return context;
  }


  finishToCanvas(context) {
    if (this.points != null ? this.points.closed : undefined) { context.closePath(); }
    context.fill();// if @data.fill?
    if ((this.data['stroke-width'] > 0) && ((this.data.stroke != null ? this.data.stroke.hex : undefined) !== "none")) { context.stroke(); }
    return context;
  }

  clearCachedObjects() {}

  lineSegments() {}
}
Monsvg.initClass();



function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}



/*

  HoverTarget

*/

/*
export class HoverTarget extends Monsvg {
  static initClass() {
    this.prototype.type = 'path';
  }

  constructor(a, b, width) {
    // I/P: a: First point
    //      b: Second point
    //      width: stroke-width to be added to

    // Default width is always 1
    if ((width == null)) {
      width = 1;
    }


    // Convert SmoothTo's to independent CurveTo's
    //b = b instanceof SmoothTo ? b.toCurveTo() : b;


    // Standalone path. MoveTo precessor point, and make the current one.
    // This way it exactly represents a single line-segment between two points on the path.
    let d = `M${a.x * ui.canvas.zoom},${a.y * ui.canvas.zoom} ${b.toStringWithZoom()}`;

    // Build the data object, just a bunch of defaults.
    let data = {
      fill: "none",
      stroke: "rgba(75, 175, 255, 0.0)",
      "stroke-width": 4 / ui.canvas.zoom,
      d
    };

    super(data);

    this.data = data;

    this.a = a;
    this.b = b;
    this.width = width;
    this.owner = this.b.owner;

    // Store under second point.
    this.b.hoverTarget = this;

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




*/

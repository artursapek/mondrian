/*

  io

  The goal of this is an IO that can take anything that could
  conceivably be SVG and convert it to Monsvg.

*/


let io = {

  parse(input, makeNew) {
    if (makeNew == null) { makeNew = true; }
    let $svg = this.findSVGRoot(input);
    let svg = $svg[0];

    let bounds = this.getBounds($svg);

    // Set the proper dimensions

    if ((bounds.width == null)) { bounds.width = 1000; }
    if ((bounds.height == null)) { bounds.height = 1000; }


    if (makeNew) {
      ui.new(bounds.width, bounds.height);
    }

    let parsed = this.recParse($svg);

    let viewbox = svg.getAttribute("viewBox");

    if (viewbox) {
      // If there's a viewBox attr, we adjust the contents to fit in the actual canvas
      // the way they fit in the viewBox.
      viewbox = viewbox.split(" ");
      viewbox = new Bounds(viewbox[0], viewbox[1], viewbox[2], viewbox[3]);
    }
      //parsed.map viewbox.adjustElemsTo bounds
      //TODO FIX

    return parsed;
  },

  getBounds(input) {
    let $svg = this.findSVGRoot(input);
    let svg = $svg[0];
    let width = svg.getAttribute("width");
    let height = svg.getAttribute("height");
    let viewbox = svg.getAttribute("viewBox");

    if ((width == null)) {
      if (viewbox != null) {
        width = viewbox.split(" ")[2];
      } else {
        console.warn("No width, defaulting to 1000");
        width = 1000;
      }
    }

    if ((height == null)) {
      if (viewbox != null) {
        height = viewbox.split(" ")[3];
      } else {
        console.warn("No height, defaulting to 1000");
        height = 1000;
      }
    }

    width = parseFloat(width);
    height = parseFloat(height);

    if (isNaN(width)) {
      console.warn("Width is NaN, defaulting to 1000");
      width = 1000;
    }

    if (isNaN(height)) {
      console.warn("Width is NaN, defaulting to 1000");
      height = 1000;
    }

    return new Bounds(0, 0, parseFloat(width), parseFloat(height));
  },

  recParse(container) {
    let results = [];
    for (let elem of Array.from(container.children())) {

      // <defs> symbols... for now we don't do much with this.
      if (elem.nodeName === "defs") {
        continue;
        let inside = this.recParse($(elem));
        results = results.concat(inside);

      // <g> group tags... drill down.
      } else if (elem.nodeName === "g") {
          // The Group class just isnt ready, so we're not supporting it for now.
          // Ungroup everything.
          let parsedChildren = this.recParse($(elem));
          results = results.concat(parsedChildren);
          console.warn(`Group element not implemented yet. Ungrouping ${parsedChildren.length} elements.`);
          // TODO implement groups properly

      } else {

        // Otherwise it must be a shape element we have a class for.
        let parsed = this.parseElement(elem);

        if (parsed === false) {
          continue;
        }

        // Any geometric shapes
        if (parsed instanceof Monsvg) {
          results.push(parsed);

        // <use> tag
        } else if (parsed instanceof Object && (parsed["xlink:href"] != null)) {
          parsed.reference = true;
          results.push(parsed);
        }
      }
    }

    let monsvgs = results.filter(e => e instanceof Monsvg);

    return results;
  },


  findSVGRoot(input) {
    if (input instanceof Array) {
      return input[0].$rep.closest("svg");
    } else if (input instanceof $) {
      input = input.filter('svg');
      if (input.is("svg")) {
        return input;
      } else {
        let $svg = input.find("svg");
        if ($svg.length === 0) {
          throw new Error("io: No svg node found.");
        } else {
          return $svg[0];
        }
      }
    } else {
      return this.findSVGRoot($(input));
    }
  },


  parseElement(elem) {
    let classes = {
      'path': Path,
      'text': Text
    };
    let virgins = {
      'rect': Rect,
      'ellipse': Ellipse,
      'polygon': Polygon, // TODO
      'polyline': Polyline // TODO
    };

    // Ignore attributes that have these words in them.
    // They're useless old crap that Inkscape jizzes all over its SVG files.

    if (elem instanceof $) {
      let $elem = elem;
      elem = elem[0];
    }

    let attrs = elem.attributes;

    let transform = null;
    for (let key of Object.keys(attrs || {})) {
      let attr = attrs[key];
      if (attr.name === "transform") {
        transform = attr.value;
      }
    }

    let data = this.makeData(elem);
    let type = elem.nodeName.toLowerCase();

    if ((classes[type] != null) || (virgins[type] != null)) {
      let result = null;

      if (classes[type] != null) {
        result = new classes[elem.nodeName.toLowerCase()](data);
        if (type === "text") {
          result.setContent(elem.textContent);
        }

      } else if (virgins[type] != null) {
        let virgin = new virgins[elem.nodeName.toLowerCase()](data);
        result = virgin.convertToPath();
        result.virgin = virgin;
      }

      if (transform && (elem.nodeName.toLowerCase() !== "text")) {
        result.carryOutTransformations(transform);
        delete result.data.transform;
        result.rep.removeAttribute("transform");
        result.commit();
      }

      return result;

    } else if (type === "use") {
      return false; // No use tags for now fuck that ^_^

    } else {
      return null;
    }
  }, // Unknown tag, ignore it


  makeData(elem) {
    let blacklist = ["inkscape", "sodipodi", "uuid"];

    let blacklistCheck = function(key) {
      for (let x of Array.from(blacklist)) {
        if (key.indexOf(x) > -1) {
          return false;
        }
      }
      return true;
    };

    let attrs = elem.attributes;
    let data = {};

    for (let key in attrs) {
      let val = attrs[key];
      key = val.name;
      val = val.value;
      if (key === "") { continue; }

      // Don't keep style attributes. Carry them out.
      // style should only be used for temporary transformations,
      // not permanent ones.
      if ((key === "style") && (elem.nodeName !== "text")) {
        data = this.applyStyles(data, val);
      } else if ((val != null) && blacklistCheck(key)) {
        if (/^\d+$/.test(val)) {
          val = float(val);
        }
        data[key] = val;
      }
    }

    // By now any transform attrs should be permanent
    //elem.removeAttribute("transform")

    return data;
  },

  applyStyles(data, styles) {
    let blacklist = ["display", "transform"];
    styles = styles.split(";");
    for (let style of Array.from(styles)) {
      style = style.split(":");
      let key = style[0];
      let val = style[1];
      if (blacklist.has(key)) { continue; }
      data[key] = val;
    }
    return data;
  },


  parseAndAppend(input, makeNew) {
    let parsed = this.parse(input, makeNew);
    parsed.map(elem => elem.appendTo('#main'));
    ui.refreshAfterZoom();
    return parsed;
  },


  prepareForExport() {
    return (() => {
      let result = [];
      for (let elem of Array.from(ui.elements)) {
        if (elem.type === "path") {
          if (elem.virgin != null) {
            elem.virginMode();
          }
        }
        result.push((typeof elem.cleanUpPoints === 'function' ? elem.cleanUpPoints() : undefined));
      }
      return result;
    })();
  },


  cleanUpAfterExport() {
    return (() => {
      let result = [];
      for (let elem of Array.from(ui.elements)) {
        let item;
        if (elem.type === "path") {
          if (elem.virgin != null) {
            item = elem.editMode();
          }
        }
        result.push(item);
      }
      return result;
    })();
  },


  makeFile() {
    this.prepareForExport();

    // Get the file
    let main = new XMLSerializer().serializeToString(dom.main);

    this.cleanUpAfterExport();

    // Newlines! This is hacky.
    // Make better whitespace management happen later
    main = main.replace(/>/gi, ">\n");

    // Attributes to never export, for internal use at runtime only
    let blacklist = ["uuid"];

    for (let attr of Array.from(blacklist)) {
      main = main.replace(new RegExp(attr + '\\=\\"\[\\d\\w\]*\\"', 'gi'), '');
    }

    // Return the file with a comment in the beginning
    // linking to Mondy
    return `\
<!-- Made in Mondrian.io -->
${main}\
`;
  },


  makeBase64() {
    return btoa(this.makeFile());
  },


  makeBase64URI() {
    return `data:image/svg+xml;charset=utf-8;base64,${this.makeBase64()}`;
  },


  makePNGURI(elements, maxDimen) {
    let bounds;
    if (elements == null) { ({ elements } = ui); }
    if (maxDimen == null) { maxDimen = undefined; }
    let sandbox = dom.pngSandbox;
    let context = sandbox.getContext("2d");

    if (elements.length) {
      bounds = this.getBounds(elements);
    } else {
      bounds = this.getBounds(dom.main);
    }

    sandbox.setAttribute("width", bounds.width);
    sandbox.setAttribute("height", bounds.height);

    if (maxDimen != null) {
      let s = Math.max(context.canvas.width, context.canvas.height) / maxDimen;
      context.canvas.width /= s;
      context.canvas.height /= s;
      context.scale(1 / s, 1 / s);
    }

    if (typeof elements === "string") {
      elements = this.parse(elements, false);
    }

    for (let elem of Array.from(elements)) {
      elem.drawToCanvas(context);
    }

    return sandbox.toDataURL("png");
  }
};


window.io = io;

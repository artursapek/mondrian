/*

  Pseudo-PNG class that just draws to
  an off-screen canvas and exports that

*/

class PNG {

  constructor(elements) {

    // Given either an SVG file as a string,
    // an SVG file as an SVG object,
    // or a list of Monsvg elements
    this._parseInput(elements);

    // Put down an off-screen
    // canvas element for us to draw on
    this._buildRep();
  }


  maxDimension(dimen) {
    let context = this.context();

    // Scale the canvas dimensions
    let scale = Math.max(this.width, this.height) / dimen;
    this.setDimensions(this.width / scale, this.height / scale);

    // Scale the context
    let bounds = this.svg._bounds;
    let boundsScale = Math.max(bounds.width, bounds.height) / dimen;
    context.scale(1 / boundsScale, 1 / boundsScale);
    return this;
  }


  export() {
    // PNG clusterfuck
    return atob(this.exportAsBase64());
  }


  exportAsBase64() {
    // Raw B64
    return this.exportAsDataURI().replace(/^.*\,/, '');
  }


  exportAsDataURI() {
    // Draw @elements to the canvas only when we have to
    this._draw();
    return this.rep.toDataURL('png');
  }


  destroy() {
    this.elements = null;
    this.rep.remove();
    this.rep = null;
    return this;
  }


  clear() {
    return this.context().clearRect(0, 0, this.width, this.height);
  }


  static _setScale(x, y) {
    this.context().scale(x / this._contextScaleX, y / this._contextScaleY);
    this._contextScaleX = x;
    return this._contextScaleY = y;
  }


  _draw() {
    this.clear();
    let context = this.context();
    return this.elements.forEach(element => {
      return element.drawToCanvas(context);
    });
  }


  _parseInput(elements) {
    if (typeof(elements) === 'string') {
      this.svg = new SVG(elements);
      return this.elements = this.svg.elements;

    } else if (elements instanceof SVG) {
      this.svg = elements;
      return this.elements = this.svg.elements;

    } else if (elements instanceof Array) {
      this.elements = elements;
      return this.svg = new SVG(this.elements);
    }
  }


  _buildRep() {
    // Make a throwaway canvas, append it to body
    this.rep = document.createElement('canvas');
    this.rep.classList.add('offscreen-throwaway');
    this.setDimensions(
      this.svg.metadata.width,
      this.svg.metadata.height);

    this._contextScaleX = 1.0;
    this._contextScaleY = 1.0;

    return q('body').appendChild(this.rep);
  }


  attr(attr, val) {
    return this.rep.setAttribute(attr, val);
  }


  setDimensions(width, height) {
    this.width = width;
    this.height = height;
    this.attr('width',  this.width);
    return this.attr('height', this.height);
  }


  context() {
    return this._context != null ? this._context : (this._context = this.rep.getContext('2d'));
  }
}


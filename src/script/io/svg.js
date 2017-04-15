import CONSTANTS from 'script/constants'
import Bounds from 'script/geometry/bounds'
import Posn from 'script/geometry/posn'
import ui from 'script/ui/ui'

/*

  SVG representation class/API

*/

export default class SVG {
  static initClass() {
  
    // Constants
  
    this.prototype.MIMETYPE = 'image/svg+xml';
  
    this.prototype.CHARSET = 'utf-8';
  }

  constructor(contents) {

    this._ensureDoc(contents);

    if (this._svgRoot == null) { this._svgRoot = this.doc.querySelector('svg'); }
    if ((this._svgRoot == null)) {
      throw new Error('No svg element found');
    }

    this._buildMetadata();
    if ((this.elements == null)) { this._buildElements(); }
    this._assignMondrianNamespace();
  }

  // Constructor helpers

  _ensureDoc(contents) {
    if (typeof(contents) === 'string') {
      // Parse the SVG string
      return this.doc = new DOMParser().parseFromString(contents, this.MIMETYPE);

    } else if (contents.documentURI != null) {
      // This means it's already a parsed document
      return this.doc = contents;

    } else if (contents instanceof Array) {
      // We've been given a list of Monsvg elements
      this.elements = contents;

      // Create the document from scratch
      this.doc = document.implementation.createDocument(CONSTANTS.SVG_NAMESPACE, 'svg');

      // Have to do this for some reason
      // It gets created with an <undefined></undefined> element
      this.doc.removeChild(this.doc.childNodes[0]);

      this._svgRoot = this.doc.createElementNS(CONSTANTS.SVG_NAMESPACE, "svg");

      this.doc.appendChild(this._svgRoot);

      this.elements.forEach(elem => {
        return this._svgRoot.appendChild(elem.rep);
      });

      // If we haven't been given an SVG element with
      // a canvas size, just derive it from the elements.
      // This will mean it's "trimmed" from the beginning.
      return this._deriveBoundsFromElements();

    } else {
      throw new Error('Bad input');
    }
  }

  _buildMetadata() {
    this.metadata = {};

    this.metadata.width = parseInt(this._svgAttr('width', 10));
    this.metadata.height = parseInt(this._svgAttr('height', 10));

    if (this._bounds == null) {
      return this._bounds = new Bounds(0, 0, this.metadata.width, this.metadata.height);
    }
  }


  _buildElements() {
    return this.elements = io.parse(this.toString(), false);
  }

  _assignMondrianNamespace() {
    // Make the mondrian: namespace legal
    return this._svgRoot.setAttribute('xmlns:mondrian', 'http://mondrian.io/xml');
  }

  _deriveBoundsFromElements() {
    // Get the bounds of all the elements
    this._bounds = this._elementsBounds();

    let width = this._bounds.width + this._bounds.x;
    let height = this._bounds.height + this._bounds.y;

    return this._applyBounds();
  }

  _applyBounds() {
    this._svgRoot.setAttribute('width', this._bounds.width);
    return this._svgRoot.setAttribute('height', this._bounds.height);
  }


  _elementsBounds() {
    return new Bounds(this.elements.map(elem => elem.bounds()));
  }


  trim() {
    // No I/O
    // Trim edges to elements

    this._normalizeRotations();
    let bounds = this._elementsBounds();

    this.elements.forEach(elem => elem.nudge(bounds.x.invert(), bounds.y));

    this._bounds.width = bounds.width;
    this._bounds.height = bounds.height;

    return this._applyBounds();
  }


  _normalizeRotations() {
    let { angle } = ui.transformer;
    return this.elements.forEach(elem => {
      return elem.rotate(360 - angle, this.center());
    });
  }
      // If there's more than one unique angle we abandon them all
      // because there's no other fair way to resolve that.


  _svgAttr(attr) {
    return this._svgRoot.getAttribute(attr);
  }


  toString() {
    return new XMLSerializer().serializeToString(this.doc);
  }


  toBase64() {
    return `data:${this.MIMETYPE};charset=${this.CHARSET};base64,${this.toString()}`;
  }


  appendTo(selector) {
    return q(selector).appendChild(this._svgRoot);
  }


  center() {
    return new Posn(this.metadata.width / 2, this.metadata.height / 2);
  }
}
SVG.initClass();






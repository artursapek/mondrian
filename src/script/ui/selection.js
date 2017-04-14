import ui from 'script/ui/ui';
import events from 'script/mixins/events';
/*

  Manages elements being selected

  API:

  All selected elements:
  ui.selection.elements.all

  All selected points:
  ui.selection.points.all

  Both ui.selection.elements and ui.selection.points
  have the following methods:

  select(elems)
  selectMore(elems)
  selectAll
  deselect(elems)
  deselectAll

*/

ui.selection = {

  elements: {

    all: [],
      // Selected elements


    clone() { return this.all.map(elem => elem.clone()); },


    empty() { return this.all.length === 0; },


    exists() { return !this.empty(); },


    select(elems) {
      // I/P: elem or list of elems
      // Select only elems

      ui.selection.points.deselectAll();

      if (elems instanceof Array) {
        this.all = elems;
      } else {
        this.all = [elems];
      }

      return this.trigger('change');
    },


    selectMore(elems) {
      // I/P: elem, or list of elems
      // Adds elem(s) to the selection

      ui.selection.points.deselectAll();

      if (elems instanceof Array) {
        for (let elem of Array.from(elems)) {
          this.all.ensure(elem);
        }
      } else {
        this.all.ensure(elems);
      }

      return this.trigger('change');
    },


    selectAll() {
      // No I/O
      // Select all elements

      ui.selection.points.deselectAll();

      this.all = ui.elements;
      return this.trigger('change');
    },


    selectWithinBounds(bounds) {
      // I/P: Bounds
      // Select all elements within given Bounds

      ui.selection.points.deselectAll();

      let rect = bounds.toRect();
      this.all = ui.elements.filter(elem => elem.overlaps(rect));
      return this.trigger('change');
    },


    deselect(elems) {
      // I/P: elem or list of elems
      // Deselect given elem(s)

      this.all.remove(elems);
      return this.trigger('change');
    },


    deselectAll() {
      // No I/O
      // Deselects all elements

      if (this.all.length === 0) { return; }

      this.all = [];
      return this.trigger('change');
    },


    each(func) {
      return this.all.forEach(func);
    },


    map(func) {
      return this.all.map(func);
    },


    filter(func) {
      return this.all.filter(func);
    },


    zIndexes() {
      // O/P: a list of the z-indexes of the selected elements
      // ex:  [2, 5, 7]

      return Array.from(this.all).map((e) => e.zIndex());
    },


    ofType(type) {
      // I/P: string of element's nodename
      // ex:  'path'

      // O/P: a list of the selected elements of a certain type
      // ex:  [Path, Path, Path]

      return this.filter(e => e.type === type);
    },


    validate() {
      // No I/O
      // Make sure every selected elem exists in the UI

      this.all = this.filter(elem => ui.elements.has(elem));
      return this.trigger('change');
    },


    // Exporting

    export(opts) {
      if (this.empty()) { return ""; }

      opts = $.extend(
        {trim: false}
      , opts);

      let svg = new SVG(this.clone());

      if (opts.trim) {
        svg.trim();
      }

      return svg.toString();
    },


    exportAsDataURI() {
      return `data:image/svg+xml;base64,${btoa(this.export())}`;
    },


    exportAsPNG(opts) {
      return new PNG(this.export(opts));
    },

    asDataURI() {}
  },

  points: {

    all: [],
      // Selected points


    empty() { return this.all.length === 0; },


    exists() { return !this.empty(); },


    select(points) {
      // I/P: Point or list of Points
      // Selects points, deslects any previously selected points

      ui.selection.elements.deselectAll();

      if (points instanceof Array) {
        this.all = points;
      } else {
        this.all = [points];
      }

      this.all.forEach(p => p.select());

      return this.trigger('change');
    },

    selectMore(points) {
      // I/P: Point or list of Points
      // Selects points

      ui.selection.elements.deselectAll();

      if (points instanceof Array) {
        points.forEach(point => {
          this.all.ensure(point);
          return point.select();
        });
      } else {
        this.all.ensure(points);
        points.select();
      }


      return this.trigger('change');
    },


    deselect(points) {
      points.forEach(point => point.deselect());
      this.all.remove(points);
      return this.trigger('change');
    },

    deselectAll() {
      if (this.all.length === 0) { return; }

      this.all.forEach(point => point.deselect());
      this.all = [];

      return this.trigger('change');
    },

    zIndexes() {
      // O/P: Object where keys are elem zIndexes
      //      and values are lists of point indexes
      // ex: { 3: [5, 6], 7: [1], 22: [29] }
      let zIndexes = {};
      for (let point of Array.from(this.all)) {
        let zi = point.owner.zIndex();
        if (zIndexes[zi] == null) { zIndexes[zi] = []; }
        zIndexes[zi].push(point.at);
      }
      return zIndexes;
    },


    show() { return this.all.map(p => p.show); },


    hide() { return this.all.map(p => p.hide(true)); }, // Force it


    each(func) {
      return this.all.forEach(func);
    },


    filter(func) {
      return this.all.filter(func);
    },


    validate() {
      this.all = this.filter(pt => ui.elements.has(pt.owner));

      return this.trigger('changed');
    }
  },


  refresh() {
    return this.elements.validate();
  }
};


// Give both an event register
$.extend(ui.selection.elements, events);
$.extend(ui.selection.points, events);

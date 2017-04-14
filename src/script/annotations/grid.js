/*


 */

let grid = {

  frequency: {
    x: 20,
    y: 20
  },

  dots: [],

  posns: [],

  visible() {
    return this.dots.length;
  },

  toggle() {
    if (this.visible()) {
      return this.clear();
    } else {
      return this.draw();
    }
  },

  clear() {
    dom.$grid.empty();
    // I think this might help garbage collection
    // But I'm probably wrong
    this.dots = null;
    return this.dots = [];
  },


  draw() {
    this.clear();

    let [width, height] = Array.from([ui.canvas.width, ui.canvas.height]);

    for (let y = 0, end = height / this.frequency.y, asc = 0 <= end; asc ? y <= end : y >= end; asc ? y++ : y--) {
      for (let x = 0, end1 = width / this.frequency.x, asc1 = 0 <= end1; asc1 ? x <= end1 : x >= end1; asc1 ? x++ : x--) {
        let posn = new Posn(x * this.frequency.x, y * this.frequency.y);
        let dot = this.dot(posn);
        dot.appendTo("svg#grid", false);
        this.dots.push(dot);
        this.posns.push(posn);
      }
    }

    return async(() => {
      return this.refreshRadii();
    });
  },

  dot(p) {
    return new Circle({
      cx: p.x,
      cy: p.y,
      r:  1,
      dontTrack: true,
      fill: new Color(0,0,0,0.6),
      stroke: 'none'
    });
  },

  refreshRadii() {
    if (!this.visible()) { return; }
    dom.$grid.hide();
    this.dots.map(function(dot) {
      dot.attr({
        r: 1 / ui.canvas.zoom});
      return dot.commit();
    });
    return dom.$grid.show();
  }
};




ui.grid = grid;

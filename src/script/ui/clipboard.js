import ui from 'script/ui/ui';
/*


  In-app Clipboard

  Cut, Copy, and Paste


*/



ui.clipboard = {


  data: undefined,


  cut() {
    if (ui.selection.elements.all.length === 0) { return; }
    this.copy();
    return Array.from(ui.selection.elements.all).map((elem) =>
      elem.delete());
  },


  copy() {
    if (ui.selection.elements.all.length === 0) { return; }
    return this.data = ui.selection.elements.export();
  },


  paste() {
    if ((this.data == null)) { return; }

    // Parse the stringified clipboard data
    let parsed = io.parseAndAppend(this.data, false);

    // Create a fit func that adjusts elements to fit in their bounds
    // adjusted to be in the center of the window
    let bounds = new Bounds(((() => {
      let result = [];
      for (let p of Array.from(parsed)) {         result.push(p.bounds());
      }
      return result;
    })()));
    let fit = bounds.clone();
    fit.centerOn(ui.canvas.posnInCenterOfWindow());

    // Center the elements
    let adjust = bounds.adjustElemsTo(fit);
    for (let elem of Array.from(parsed)) {
      adjust(elem);
    }

    // Select them
    ui.selection.elements.select(parsed);

    return archive.addExistenceEvent(parsed.map(p => p.rep));
  }
};




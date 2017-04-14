import ui from 'script/ui/ui';

$.extend(ui.selection, {
  macro(actions) {
    // Given an object with 'elements' and/or 'points'
    // functions, maps these on all selected objects of that type
    // 'transformer' function optional as well, where the
    // transformer is the context

    if (actions.elements != null) {
      this.elements.each(e => actions.elements.call(e));
    }
    if (actions.points != null) {
      this.points.each(p => actions.points.call(p));
    }
    if ((actions.transformer != null) && this.elements.exists()) {
      actions.transformer.call(ui.transformer);
    }

    return ui.utilities.transform.refreshValues();
  },

  nudge(x, y, makeEvent) {
    if (makeEvent == null) { makeEvent = true; }
    this.macro({
      elements() {
        return this.nudge(x, y);
      },
      points() {
        this.nudge(x, y);
        if (this.antlers != null) {
          this.antlers.refresh();
        }
        return this.owner.commit();
      },
      transformer() {
        return this.nudge(x, -y).redraw();
      }
    });

    if (makeEvent) {
      // I think this is wrong
      archive.addMapEvent('nudge', this.elements.zIndexes(), { x, y });
      return this.elements.each(e => e.refreshUI());
    }
  },


  scale(x, y, origin) {
    if (origin == null) { origin = ui.transformer.center(); }
    return this.macro({
      elements() {
        return this.scale(x, y, origin);
      }
    });
  },


  rotate(a, origin) {
    if (origin == null) { origin = ui.transformer.center(); }
    return this.macro({
      elements() {
        return this.rotate(a, origin);
      },
      transformer() {
        return this.rotate(a, origin).redraw();
      }
    });
  },


  delete() {
    return this.macro({
      elements() {
        return this.delete();
      }
    });
  }
}
);


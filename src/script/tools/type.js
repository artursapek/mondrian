import tools from 'script/tools/tools';
import Tool from 'script/tools/tool';
/*

  Type tool

*/



tools.type = new Tool({

  cssid: 'type',
  id: 'type',

  hotkey: 'T',

  typingInto: undefined,

  tearDown() {
    return this.typingInto = undefined;
  },

  addNode(e) {
    if (this.typingInto != null) {
      this.typingInto.displayMode();
      archive.addExistenceEvent(this.typingInto.rep);
      return this.typingInto = undefined;
    } else {
      ui.selection.elements.deselectAll();
      this.typingInto = new Text({
        x: e.canvasPosnZoomed.x,
        y: e.canvasPosnZoomed.y,
        fill: ui.fill,
        stroke: ui.stroke
      });

      this.typingInto.appendTo('#main');
      return this.typingInto.selectAll();
    }
  },


  click: {
    elem(e) {
      if (e.elem.type === "text") {
        e.elem.editableMode();
        return e.elem.textEditable.focus();
      } else {
        return this.click.all.call(tools.type, e);
      }
    },

    all(e) {
      return this.addNode(e);
    }
  },

  startDrag: {
    elem(e) {
      console.log(e.elem);
      if (e.elem.type === "text") {
        e.elem.editableMode();
        return e.elem.textEditable.focus();
      }
    }
  },


  stopDrag: {
    all(e) {
      if ((e.elem != null ? e.elem.type : undefined) !== "text") {
        return this.addNode(e);
      }
    }
  }
});


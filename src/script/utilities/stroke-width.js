import ui from 'script/ui/ui';
import setup from 'script/setup';
import Utility from 'script/utilities/utility';
import tools from 'script/tools/tools';
/*

  Stroke thickness utility

*/


ui.utilities.strokeWidth = new Utility({
  setup() {
    this.$rep = $("#stroke-width-ut");
    this.rep = this.$rep[0];
    this.$preview = this.$rep.find("#stroke-width-preview");
    this.$noStroke = this.$rep.find("#no-stroke-width-hint");

    return this.strokeControl = new NumberBox({
      rep: this.$rep.find('input')[0],
      value: 1,
      min: 0,
      max: 100,
      places: 2,
      commit: val => {
        this.alterVal(val);
        return this.drawPreview();
      },

      onDone() {
        return archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          "stroke-width");
      }
    });
  },

  alterVal(val) {
    if (isNaN(val)) { return; } // God damn this fucking language
    val = Math.max(val, 0).places(2);
    for (let elem of Array.from(ui.selection.elements.all)) {
      elem.data['stroke-width'] = val;
      if ((elem.data.stroke == null) || (elem.data.stroke.hex === "none")) {
        elem.data.stroke = ui.colors.black;
      }
      elem.commit();
    }
    this.drawPreview();
    return ui.uistate.set('strokeWidth', parseInt(val, 10));
  },

  drawPreview() {
    let preview = Math.min(20, Math.max(0, this.strokeControl.value));
    this.$preview.css({
      opacity: Math.min(preview, 1.0),
      height: `${Math.max(1, preview)}px`,
      top: `${Math.ceil(30 - Math.round(preview / 2))}px`
    });

    if (this.strokeControl.value === 0) {
      return this.$noStroke.css("opacity", "0.4");
    } else {
      return this.$noStroke.css("opacity", "0.0");
    }
  },

  onshow() {
    return this.refresh();
  },

  refresh() {
    let width;
    if (ui.selection.elements.all.length === 1) {
      width = ui.selection.elements.all[0].data['stroke-width'];
      ui.uistate.set('strokeWidth', parseInt(width, 10));
    } else {
      width = ui.uistate.get('strokeWidth');
    }
    if (width != null) {
      this.strokeControl.set(width);
    } else {
      this.strokeControl.set(0);
    }
    return this.drawPreview();
  },

  shouldBeOpen() {
    return (ui.selection.elements.all.length > 0) || ([tools.pen, tools.line, tools.ellipse, tools.rectangle, tools.crayon, tools.type].has(ui.uistate.get('tool')));
  }
});

setup.push(() => ui.utilities.strokeWidth.alterVal(1));


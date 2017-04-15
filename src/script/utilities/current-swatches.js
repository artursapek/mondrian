import ui from 'script/ui/ui';
import Utility from 'script/utilities/utility';
import SwatchDuo from 'script/ui/swatch-duo';

ui.utilities.currentSwatches = new Utility({
  setup() {
    this.$rep = $("#current-swatches-ut");
    this.rep = this.$rep[0];
    return ui.selection.elements.on('change', () => {
      this.generateSwatches();
      if (ui.selection.elements.empty()) {
        return this.clear();
      } else if (ui.selection.elements.all.length === 1) {
        return ui.utilities.color.sample(ui.selection.elements.all[0]);
      }
    });
  },

  shouldBeOpen() {
    return ui.selection.elements.all.length > 0;
  },

  clear() {
    return this.rep.innerHTML = "";
  },


  generateSwatches() {
    this.clear();
    this.getSelectedSwatches();

    if (this.swatches.length === 1) {
      ui.utilities.color.sample(ui.selection.elements.all[0]);
      return this.clear();
    } else {
      return Array.from(this.swatches).map((swatch) =>
        swatch.fill.equal(ui.fill) && swatch.stroke.equal(ui.stroke) ?
          this.$rep.prepend(swatch.rep)
        :
          this.$rep.append(swatch.rep));
    }
  },


  getSelectedSwatches() {
    this.swatches = [];
    this.swatchMap = {};

    let add = (key, val) => {
      if (this.swatchMap[key] != null) {
        return this.swatchMap[key].push(val);
      } else {
        return this.swatchMap[key] = [val];
      }
    };

    return (() => {
      let result = [];
      for (var elem of Array.from(ui.selection.elements.all)) {
        let swatchDuo = new SwatchDuo(elem);
        let key = swatchDuo.toString();
        if ((this.swatchMap[key] == null)) { this.swatches.push(swatchDuo); }
        add(key, elem);

        let $srep = swatchDuo.$rep;

        result.push($srep.click(function() {
          return ui.selection.elements.select(ui.utilities.currentSwatches.swatchMap[this.getAttribute("key")]);})
        .mouseover(function(e) {
          e.stopPropagation();
          return (() => {
            let result1 = [];
            for (elem of Array.from(ui.utilities.currentSwatches.swatchMap[this.getAttribute("key")])) {
              result1.push(elem.showPoints());
            }
            return result1;
          })();}).mouseout(function(e) {
          return (() => {
            let result1 = [];
            for (elem of Array.from(ui.utilities.currentSwatches.swatchMap[this.getAttribute("key")])) {
              result1.push(elem.removePoints().hidePoints());
            }
            return result1;
          })();
        }));
      }
      return result;
    })();
  }
});






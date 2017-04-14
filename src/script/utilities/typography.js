import Utility from 'script/utilities/utility';

ui.utilities.typography = new Utility({
  setup() {
    this.$rep = $("#typography-ut");
    this.rep = this.$rep[0];

    this.$faces = this.$rep.find("#font-faces-dropdown");
    this.$size = this.$rep.find("#font-size-val");

    this.sizeControl = new NumberBox({
      rep: this.$size[0],
      value: 24,
      min: 1,
      max: 1000,
      places: 2,
      commit: val => {
        return this.setSize(val);
      }
    });

    return this.faceControl = new Dropdown({
      options: this.faces,
      rep:     this.$faces[0],
      callback: val => {
        return this.setFace(val);
      }
    });
  },

  faces: ['Arial', 'Arial Black', 'Cooper Black', 'Georgia', 'Monaco', 'Verdana', 'Impact', 'Gill Sans'].map((fontFace) => new FontFaceOption(fontFace)),

  setFace(face) {
    ui.selection.elements.ofType("text").map(function(t) {
      t.setFace(face);
      return t.commit();
    });
    return ui.transformer.refresh();
  },


  setSize(val) {
    ui.selection.elements.ofType("text").map(function(t) {
      t.setSize(val);
      return t.commit();
    });
    return ui.transformer.refresh();
  },

  refresh() {
    let sizes = [];
    ui.selection.elements.ofType("text").map(function(t) {
      let fs = t.data['font-size'];
      if (!sizes.has(fs)) {
        return sizes.push(fs);
      }
    });
    if (sizes.length === 1) {
      this.sizeControl.write(sizes[0]);
    }
    return this.faceControl.close();
  },

  onshow() {
    return this.refresh();
  },

  shouldBeOpen() {
    return (ui.selection.elements.ofType("text").length > 0) || (ui.uistate.get('tool') === tools.type);
  }
}); // TEXT EDITING AHH


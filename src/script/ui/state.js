import events from 'script/mixins/events';
import tools from 'script/tools/tools';
import Posn from 'script/geometry/posn';

/*

  JSON Serializable UI State

*/



class UIState {
  constructor(attributes) {
    if (attributes == null) { attributes = this.DEFAULTS(); }
    this.attributes = attributes;
    this.on('change', () => {
      return this.saveLocally();
    });
  }

  restore() {
    // Restore the previous state in localStorage if it exists
    let storedState = localStorage.getItem('uistate');
    if (storedState != null) { this.importJSON(JSON.parse(storedState)); }
    return this;
  }

  set(key, val) {
    // Prevent echo loops and pointless change callbacks
    if (this.attributes[key] === val) { return; }
    switch (key) {
      case 'tool':
        this.attributes.lastTool = this.attributes.tool;
        this.attributes.tool = val;
        break;
      default:
        this.attributes[key] = val;
    }

    this.trigger('change', key, val);
    return this.trigger(`change:${key}`, val);
  }

  get(key) {
    return this.attributes[key] || this.DEFAULTS()[key];
  }

  saveLocally() {
    return localStorage.setItem('uistate', this.toJSON());
  }

  apply() {
    ui.fill.absorb(this.get('fill'));
    return ui.stroke.absorb(this.get('stroke'));
  }

  toJSON() {
    return {
      fill:        this.attributes.fill.hex,
      stroke:      this.attributes.stroke.hex,
      strokeWidth: this.attributes.strokeWidth,
      zoom:        this.attributes.zoom,
      normal:      this.attributes.normal.toJSON(),
      //tool:        this.attributes.tool.id,
      //lastTool:    this.attributes.lastTool.id
    };
  }

  importJSON(attributes) {
    this.attributes = {
      fill:        new Color(attributes.fill),
      stroke:      new Color(attributes.stroke),
      strokeWidth: attributes.strokeWidth,
      zoom:        attributes.zoom,
      normal:      Posn.fromJSON(attributes.normal),
      tool:        tools[attributes.tool],
      lastTool:    tools[attributes.lastTool]
    };
    return this.trigger('change');
  }

  DEFAULTS() {
    // These are "pre-parsed"; we don't bother
    // storing this in JSON
    return {
      fill:        new Color("#5fcda7"),
      stroke:      new Color("#000000"),
      strokeWidth: 1.0,
      zoom:        1.0,
      normal:      new Posn(-1, -1),
      tool:        tools.cursor,
      lastTool:    tools.cursor
    };
  }
}

$.extend(UIState.prototype, events);

window.UIState = UIState;

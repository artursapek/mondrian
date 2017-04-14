/*

  TopUI

  An agnostic sort of "tool" that doesn't care what tool is selected.
  Specifically for dealing with top UI elements like utilities.

  Operates much like a Tool object, but the keys are classnames of top UI objects.

*/

ui.topUI = {

  _tooltipShowTimeout: undefined,
  _tooltipHideTimeout: undefined,
  _$tooltipVisible:    undefined,

  dispatch(e, event) {
    for (let cl of Array.from(e.target.className.split(" "))) {
      __guardMethod__(this[event], `.${cl}`, (o, m) => o[m](e));
    }
    return __guardMethod__(this[event], `#${e.target.id}`, (o1, m1) => o1[m1](e));
  },

  hover: {
    ".tool-button"(e) {
      return ui.tooltips.activate(e.target.getAttribute("tool"));
    }
  },

  unhover: {
    ".tool-button"(e) {
      return ui.tooltips.deactivate(e.target.getAttribute("tool"));
    }
  },

  click: {
    ".swatch"(e) {
      if (e.target.parentNode.className === "swatch-duo") { return; }
      let $swatch = $(e.target);
      let offset = $swatch.offset();
      ui.utilities.color.setting = e.target;
      return ui.utilities.color.toggle().position(offset.left + 41, offset.top).ensureVisibility();
    },

    "#transparent-permanent-swatch"() {
      ui.utilities.color.set(ui.colors.null);
      ui.utilities.color.updateIndicator();
      if (ui.selection.elements.all.length) {
        return archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"));
      }
    },

    ".tool-button"(e) {
      let tool = e.target.getAttribute('tool');
      ui.switchToTool(tools[tool]);
      return ui.tooltips.hideVisible();
    },

    ".slider"(e) {
      return $(e.target).trigger("release");
    }
  },


  mousemove: {
    "slider knob"() {}
  },


  mousedown: {
    "slider knob"() {}
  },


  mouseup: {
    "#color-pool"(e) {
      ui.utilities.color.selectColor(e);

      trackEvent("Color", "Choose", ui.utilities.color.selectedColor.toString());

      if (ui.selection.elements.all.length > 0) {
        return archive.addAttrEvent(
          ui.selection.elements.zIndexes(),
          ui.utilities.color.setting.getAttribute("type"));
      }
    }
  },


  startDrag: {
    ".slider-container"(e) {
      console.log(5);
      return ui.cursor.lastDownTarget = $(e.target).find(".knob")[0];
    }
  },


  continueDrag: {
    "#color-pool"(e) {
      return ui.utilities.color.selectColor(e);
    },

    ".knob"(e) {
      let change = new Posn(e).subtract(ui.cursor.lastPosn);
      return $(e.target).nudge(change.x, 0);
    }
  },


  stopDrag: {
    ".knob"(e) {
      return $(e.target).trigger("stopDrag");
    }
  }
};






function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
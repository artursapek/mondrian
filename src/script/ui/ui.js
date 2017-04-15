import setup from 'script/setup';
import dom from 'script/dom/dom';
import Color from 'script/uiClasses/color';
import Posn from 'script/geometry/posn';

/*

  UI handling

  Handles
    - Mouse event routing
    - UI state memory
  Core UI functions and interface for all events used by the tools.


*/


let ui = {
  // This is the highest level of UI in Mondy.
  // It contains lots of more specific objects and dispatches events to tools
  // as appropriate. It also handles tool switching.
  //
  // It has many child objects with more specific functions, like hotkeys and cursor (tracking)

  setup() {
    // Default settings for a new Mondrian session.

    this.uistate = new UIState();
    this.uistate.restore();

    // This means the user switched tabs and came back.
    // Now we have no idea where the cursor is,
    // so don't even try showing the placeholder if it's up.
    ui.window.on('focus', () => {
      return dom.$toolCursorPlaceholder.hide();
    });

    // Make sure the window isn't somehow scrolled. This will hide all the UI, happens very rarely.
    window.scrollTo(0, 0);

    // Base case for tool switching.
    //@lastTool = tools.cursor

    // Set the default fill and stroke colors in case none are stored in localStorage
    this.fill = new Swatch("5fcda7").appendTo("#fill-color");
    this.stroke = new Swatch("000000").appendTo("#stroke-color");

    this.fill.type = "fill";
    this.stroke.type = "stroke";

    // The default UI config is the draw config obviously!
    this.changeTo("draw");

    return this.selection.elements.on('change', () => {
      this.refreshUtilities();
      this.transformer.refresh();
      return this.utilities.transform.refresh();
    });
  },


  clear() {
    return $("#ui .point.handle").remove();
  },


  // UI state management
  // TODO Abstract into its own class

  importState(state) {
    // Given an object of certain attributes,
    // configure the UI to match that state.
    // Keys to give:
    //   fill:        hex string of color
    //   stroke:      hex string of color
    //   strokeWidth: number
    //   normal:      posn.toString()
    //   zoomLevel:   number

    this.fill.absorb(new Color(state.fill));
    this.stroke.absorb(new Color(state.stroke));

    this.canvas.setZoom(parseFloat(state.zoom));
    this.refreshAfterZoom();

    this.canvas.normal = new Posn(state.normal);
    this.canvas.refreshPosition();

    if (state.tool != null) {
      return secondRoundSetup.push(() => {
        return this.switchToTool(objectValues(tools).filter(t => t.id === state.tool)[0]);
      });
    } else {
      return secondRoundSetup.push(() => {
        return this.switchToTool(tools.cursor);
      });
    }
  }, // Noobz



  new(width, height, normal, zoom) {
    // Set up the UI for a new file. Give two dimensions.
    // TODO Add a user interface for specifying file dimensions
    if (normal == null) { ({ normal } = this.canvas); }
    if (zoom == null) { ({ zoom } = this.canvas); }
    this.canvas.width = width;
    this.canvas.height = height;
    this.canvas.zoom = zoom;
    this.canvas.normal = normal;
    this.canvas.redraw();
    this.canvas.zoom100();
    return this.deleteAll();
  },


  configurations: {
    // A configuration is defined as an function that returns an object.
    // The object needs to have a "show" attribute which is an array
    // of elements to show when we choose that UI configuration.
    // Before this is done, the previous configuration's "show"
    // elements are hidden. This lets us toggle easily between UI modes, like
    // going from draw mode to save mode for example.
    //
    // A configuration can also have an "etc" function which will just run
    // with no parameters when the configuration is selected.
    draw() {
      return {
        show:
          [dom.$canvas,
          dom.$toolPalette,
          dom.$menuBar,
          dom.$filename,
          dom.$currentSwatches,
          dom.$utilities]
      };
    },
    gallery() {
      return {
        show:
          [dom.$currentService,
          dom.$serviceGallery]
      };
    },
    browser() {
      return {
        show:
          [dom.$currentService,
          dom.$serviceBrowser]
      };
    }
  },


  changeTo(config) {
    // Hide the old config
    if (this.currentConfig != null) {
      this.currentConfig.show.map(e => e.hide());
    }

    // When we switch contexts we want to get hotkeys back immediately,
    // becuase it's pretty much guaranteed that whatever
    // might have disabled them before is now gone.
    this.hotkeys.enable().reset();

    if ("config" === "draw") {
      this.refreshUtilities();
    } else {
      for (let util of Array.from(this.utilities)) {
        util.hide();
      }
    }

    this.currentConfig = typeof this.configurations[config] === 'function' ? this.configurations[config]() : undefined;
    if (this.currentConfig != null) {
      this.currentConfig.show.map(e => e.show());
      if (typeof this.currentConfig.etc === 'function') {
        this.currentConfig.etc();
      }

      // Set the title if we want one.
      if (this.currentConfig.title != null) {
        dom.$dialogTitle.show().text(this.currentConfig.title);
      } else {
        dom.$dialogTitle.hide();
      }
    }

    this.menu.closeAllDropdowns();

    return this;
  },

  refreshAfterZoom() {
    for (let elem of Array.from(this.elements)) {
      elem.refreshUI();
    }
    this.selection.points.show();
    return this.grid.refreshRadii();
  },


  // Tool switching/management

  switchToTool(tool) {
    if (tool === this.uistate.get('tool')) { return; }

    __guard__(this.uistate.get('tool'), x => x.tearDown());
    this.uistate.set('tool', tool);

    if (dom.$toolCursorPlaceholder != null) {
      dom.$toolCursorPlaceholder.hide();
    }
    if (dom.$body != null) {
      dom.$body.off('mousemove.tool-placeholder');
    }
    if (dom.body != null) {
      dom.body.setAttribute('tool', tool.cssid);
    }

    tool.setup();

    if (tool !== tools.paw) {
      // All tools except paw (panning; space-bar) have a button
      // in the UI. Update those buttons unless we're just temporarily
      // activating the paw.
      __guard__(q(".tool-button[selected]"), x1 => x1.removeAttribute('selected'));
      __guard__(q(`.tool-button[tool=\"${tool.id}\"]`), x2 => x2.setAttribute('selected', ''));

      // A hack, somewhat. Changing the document cursor offset in the CSS
      // fires a mousemove so if we're changing to a tool with a different
      // action point then it's gonna disappear. But the mousemove event object
      // has an offsetX, offsetY attribute pair which will match the tool's
      // own offsetX and offsetY, so we just take the first event where those
      // don't match and hide the placeholder.
      dom.$body.on('mousemove.tool-placeholder', e => {
        if ((e.offsetX !== tool.offsetX) || (e.offsetY !== tool.offsetY)) {
          dom.$toolCursorPlaceholder.hide();
          return dom.$body.off('mousemove.tool-placeholder');
        }
    });
    }

    this.refreshUtilities();

    if (this.cursor.currentPosn === undefined) { return; }

    return dom.$toolCursorPlaceholder
      .show()
      .attr('tool', tool.cssid)
      .css({
        left: this.cursor.currentPosn.x - tool.offsetX,
        top:  this.cursor.currentPosn.y - tool.offsetY
    });
  },


  switchToLastTool() {
    return this.switchToTool(this.uistate.get('lastTool'));
  },


  // Event proxies for tools

  hover(e, target) {
    e.target = target;
    this.uistate.get('tool').dispatch(e, "hover");
    let topUI = isOnTopUI(target);
    if (topUI) {
      switch (topUI) {
        case "menu":
          let menus = objectValues(this.menu.menus);
          // If there's a menu that's open right now
          if (menus.filter(menu => menu.dropdownOpen).length > 0) {
            // Get the right menu
            let menu = menus.filter(menu => menu.itemid === target.id)[0];
            if (menu != null) { return menu.openDropdown(); }
          }
          break;
        default:
          return this.topUI.dispatch(e, "hover");
      }
    }
  },


  unhover(e, target) {
    e.target = target;
    if (isOnTopUI(target)) {
      return this.topUI.dispatch(e, "unhover");
    } else {
      return this.uistate.get('tool').dispatch(e, "unhover");
    }
  },

  click(e, target) {
    // Certain targets we ignore.
    if ((target.nodeName.toLowerCase() === "emph") || (target.hasAttribute("buttontext"))) {
      let t = $(target).closest(".menu-item")[0];
      if ((t == null)) {
        t = $(target).closest(".menu")[0];
      }
      target = t;
    }

    let topUI = isOnTopUI(target);

    if (topUI) {
      // Constrain UI to left clicks only.
      if (e.which !== 1) { return; }

      switch (topUI) {
        case "menu":
          return __guard__(this.menu.menu(target.id), x => x._click(e));

        case "menu-item":
          return __guard__(this.menu.item(target.id), x1 => x1._click(e));

        default:
          return this.topUI.dispatch(e, "click");
      }
    } else {
      if (e.which === 1) {
        return this.uistate.get('tool').dispatch(e, "click");
      } else if (e.which === 3) {
        return this.uistate.get('tool').dispatch(e, "rightClick");
      }
    }
  },

  doubleclick(e, target) {
    return this.uistate.get('tool').dispatch(e, "doubleclick");
  },

  mousemove(e) {
    // Paw tool specific shit. Sort of hackish. TODO find a better spot for this.
    let topUI = isOnTopUI(e.target);
    if (topUI) {
      this.topUI.dispatch(e, "mousemove");
    }
    if (this.uistate.get('tool') === tools.paw) {
      return dom.$toolCursorPlaceholder.css({
        left: e.clientX - 8,
        top: e.clientY - 8
      });
    }
  },

  mousedown(e) {
    if (!isOnTopUI(e.target)) {
      this.menu.closeAllDropdowns();
      this.refreshUtilities();
      return this.uistate.get('tool').dispatch(e, "mousedown");
    }
  },

  mouseup(e) {
    let topUI = isOnTopUI(e.target);
    if (topUI) {
      return this.topUI.dispatch(e, "mouseup");
    } else {
      e.stopPropagation();
      return this.uistate.get('tool').dispatch(e, "mouseup");
    }
  },

  startDrag(e) {
    let topUI = isOnTopUI(e.target);
    if (topUI) {
      return this.topUI.dispatch(e, "startDrag");
    } else {
      this.uistate.get('tool').initialDragPosn = new Posn(e);
      this.uistate.get('tool').dispatch(e, "startDrag");

      return Array.from(this.hotkeys.modifiersDown).map((key) =>
        this.uistate.get('tool').activateModifier(key));
    }
  },

  continueDrag(e, target) {
    e.target = target;
    let topUI = isOnTopUI(target);
    if (topUI) {
      return this.topUI.dispatch(e, "continueDrag");
    } else {
      return this.uistate.get('tool').dispatch(e, "continueDrag");
    }
  },

  stopDrag(e, target) {
    document.onselectstart = () => true;

    let releaseTarget = e.target;
    e.target = target;
    let topUI = isOnTopUI(e.target);

    if (topUI) {
      if ((target.nodeName.toLowerCase() === "emph") || (target.hasAttribute("buttontext"))) {
        target = target.parentNode;
      }

      switch (topUI) {
        case "menu":
          if (releaseTarget === target) {
            return __guard__(this.menu.menu(target.id), x => x._click(e));
          }
          break;
        case "menu-item":
          if (releaseTarget === target) {
            return __guard__(this.menu.item(target.id), x1 => x1._click(e));
          }
          break;

        default:
          return this.topUI.dispatch(e, "stopDrag");
      }
    } else {
      this.uistate.get('tool').dispatch(e, "stopDrag");
      this.uistate.get('tool').initialDragPosn = null;
      return this.snap.toNothing();
    }
  },


  // Colorz

  fill: null,

  stroke: null,

  // The elements on the board
  elements: [], // Elements on the board

  queryElement(svgelem) {
    // I/P: an SVG element in the DOM
    // O/P: its respective Monsvg object
    for (let elem of Array.from(this.elements)) {
      if (elem.rep === svgelem) {
        return elem;
      }
    }
  },


  // TODO Abstract
  hoverTargetsHighlighted: [],

  // TODO Abstract
  unhighlightHoverTargets() {
    for (let hoverTarget of Array.from(this.hoverTargetsHighlighted)) {
      hoverTarget.unhighlight();
    }
    return this.hoverTargetsHighlighted = [];
  },


  refreshUtilities() {
    if (!appLoaded) { return; }
    return (() => {
      let result = [];
      for (let key of Object.keys(this.utilities || {})) {
        let utility = this.utilities[key];
        if (!utility.shouldBeOpen()) {
          result.push(utility.hide());
        } else {
          result.push(utility.show());
        }
      }
      return result;
    })();
  },


  deleteAll() {
    for (let elem of Array.from(this.elements)) {
      elem.delete();
    }
    this.elements = [];
    dom.main.removeChildren();
    return this.selection.refresh();
  },


  // Common colors
  colors: {
    transparent: new Color(0,0,0,0),
    white:  new Color(255, 255, 255),
    black:  new Color(0, 0, 0),
    red:    new Color(255, 0, 0),
    yellow: new Color(255, 255, 0),
    green:  new Color(0, 255, 0),
    teal:   new Color(0, 255, 255),
    blue:   new Color(0, 0, 255),
    pink:   new Color(255, 0, 255),
    null:   new Color(null, null, null),
    // Logo colors
    logoRed:    new Color("#E03F4A"),
    logoYellow: new Color("#F1CF2E"),
    logoBlue:   new Color("#3FB2E0")
  }
};

export default ui;


setup.push(() => ui.setup());

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

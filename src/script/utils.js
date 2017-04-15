/*

  Utils

  Random little snippets to make things easier.
  Default prototype extensions for String, Array, Math... everything

  Add miscellaneous helpers that can be useful in more than one file here, since
  this gets compiled before everything else.

         _____
        /__    \
        ___) E| -_
       \_____  -_  -_
                 -_  -_
                   -_  -_
                     -_ o |
                       -_ /     This is a wrench ok?

*/

window.print = function() { return console.log.apply(console, arguments); };


window.async = fun =>
  // Shorthand for breaking out of current execution block
  // Usage:
  //
  // async ->
  //   do shit

  setTimeout(fun, 1)
;


// Shorthand for querySelector and querySelectorAll
// querySelectorAll is like six times slower,
// so only use it when necessary.
// That being said, it's still better
// than using $() just to select shit
window.q = query => document.querySelector.call(document, query);

window.qa = query => document.querySelectorAll.call(document,query);


window.uuid = function(len) {
  // Generates
  if (len == null) { len = 20; }
  let id = '';
  let chars = ('abcdefghijklmnopqrstuvwxyz' +
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
          '1234567890').split('');

  for (let i = 1, end = len, asc = 1 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    id += chars[parseInt(Math.random() * 62, 10)];
  }
  return id;
};


// This shit sucks:
// TODO remove this or do it better
// Checks if a given event target is one of the shapes on the board
window.isSVGElement = target => { target.namespaceURI === 'http://www.w3.org/2000/svg'; }

window.isSVGElementInMain = target => (target.namespaceURI === 'http://www.w3.org/2000/svg') && ($(target).closest("#main").length > 0) && (target.id !== 'main');

// Testing if target is certain type of handle
window.isPointHandle = target => target.className === 'transform handle point';

window.isBezierControlHandle = target => target.className === 'transform handle point bz-ctrl';

window.isTransformerHandle = target => target.className.mentions('transform handle');

window.isHoverTarget = target => (target.parentNode != null ? target.parentNode.id : undefined) === 'hover-targets';

// Testing if target is any type of handle
window.isHandle = function(target) {
  if (target.nodeName.toLowerCase() === 'div') {
    return target.className.mentions('handle');
  }
  return false;
};

window.isTextInput = target => (target.nodeName.toLowerCase() === "input") && (target.getAttribute("type") === "text");

window.isUtilityWindow = target => target.className.mentions("utility-window") || ($(target).closest('.utility-window').length > 0);

window.isSwatch = target => target.className.mentions("swatch");

// This really sucks
// TODO anything else
window.isOnTopUI = function(target) {
  if (typeof target.className === "string") {
    let cl = target.className.split(" ");
    if (cl.has("disabled")) {
      return false;
    }
    if (cl.has("tool-button")) {
      return "tb";
    } else if (cl.has("menu")) {
      return "menu";
    } else if (cl.has("menu-item")) {
      return "menu-item";
    } else if (cl.has("menu-dropdown")) {
      return "dui";
    }
  }

  if (target.hasAttribute("buttontext")) {
    return true;
  }

  if (target.nodeName.toLowerCase() === "a") {
    return true;
  }

  if (target.id === "hd-file-loader") {
    return "file-loader";
  } else if (isTextInput(target)) {
    return "text-input";
  } else if (isUtilityWindow(target)) {
    return "utility-window";
  } else if (isSwatch(target)) {
    return "swatch";
  }

  return false;
};

// </sucks>


window.allowsHotkeys = function(target) {
  return $(target).closest("[h]").length > 0; 
}

window.isDefaultQuarantined = function(target) {
  if (target.hasAttribute("quarantine")) {
    return true;
  } else if ($(target).closest("[quarantine]").length > 0) {
    return true;
  } else {
    return false;
  }
};

window.queryElemByUUID = uuid => ui.queryElement(q(`#main [uuid="${uuid}"]`));

window.queryElemByZIndex = zi => ui.queryElement(dom.$main.children()[zi]);



window.cleanUpNumber = function(n) {
  n = n.roundIfWithin(SETTINGS.MATH.POINT_ROUND_DGAF);
  n = n.places(SETTINGS.MATH.POINT_DECIMAL_PLACES);
  return n;
};

window.int = n => parseInt(n, 10);

window.float = n => parseFloat(n);

window.oots = Object.prototype.toString;

Object.prototype.toString = function() {
  if (this instanceof $) {
    return `$('${this.selector}') object`;
  } else {
    try {
      return JSON.stringify(this);
    } catch (e) {
      return oots.call(this);
    }
  }
};


export function objectValues(obj) {
  let vals = [];
  for (let key of Object.keys(obj || {})) {
    let val = obj[key];
    vals.push(val);
  }
  return vals;
};


window.cloneObject = function(obj) {
  let newo = new Object();
  for (let key of Object.keys(obj || {})) {
    let val = obj[key];
    newo[key] = val;
  }
  return newo;
};

window.sortNumbers = function(a, b) {
  if (a < b) {
    return -1;
  } else if (a > b) {
    return 1;
  } else if (a === b) {
    return 0;
  }
};

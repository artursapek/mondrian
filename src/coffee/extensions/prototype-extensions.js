/*

  Built-in prototype extensions

*/


// Math

Math.lerp = (a, b, c) => b + (a * (c - b));

// Used in approximating circle/ellipse with cubic beziers.
// References:
//   http://www.whizkidtech.redprince.net/bezier/circle/
//   http://www.whizkidtech.redprince.net/bezier/circle/kappa/
Math.KAPPA = 0.5522847498307936;


// String

String.prototype.toFloat = function() { // Take only digits and decimals, then parseFloat.
  return parseFloat(this.valueOf().match(/[\d\.]/g).join(''));
};

// Does phrase exist within a string, verbatim?
String.prototype.mentions = function(phrase) {
  if (typeof(phrase) === 'string') {
    return this.indexOf(phrase) > -1;
  } else if (phrase instanceof Array) {
    for (let p of Array.from(phrase)) {
      if (this.mentions(p)) { return true; }
    }
    return false;
  }
};

// Same thing for this silly shit, idk ¯\_(ツ)_/¯
SVGAnimatedString.prototype.mentions = function(phrase) {
  return this.baseVal.mentions(phrase);
};

String.prototype.capitalize = function() {
  // 'artur' => 'Artur'
  return this.charAt(0).toUpperCase() + this.slice(1);
};

String.prototype.camelCase = function() {
  // 'slick duba' => 'slickDuba'
  return this.split(/[^a-z]/gi).map(function(x, ind) {
    if (ind === 0) { return x; } else { return x.capitalize(); }
  }).join('');
};

String.prototype.strip = function() {
  // Strip spaces on beginning and end
  return this.replace(/(^\s*)|(\s+$)|\n/g, '');
};


// Number

Number.prototype.px = function() {
  // 212.12345 => '212.12345px'
  return `${this.toPrecision()}px`;
};

Number.prototype.invert = function() {
  // 4 => -4
  // -4 => 4
  return this * -1;
};

Number.prototype.within = function(tolerance, other) {
  // I/P: Two numbers
  // O/P: Is this within tolerance of other?
  let d = this - other;
  return (d < tolerance) && (d > -tolerance);
};

Number.prototype.roundIfWithin = function(tolerance) {
  if ((Math.ceil(this) - this) < tolerance) {
    return Math.ceil(this);
  } else if ((this - Math.floor(this)) < tolerance) {
    return Math.floor(this);
  } else {
    return this.valueOf();
  }
};

Number.prototype.ensureRealNumber = function() {
  // For weird edgecases that cause NaN bugs,
  // which are incredibly annoying
  let val = this.valueOf();
  let fuckedUp = ((val === Infinity) || (val === -Infinity) || isNaN(val));
  if (fuckedUp) { return 1; } else { return val; }
};

Number.prototype.toNearest = function(n, tolerance) {
  // Round to the nearest increment of n, starting at 0
  // Used in snapping.
  //
  // I/P: n: any value
  //      tolerance: optional tolerance:
  //                 only round if it's within this
  //                 much of what it would round to
  // Examples:
  // x = 4.22
  //
  // x.toNearest(1) == 4
  // x.toNearest(0.1) == 4.2
  // x.toNearest(250) == 0
  //
  // Not within the tolerance:
  // x.toNearest(0.1, 0.01) == 4.22

  let inverse;
  let add = false;
  let val = this.valueOf();
  if (val < 0) {
    inverse = true;
    val *= -1;
  }
  let offset = val % n;
  if (offset > (n / 2)) {
    offset = n - offset;
    add = true;
  }
  if ((tolerance != null) && (offset > tolerance)) {
    return val;
  }
  if (offset < (n / 2)) {
    if (add) {
      val = val + offset;
    } else {
      val = val - offset;
    }
  } else {
    if (add) {
      val = val - (n - offset);
    } else {
      val = val + (n - offset);
    }
  }
  if (inverse) {
    val *= -1;
  }
  return val;
};


// Array

Array.prototype.remove = function(el) {
  // Remove elements
  // I/P: Regexp or Array or any other value
  // O/P: When given Regexp, removes all elements that
  //      match it (assumed strings).
  //      When Array, removes all elements that are
  //      in the given array.
  //      When any other value, removes all elements
  //      that equal that value. (compared with !==)

  if (el instanceof RegExp) {
    return this.filter(a => !el.test(a));
  } else {
    if (el instanceof Array) {
      return this.filter(a => !el.has(a));
    } else {
      return this.filter(a => el !== a);
    }
  }
};

Array.prototype.has = function(el) {
  // I/P: Anything
  // O/P: Bool: does it contain the given value?
  if (el instanceof Function) {
    return this.filter(el).length > 0;
  } else {
    return this.indexOf(el) > -1;
  }
};

Array.prototype.find = function(func) {
  for (let i = 0, end = this.length, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
    if (func(this[i])) {
      return this[i];
    }
  }
};

Array.prototype.ensure = function(el) {
  // Push if not included already
  if (this.indexOf(el) === -1) {
    return this.push(el);
  }
};

// Why not
Array.prototype.first = function() {
  return this[0];
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

Array.prototype.sortByZIndex = function() {
  // This is really stupidly specific
  return this.sort(function(a, b) {
    if (a.zIndex() < b.zIndex()) {
      return -1;
    } else {
      return 1;
    }
  });
};

// Replace r with w
Array.prototype.replace = function(r, w) {
  let ind = this.indexOf(r);
  if (ind === -1) {
    return this;
  } else {
    return this.slice(0, ind).concat(w instanceof Array ? w : [w]).concat(this.slice(ind + 1));
  }
};

Array.prototype.cannibalize = function() {
  // Returns itself with first elem at the end
  this.push(this[0]);
  return this.slice(1);
};


Array.prototype.cannibalizeUntil = function(elem) {
  // Cannibalize until elem is at index 0
  let placesAway = this.indexOf(elem);
  let head = this.splice(placesAway);
  return head.concat(this);
};

Array.prototype.without = function(elem) {
  return this.filter(x => x !== elem);
};


// DOM Element

Element.prototype.remove = function() {
  if (this.parentElement !== null) {
    return this.parentElement.removeChild(this);
  }
};

Element.prototype.removeChildren = function() {
  return (() => {
    let result = [];
    while (this.childNodes.length > 0) {
      result.push(this.childNodes[0].remove());
    }
    return result;
  })();
};

Element.prototype.toString = function() {
  return new XMLSerializer.serializeToString(this);
};

Number.prototype.places = function(x) {
  return parseFloat(this.toFixed(x));
};


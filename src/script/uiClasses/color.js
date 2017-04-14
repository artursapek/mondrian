/*

  Color

  A nice lil' class for representing and manipulating colors.

*/



class Color {

  constructor(r, g, b, a) {

    this.r = r;
    this.g = g;
    this.b = b;
    if (a == null) { a = 1.0; }
    this.a = a;
    if (this.r instanceof Color) {
      return this.r;
    }
    if (this.r === null) {
      this.hex = "none";
    } else if (this.r === "none") {
      this.hex = "none";
      this.r = null;
      this.g = null;
      this.b = null;
    } else {
      if (typeof this.r === "string") {
        if ((this.r.charAt(0) === "#") || (this.r.length === 6)) {
          // Convert hex to rgba
          this.hex = this.r.toUpperCase().replace("#", "");
          let rgb = this.hexToRGB(this.hex);
          this.r = rgb.r;
          this.g = rgb.g;
          this.b = rgb.b;
        } else if (this.r.match(/rgba?\(.*\)/gi) != null) {
          // rgb(r,g,b)
          let vals = this.r.match(/[\d\.]+/gi);
          this.r = vals[0];
          this.g = vals[1];
          this.b = vals[2];
          if (vals[3] != null) {
            this.a = parseFloat(vals[3]);
          }
          this.hex = this.rgbToHex(this.r, this.g, this.b);
        }


      } else {
        if ((this.g == null) && (this.b == null)) {
          this.g = this.r;
          this.b = this.r;
        }
        this.hex = this.rgbToHex(this.r, this.g, this.b);
      }

      this.r = Math.min(this.r, 255);
      this.g = Math.min(this.g, 255);
      this.b = Math.min(this.b, 255);

      this.r = Math.max(this.r, 0);
      this.g = Math.max(this.g, 0);
      this.b = Math.max(this.b, 0);
    }

    if (isNaN(this.r || isNaN(this.g || isNaN(this.b)))) {
      if (isNaN(this.r)) { this.r = 0; }
      if (isNaN(this.g)) { this.g = 0; }
      if (isNaN(this.b)) { this.b = 0; }
      debugger;
      this.updateHex();
    }
  }



  clone() { return new Color(this.r, this.g, this.b); }


  absorb(color) {
    this.r = color.r;
    this.g = color.g;
    this.b = color.b;
    this.a = color.a;
    this.hex = color.hex;
    if (typeof this.refresh === 'function') {
      this.refresh();
    }
    return this;
  }


  min() {
    return [this.r, this.g, this.b].sort((a, b) => a - b)[0];
  }


  mid() {
    return [this.r, this.g, this.b].sort((a, b) => a - b)[1];
  }


  max() {
    return [this.r, this.g, this.b].sort((a, b) => a - b)[2];
  }


  midpoint() { return this.max() / 2; }


  valToHex(val) {
    let chars = '0123456789ABCDEF';
    return chars.charAt((val - (val % 16)) / 16) + chars.charAt(val % 16);
  }


  hexToVal(hex) {
    let chars = '0123456789ABCDEF';
    return (chars.indexOf(hex.charAt(0)) * 16) + chars.indexOf(hex.charAt(1));
  }


  rgbToHex(r, g, b) {
    return `${this.valToHex(r)}${this.valToHex(g)}${this.valToHex(b)}`;
  }


  hexToRGB(hex) {
    let r = this.hexToVal(hex.substring(0, 2));
    let g = this.hexToVal(hex.substring(2, 4));
    let b = this.hexToVal(hex.substring(4, 6));
    return {
      r,
      g,
      b
    };
  }


  recalculateHex() {
    return this.hex = this.rgbToHex(this.r, this.g, this.b);
  }


  darken(amt) {
    let macro = val => val / amt;
    return new Color(macro(this.r), macro(this.g), macro(this.b));
  }


  lightness() {
    // returns float 0.0 - 1.0
    return ((this.min() + this.max()) / 2) / 255;
  }


  saturation() {
    let max = this.max();
    let min = this.min();
    let d = max - min;

    let sat = this.lightness() >= 0.5 ? d / (510 - max - min) : d / (max + min);
    if (isNaN(sat)) { sat = 1.0; }
    return sat;
  }


  desaturate(amt) {
    if (amt == null) { amt = 1.0; }
    let mpt = this.midpoint();
    this.r -= (this.r - mpt) * amt;
    this.g -= (this.g - mpt) * amt;
    this.b -= (this.b - mpt) * amt;
    this.hex = this.rgbToHex(this.r, this.g, this.b);
    return this;
  }


  lighten(amt) {
    if (amt == null) { amt = 0.5; }
    amt *= 255;
    this.r = Math.min(255, this.r + amt);
    this.g = Math.min(255, this.g + amt);
    this.b = Math.min(255, this.b + amt);
    this.hex = this.rgbToHex(this.r, this.g, this.b);
    return this;
  }


  toRGBString() {
    if (this.r === null) {
      return "none";
    } else {
      return `rgba(${this.r}, ${this.g}, ${this.b}, ${this.a})`;
    }
  }


  toHexString() {
    return `#${this.hex}`;
  }


  toString() {
    this.removeNaNs(); // HACK
    return this.toRGBString();
  }


  removeNaNs() {
    // HACK BUT IT WORKS FOR NOW LOL FUCK NAN
    if (isNaN(this.r)) {
      this.r = 0;
    }
    if (isNaN(this.g)) {
      this.g = 0;
    }
    if (isNaN(this.b)) {
      return this.b = 0;
    }
  }


  equal(c) {
    return this.toHexString() === c.toHexString();
  }


  updateHex() {
    return this.hex = this.rgbToHex(this.r, this.g, this.b);
  }
}





window.Color = Color;




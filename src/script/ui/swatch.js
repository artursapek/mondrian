/*

  Swatch is to Color as Point is to Posn

*/


class Swatch extends Color {
  static initClass() {
  
    this.prototype.type = null;
  }
  constructor(r, g, b, a) {
    super(r, g ,b, a);
    this.r = r;
    this.g = g;
    this.b = b;
    if (a == null) { a = 1.0; }
    this.a = a;
    if (this.r instanceof Color) {
      this.g = this.r.g;
      this.b = this.r.b;
      this.a = this.r.a;
      this.r = this.r.r;
    }
    this.$rep = $("<div class=\"swatch\"></div>");
    this.rep = this.$rep[0];
    this.refresh();
    this.$rep.on("set", (event, color) => {
      this.absorb(color);
      return this.refresh();
    });
    this;
  }

  refresh() {
    // TODO investigate this being called unnecessarily (select all shapes and see)
    if (this.r === null) {
      this.rep.style.backgroundColor = "";
      this.rep.style.border = "";
      this.rep.setAttribute("empty", "");
      this.rep.setAttribute("val", "empty");
    } else {
      this.rep.style.backgroundColor = this.toString();
      this.rep.style.border = `1px solid ${this.clone().darken(1.5).toHexString()}`;
      this.rep.removeAttribute("empty");
      this.rep.setAttribute("val", this.toString());
    }

    if (this.type != null) {
      this.rep.setAttribute("type", this.type);

      let tiedTo = this.tiedTo();
      if (tiedTo instanceof Array) {
        return Array.from(this.tiedTo()).map((elem) =>
          ((elem.data[this.type] = this.clone()),
          elem.commit()));

      } else {
        tiedTo.data[this.type] = this.clone();
        return tiedTo.commit();
      }
    }
  }


  tiedTo() { return ui.selection.elements.all; } // "fill" or "stroke"

  appendTo(selector) {
    //q(selector).appendChild(this.rep);
    return this;
  }
}
Swatch.initClass();

window.Swatch = Swatch;

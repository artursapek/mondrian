


class SwatchDuo {
  constructor(fill, stroke) {
    // I/P: two Swatch objects

    this.fill = fill;
    this.stroke = stroke;
    if (this.fill instanceof Monsvg) {
      if (this.fill.data.stroke === undefined) {
        this.stroke = new Swatch(null);
      } else {
        this.stroke = new Swatch(this.fill.data.stroke);
      }

      if (this.fill.data.fill === undefined) {
        this.fill = new Swatch(null);
      } else {
        this.fill = new Swatch(this.fill.data.fill);
      }
    }

    this.fill.type = "fill";
    this.stroke.type = "stroke";

    this.$rep = $("<div class=\"swatch-duo\"></div>");

    this.$rep.append(this.fill.$rep);
    this.$rep.append(this.stroke.$rep);
    this.$rep.attr("key", this.toString());

    this.rep = this.$rep[0];
  }

  tiedTo() {}

  toString() {
    return `${this.fill.toHexString()}/${this.stroke.toHexString()}`;
  }
}



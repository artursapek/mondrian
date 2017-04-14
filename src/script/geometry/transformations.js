class Transformations {
  constructor(owner, transformations) {
    this.owner = owner;
    this.transformations = transformations;
    let transform = this.owner.rep.getAttribute("transform");
    this.transformations.map(t => t.family = this);
    if (transform != null) { this.parseExisting(transform); }
  }

  commit() {
    return this.owner.data.transform = this.toAttr();
  }

  toAttr() {
    return this.transformations.map(t => t.toAttr()).join(" ");
  }

  toCSS() {
    return this.transformations.map(t => t.toCSS()).join(" ");
  }

  get(key) {
    let f = this.transformations.filter(t => t.key === key);
    if (f.length > 0) { return f[0]; }
  }

  parseExisting(transform) {
    let operations = transform.match(/\w+\([^\)]*\)/g);
    return (() => {
      let result = [];
      for (let op of Array.from(operations)) {
      // get the keyword, like "rotate" from "rotate(10)"
        let item;
        let keyword = op.match(/^\w+/g)[0];
        let alreadyDefined = this.get(keyword);
        if (alreadyDefined != null) {
          item = alreadyDefined.parse(op);
        } else {
          let representative = {
            rotate: RotateTransformation,
            scale:  ScaleTransformation
          }[keyword];
          if (representative != null) {
            let newlyDefined = new representative().parse(op);
            newlyDefined.family = this;
            item = this.transformations.push(newlyDefined);
          }
        }
        result.push(item);
      }
      return result;
    })();
  }

  applyAsCSS(rep) {
    let og = `-${this.owner.origin.x} -${this.owner.origin.y}`;
    let tr = this.toCSS();
    rep.style.transformOrigin = og;
    rep.style.webkitTransformOrigin = og;
    rep.style.mozTransformOrigin = og;
    rep.style.transform = tr;
    rep.style.webkitTransformOrigin = og;
    rep.style.webkitTransform = tr;
    rep.style.mozTransformOrigin = og;
    return rep.style.mozTransform = tr;
  }
}

class RotateTransformation {
  static initClass() {
  
    this.prototype.key = "rotate";
  }
  constructor(deg, family) {
    this.deg = deg;
    this.family = family;
  }

  toAttr() {
    return `rotate(${this.deg.places(3)} ${this.family.owner.center().x.places(3)} ${this.family.owner.center().y.places(3)})`;
  }

  toCSS() {
    return `rotate(${this.deg.places(3)}deg)`;
  }

  rotate(a) {
    this.deg += a;
    this.deg %= 360;
    return this;
  }

  parse(op) {
    let ref, x, y;
    return [this.deg, x, y] = Array.from(ref = op.match(/[\d\.]+/g).map(parseFloat)), ref;
  }
}
RotateTransformation.initClass();


class ScaleTransformation {
  static initClass() {
  
    this.prototype.key = "scale";
  }
  constructor(x, y) {
    if (x == null) { x = 1; }
    this.x = x;
    if (y == null) { y = 1; }
    this.y = y;
  }

  toAttr() {
    return `scale(${this.x} ${this.y})`;
  }

  toCSS() {
    return `scale(${this.x}, ${this.y})`;
  }

  parse(op) {
    let ref;
    return [this.x, this.y] = Array.from(ref = op.match(/[\d\.]+/g).map(parseFloat)), ref;
  }

  scale(x, y) {
    if (x == null) { x = 1; }
    if (y == null) { y = 1; }
    this.x *= x;
    return this.y *= y;
  }
}
ScaleTransformation.initClass();

class TranslateTransformation {
  static initClass() {
  
    this.prototype.key = "translate";
  }
  constructor(x, y) {
    if (x == null) { x = 0; }
    this.x = x;
    if (y == null) { y = 1; }
    this.y = y;
  }

  toAttr() {
    return `translate(${this.x} ${this.y})`;
  }

  toCSS() {
    return `translate(${this.x}px, ${this.y}px)`;
  }

  parse(op) {
    let ref;
    return [this.x, this.y] = Array.from(ref = op.match(/[\-\d\.]+/g).map(parseFloat)), ref;
  }

  nudge(x, y) {
    console.log(x, y);
    this.x += x;
    return this.y -= y;
  }
}
TranslateTransformation.initClass();



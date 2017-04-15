export default class Range {
  constructor(min, max) {
    this.min = min;
    this.max = max;
  }

  length() { return this.max - this.min; }

  contains(n) {
    return (n > this.min) && (n < this.max);
  }

  containsInclusive(n, tolerance) {
    if (tolerance == null) { tolerance = 0; }
    return (n >= (this.min - tolerance)) && (n <= (this.max + tolerance));
  }

  intersects(n) {
    return (n === this.min) || (n === this.max);
  }

  fromList(alon) {
    this.min = Math.min.apply(this, alon);
    this.max = Math.max.apply(this, alon);
    return this;
  }

  static fromList(alor) {
    let mins = alor.map(r => r.min);
    let maxs = alor.map(r => r.max);
    let min = Math.min.apply(this, mins);
    let max = Math.max.apply(this, maxs);
    return new this(min, max);
  }

  nudge(amt) {
    this.min += amt;
    return this.max += amt;
  }

  scale(amt, origin) {
    // Amt is an integer
    // Origin is also an integer
    this.min += (this.min - origin) * (amt - 1);
    return this.max += (this.max - origin) * (amt - 1);
  }

  toString() {
    return `[${this.min.places(4)},${this.max.places(4)}]`;
  }

  percentageOfValue(v) {
    return (v - this.min) / this.length();
  }
}



/*

  Polynomial

*/

export default class Polynomial {
  static initClass() {
    this.prototype.tolerance = 1e-6;
    this.prototype.accuracy = 6;
  }

  constructor(coefs) {
    this.coefs = coefs;
    let l = this.coefs.length;
    for (let i of Object.keys(this.coefs || {})) {
      let v = this.coefs[i];
      this[`p${l - i - 1}`] = v;
    }
    this.coefs = this.coefs.reverse();
    this;
  }


  degrees() {
    return this.coefs.length - 1;
  }


  interpolate(xs, xy, n, offset, x) {
    // I have no fucking idea what this does or how it does it.
    let i;
    let y = 0;
    let dy = 0;
    let ns = 0;

    let c = [n];
    let d = [n];

    let diff = Math.abs(x - xs[offset]);
    for (i = 0, end = n + 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
      var asc, end;
      let dift = Math.abs(x - xs[offset + i]);

      if (dift < diff) {
        ns = i;
        diff = dift;
      }

      c[i] = (d[i] = ys[offset + i]);
    }

    y = ys[offset + ns];
    ns -= 1;

    for (i = 1, end1 = m + 1, asc1 = 1 <= end1; asc1 ? i <= end1 : i >= end1; asc1 ? i++ : i--) {
      var asc1, end1;
      for (i = 0, end2 = (n - m) + 1, asc2 = 0 <= end2; asc2 ? i <= end2 : i >= end2; asc2 ? i++ : i--) {
        var asc2, end2;
        let ho = xs[offset + i] - x;
        let hp = xs[offset + i + m] - x;
        let w = c[i + 1] - d[i];
        let den = ho - hp;

        if (den === 0.0) {
          let result = {
            y: 0,
            dy: 0
          };
          break;
        }

        den = w / den;
        d[i] = hp * den;
        c[i] = ho * den;
      }

      dy = ((2 * (ns + 1)) < (n - m)) ? c[ns + 1] : d[(ns -= 1)];
      y += dy;
    }

    return { y, dy};
  }


  eval(x) {
    let result = 0;
    for (let start = this.coefs.length - 1, i = start, asc = start <= 0; asc ? i <= 0 : i >= 0; asc ? i++ : i--) {
      result = (result * x) + this.coefs[i];
    }

    return result;
  }


  add(that) {
    let newCoefs = [];
    let d1 = this.degrees();
    let d2 = that.degrees();
    let dmax = Math.max(d1, d2);

    for (let i = 0, end = dmax, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
      let v1 = (i <= d1) ? this.coefs[i] : 0;
      let v2 = (i <= d2) ? that.coefs[i] : 0;

      newCoefs[i] = v1 + v2;
    }

    newCoefs = newCoefs.reverse();

    return new Polynomial(newCoefs);
  }


  roots() {
    switch (this.coefs.length - 1) {
      case 0:
        return [];
      case 1:
        return this.linearRoot();
      case 2:
        return this.quadraticRoots();
      case 3:
        return this.cubicRoots();
      case 4:
        return this.quarticRoots();
      default:
        return [];
    }
  }


  derivative() {
    let newCoefs = [];

    for (let i = 1, end = this.degrees(), asc = 1 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
      newCoefs.push(i * this.coefs[i]);
    }

    return new Polynomial(newCoefs.reverse());
  }


  bisection(min, max) {
    let result;
    let minValue = this.eval(min);
    let maxValue = this.eval(max);

    if (Math.abs(minValue) <= this.tolerance) {
      return min;
    } else if (Math.abs(maxValue) <= this.tolerance) {
      return max;
    } else if ((minValue * maxValue) <= 0) {
      let tmp1 = Math.log(max - min);
      let tmp2 = Math.LN10 * this.accuracy;
      let iters = Math.ceil((tmp1 + tmp2) / Math.LN2);

      for (let i = 0, end = iters - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
        result = 0.5 * (min + max);
        let value = this.eval(result);

        if (Math.abs(value) <= this.tolerance) {
          break;
        }

        if ((value * minValue) < 0) {
          max = result;
          maxValue = value;
        } else {
          min = result;
          minValue = value;
        }
      }
    }

    return result;
  }


  rootsInterval(min, max) {
    let root;
    let results = [];

    if (this.degrees() === 1) {
      root = this.bisection(min, max);
      if (root != null) {
        results.push(root);
      }
    } else {
      let deriv = this.derivative();

      let droots = deriv.rootsInterval(min, max);
      let dlen = droots.length;

      if (dlen > 0) {
        root = this.bisection(min, droots[0]);
        if (root != null) { results.push(root); }

        for (let i = 0, end = dlen - 2, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
          let r = droots[i];
          root = this.bisection(r, droots[i + 1]);
          if (root != null) { results.push(root); }
        }

        root = this.bisection(droots[dlen - 1], max);
        if (root != null) { results.push(root); }
      } else {
        root = this.bisection(min, max);
        if (root != null) { results.push(root); }
      }
    }

    return results;
  }


  // Root functions
  // linear, quadratic, cubic

  linearRoot() {
    let result = [];

    if (this.p1 !== 0) {
      result.push(-this.p0 / this.p1);
    }

    return result;
  }


  quadraticRoots() {
    let results = [];

    let a = this.p2;
    let b = this.p1 / a;
    let c = this.p0 / a;
    let d = (b * b) - (4 * c);

    if (d > 0) {
      let e = Math.sqrt(d);
      results.push(0.5 * (-b + e));
      results.push(0.5 * (-b - e));
    } else if (d === 0) {
      results.push(0.5 * -b);
    }

    return results;
  }


  cubicRoots() {
    let tmp;
    let results = [];
    let c3 = this.p3;
    let c2 = this.p2 / c3;
    let c1 = this.p1 / c3;
    let c0 = this.p0 / c3;

    let a = ((3 * c1) - (c2 * c2)) / 3;
    let b = (((2 * c2 * c2 * c2) - (9 * c1 * c2)) + (27 * c0)) / 27;
    let offset = c2 / 3;
    let discrim = ((b * b) / 4) + ((a * a * a) / 27);
    let halfB = b/2;

    if ((Math.abs(discrim)) <= 1e-6) {
      discrim = 0;
    }

    if (discrim > 0) {
      let e = Math.sqrt(discrim);

      tmp = -halfB + e;

      let root = tmp >= 0 ? Math.pow(tmp, 1/3) : -Math.pow(-tmp, 1/3);

      tmp = -halfB - e;

      root += tmp >= 0 ? Math.pow(tmp, 1/3) : -Math.pow(-tmp, 1/3);

      results.push((root - offset));

    } else if (discrim < 0) {

      let distance = Math.sqrt(-a/3);
      let angle = Math.atan2(Math.sqrt(-discrim), -halfB) / 3;
      let cos = Math.cos(angle);
      let sin = Math.sin(angle);
      let sqrt3 = Math.sqrt(3);

      results.push((2*distance*cos) - offset);
      results.push((-distance * (cos + (sqrt3 * sin))) - offset);
      results.push((-distance * (cos - (sqrt3 * sin))) - offset);
    } else {
      if (halfB >= 0) {
        tmp = -Math.pow(halfB, 1/3);
      } else {
        tmp = Math.pow(-halfB, 1/3);
      }

      results.push((2 * tmp) - offset);

      results.push(-tmp - offset);
    }

    return results;
  }
}
Polynomial.initClass();


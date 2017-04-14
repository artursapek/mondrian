import Monsvg from 'script/geometry/monsvg'

/*



 */

class Tspan extends Monsvg {
  static initClass() {
    this.prototype.type = 'tspan';
  }


  constructor(data) {
    this.data = data;
  }
}
Tspan.initClass();


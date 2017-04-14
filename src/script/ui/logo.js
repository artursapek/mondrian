/*

  Animated Mondy logo for indicating progress

*/

ui.logo = {
  animate() {
    this._animateRequests += 1;

    if (this._animateRequests === 1) {
      clearInterval(this.animateLogoInterval);
      return this.animateLogoInterval = setInterval(() => {
        if (this._animateRequests === 0) {
          return this._reset();
        } else {
          let vals = [ui.colors.logoRed, ui.colors.logoYellow, ui.colors.logoBlue];
          let a = parseInt(Math.random() * 3);
          dom.$logoLeft.css("background-color", vals[a]);
          vals = vals.slice(0, a).concat(vals.slice(a + 1));
          a = parseInt(Math.random() * 2);
          dom.$logoMiddle.css("background-color", vals[a]);
          vals = vals.slice(0, a).concat(vals.slice(a + 1));
          return dom.$logoRight.css("background-color", vals[0]);
        }
      }
      , 170);
    }
  },

  stopAnimating() {
    this._animateRequests -= 1;

    if (this._animateRequests < 0) {
      return this._animateRequests = 0;
    }
  },

  _animateRequests: 0,

  _reset() {
    clearInterval(this.animateLogoInterval);
    dom.$logoLeft.css("background-color", ui.colors.logoRed);
    dom.$logoMiddle.css("background-color", ui.colors.logoYellow);
    return dom.$logoRight.css("background-color", ui.colors.logoBlue);
  }
};

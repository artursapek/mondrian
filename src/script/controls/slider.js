import Control from 'script/controls/control';

class Slider extends Control {

  constructor(attrs) {
    // I/P:
    //   object of:
    //     rep: div containing slider elements:
    //       %div.slider.left-icon
    //       %div.slider.right-icon
    //       %div.slider.track
    //     commit: callback for every change of value
    //     inverse: goes max to min instead
    //     onRelease: callback for when the user stops dragging
    //     valueTipFormatter: a method that returns a string
    //                        given the value of @read().
    //                        If defined, a live tip will
    //                        appear under the slider that shows
    //                        the current value when it's being moved.

    super(attrs);

    this.hotkeys = {};

    this.$knob = this.$rep.find('.knob');
    this.$track = this.$rep.find('.track');
    if (this.valueTipFormatter != null) {
      this.$knob.append(this.$tip = $("<div class=\"slider tip\"></div>"));
    }

    this.knobWidth = this.$knob.width();

    this.trackMin = parseFloat(this.$track.css("left"));
    this.trackWidth = parseFloat(this.$track.css("width")) - this.knobWidth;
    this.trackMax = this.trackMin + this.trackWidth;

    this.$knob.on("nudge", () => {
      this.commit();
      return (this.$tip != null ? this.$tip.show().text(this.valueTipFormatter(this.read())) : undefined);
    })
    .on("stopDrag", () => {
      if (typeof this.onRelease === 'function') {
        this.onRelease(this.read());
      }
      return (this.$tip != null ? this.$tip.hide() : undefined);
      })
    .attr("drag-x", `${this.trackMin} ${this.trackMax}`);

    this.set(0.0);

    this.$iconLeft = this.$rep.find(".left-icon");
    this.$iconRight = this.$rep.find(".right-icon");

    this.$knob.on("click", e => e.stopPropagation());

    this.$iconLeft.on("click", e => {
      e.stopPropagation();
      this.set(0.0);
      return this.commit();
    });

    this.$iconRight.on("click", e => {
      e.stopPropagation();
      this.set(1.0);
      return this.commit();
    });

    this.$track = this.$rep.find(".track");

    this.$rep.on("release", () => {
      return (typeof this.onRelease === 'function' ? this.onRelease(this.read()) : undefined);
    });
  }



  read() {
    return this.leftCSSToFloat(parseFloat(this.$knob.css("left")));
  }


  write(value) {
    return this.$knob.css("left", this.floatToLeftCSS(value));
  }


  floatToLeftCSS(value) {
    let l;
    value = Math.min(1.0, (Math.max(0.0, value)));
    if (this.inverse) {
      value = 1.0 - value;
    }

    return l = ((this.trackWidth * value) + this.trackMin).px();
  }


  leftCSSToFloat(left) {
    let f = (parseFloat(left) - this.trackMin) / this.trackWidth;
    if (this.inverse) {
      return 1.0 - f;
    } else {
      return f;
    }
  }
}





/*

  Color picker

*/

ui.utilities.color = new Utility({
  setup() {

    this.rep = q("#color-picker-ut");
    this.poolContainer = q("#pool-container");
    this.poolContext = q("#color-picker-ut canvas#color-pool").getContext("2d");
    this.saturationSliderContainer = q("#saturation-slider");
    // We get two of these bad boys due to how the infinite scroll illusion works.
    this.currentIndicator1 = q("#color-marker1");
    this.currentIndicator2 = q("#color-marker2");
    this.inputs = {
      r: q("#color-r"),
      g: q("#color-g"),
      b: q("#color-b"),
      hex: q("#color-hex")
    };

    this.hide();

    // Build the infinite color pool.
    this.drawPool();

    // Set up infinite scroll.
    this.poolContainer.onscroll = function(e) {
      if (this.scrollTop === 0) {
        this.scrollTop = 1530;
      } else if (this.scrollTop === (3060 - 260)) {
        this.scrollTop = 1530 - 260;
      }
      // This lets us keep the mouse down and scroll at the same time.
      // Super cool effect nobody will notice, but it's 2 loc so w/e
      if (ui.cursor.down) {
        return ui.utilities.color.selectColor(ui.cursor.lastEvent);
      }
    };

    this.saturationSlider = new Slider({
      rep: this.saturationSliderContainer,
      commit: val => {
        this.drawPool(val);
        this.set(this.getColorAt(this.selected));
        return this.center;
      }
    });

    this.rControl = new NumberBox({
      rep: this.inputs.r,
      min: 0,
      max: 255,
      value: 0,
      commit: val => {
        return this.alterVal("r", val);
      }
    });

    this.gControl = new NumberBox({
      rep: this.inputs.g,
      min: 0,
      max: 255,
      value: 0,
      commit: val => {
        return this.alterVal("g", val);
      }
    });

    this.gControl = new NumberBox({
      rep: this.inputs.b,
      min: 0,
      max: 255,
      value: 0,
      commit: val => {
        return this.alterVal("b", val);
      }
    });

    return this.hexControl = new TextBox({
      rep: this.inputs.hex,
      value: 0,
      commit: val => {
        this.set(new Color(val));
        this.refresh();
        this.selectedColor.updateHex();
        return this.hexControl.write(this.selectedColor.hex);
      },
      hotkeys: {
        blacklist: null
      },
      maxLength: 6
    });
  },


  alterVal(which, val) {
    this.selectedColor[which] = val;
    this.selectedColor.recalculateHex();
    this.set(this.selectedColor);
    return this.refresh();
  },


  refresh() {
    // Update the color pool saturation
    this.drawPool(this.selectedColor.saturation());

    // Update the saturation slider
    this.saturationSlider.write(this.selectedColor.saturation());

    // Update the position of the indicator
    this.selected = this.getPositionOf(this.selectedColor);
    return this.updateIndicator().centerOnIndicator();
  },


  shouldBeOpen() { return false; }, // lol


  onshow() {
    this.poolContainer.scrollTop = 600;
    this.selectedColor = new Color(this.setting.getAttribute("val"));
    this.selected = this.getPositionOf(this.selectedColor);
    this.saturationSlider.set(this.selectedColor.saturation());
    this.drawPool(this.selectedColor.saturation());
    this.updateIndicator();
    this.centerOnIndicator();
    return trackEvent("Color", "Open picker");
  },


  ensureVisibility() {
    this.rep.style.top = `${Math.min(ui.window.height() - 360, parseFloat(this.rep.style.top))}px`;
    return this.saveOffset();
  },


  centerOnIndicator() {
    this.poolContainer.scrollTop = parseFloat(this.currentIndicator1.style.top) - 130;
    return this;
  },


  setting: null,


  set(color) {
    this.selectedColor = color;

    $(this.setting).trigger("set", [color]);

    $(this.inputs.r).val(color.r);
    $(this.inputs.g).val(color.g);
    $(this.inputs.b).val(color.b);
    return $(this.inputs.hex).val(color.hex);
  },


  selectColor(e) {
    this.selected = new Posn(e).subtract(this.offset).subtract(new Posn(10, 12));
    this.selected.x = Math.max(0, this.selected.x);
    this.selected.x = Math.min(260, this.selected.x);
    this.selected.y += this.poolContainer.scrollTop;
    let color = this.getColorAt(this.selected);
    this.set(color);
    return this.updateIndicator();
  },


  updateIndicator() {
    if (this.selectedColor.toString() === "none") {
      this.hideIndicator(this.currentIndicator1);
      return this.hideIndicator(this.currentIndicator2);
    } else {
      this.showIndicator(this.currentIndicator1);
      this.showIndicator(this.currentIndicator2);
      this.positionIndicator(this.currentIndicator1, this.selected);
      this.selected.y = (this.selected.y + 1530) % 3060;
      this.positionIndicator(this.currentIndicator2, this.selected);
      return this;
    }
  },


  showIndicator(indicator) {
    return indicator.style.display = "block";
  },

  hideIndicator(indicator) {
    return indicator.style.display = "none";
  },


  getColorAt(posn) {
    let data = this.poolContext.getImageData(posn.x, posn.y, 1, 1);
    return new Color(data.data[0], data.data[1], data.data[2]);
  },


  getPositionOf(color) {
    let y;
    let primary = color.max();
    let secondary = color.mid();
    let tertiary = color.min();

    switch (primary) {
      case color.r:
        y = 0;
        switch (secondary) {
          case color.g:
            y += secondary;
            break;
          case color.b:
            y -= secondary;
            break;
        }
        break;

      case color.g:
        y = 510;
        switch (secondary) {
          case color.b:
            y += secondary;
            break;
          case color.r:
            y -= secondary;
            break;
        }
        break;

      case color.b:
        y = 1020;
        switch (secondary) {
          case color.r:
            y += secondary;
            break;
          case color.g:
            y -= secondary;
            break;
        }
        break;
    }

    if (y < 0) {
      y += 1530;
    }

    y %= 1530;

    let x = 260 - (color.lightness() * 260);

    return new Posn(x, y);
  },


  positionIndicator(indicator, posn) {
    indicator.className = posn.x < 130 ? "indicator black" : "indicator white";
    indicator.style.left = posn.x.px();
    return indicator.style.top = (posn.y).px();
  },


  sample(elem) {
    this.setting = ui.fill.rep;
    this.set((elem.data.fill != null) ? elem.data.fill : ui.colors.null);
    this.setting = ui.stroke.rep;
    return this.set((elem.data.stroke != null) ? elem.data.stroke : ui.colors.null);
  },


  drawPool(saturation) {

    if (saturation == null) { saturation = 1.0; }
    let gradient = this.poolContext.createLinearGradient(0, 0, 0, 3060);

    let colors = [ui.colors.red, ui.colors.yellow, ui.colors.green,
              ui.colors.teal, ui.colors.blue, ui.colors.pink];

    for (let i = 0; i <= 12; i++) {
      gradient.addColorStop((1 / 12) * i, colors[i % 6].clone().desaturate(1.0 - saturation).toHexString());
    }

    this.poolContext.fillStyle = gradient;
    this.poolContext.fillRect(0, 0, 260, 3060);

    // 1530 3060

    let wb = this.poolContext.createLinearGradient(0, 0, 260, 0);
    wb.addColorStop(0.02, "#FFFFFF");
    wb.addColorStop(0.5, "rgba(255, 255, 255, 0.0)");
    wb.addColorStop(0.5, "rgba(0, 0, 0, 0.0)");
    wb.addColorStop(0.98, "#000000");

    this.poolContext.fillStyle = wb;
    return this.poolContext.fillRect(0, 0, 260, 3060);
  }
});



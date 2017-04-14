import ui from 'script/ui/ui';
/*

  Tooltips
  ______   ___________
  |  |  | |           |
  | |x| | |  Pen   P  |
  |_____| |___________|

*/

ui.tooltips = {
  FADEIN_DELAY: 500,
  FADEOUT_DELAY: 300,
  FADE_DURATION: 50,

  _showTimeout: undefined,
  _hideTimeout: undefined,
  _$visible:    undefined,

  $elemFor(tool) {
    return $(`.tool-button[tool=\"${tool}\"] .tool-info`);
  },

  activate(tool) {
    let $tooltip = this.$elemFor(tool);

    if ((this._$visible != null) && (this._$visible.text() === $tooltip.text())) {
      return clearTimeout(this._hideTimeout);
    }

    if (this._$visible != null) {
      clearTimeout(this._hideTimeout);
      this._$visible.hide();
      $tooltip.show();
      return this._$visible = $tooltip;
    } else {
      clearTimeout(this._showTimeout);
      return this._showTimeout = setTimeout(() => {
        $tooltip.fadeIn(this.FADE_DURATION);
        return this._$visible = $tooltip;
      }
      , this.FADEIN_DELAY);
    }
  },


  deactivate(tool) {
    let $tooltip = this.$elemFor(tool);

    if (this._$visible != null) {
      if (this._$visible.text() === $tooltip.text()) {
        return this._hideTimeout = setTimeout(() => {
          $tooltip.fadeOut(this.FADE_DURATION);
          return this._$visible = undefined;
        }
        , this.FADEOUT_DELAY);
      }
    } else {
      return clearTimeout(this._showTimeout);
    }
  },

  hideVisible(tool) {
    clearTimeout(this._showTimeout);
    if (this._$visible != null) {
      this._$visible.hide();
    }
    return this._$visible = undefined;
  }
};

/*

  TextEditable

  A content-editable <p> that lives in the #typography div
  Used to edit the contents of a Text object, each of which
  are tied to one of these.

*/

class TextEditable {

  constructor(owner) {
    this.owner = owner;
  }


  refresh() {
    let resetToBlank;
    this.$rep.text(this.owner.content);
    if (this.owner.data['font-size'] != null) {
      this.$rep.css({'font-size': (float(this.owner.data['font-size']) * ui.canvas.zoom) + 'px'});
    }

    if (this.owner.data['font-family'] != null) {
      this.$rep.css({'font-family': this.owner.data['font-family']});
    }

    let tr = this.owner.transformations.get('translate');

    if (this.owner.rep.textContent === '') {
      // $.fn.offset returns 0, 0 if the contents are empty
      resetToBlank = true;
      this.owner.rep.textContent = '[FILLER]';
      this.$rep.text('[FILLER]');
    }

    let ownerOffset = this.owner.$rep.offset();

    let left = (ownerOffset.left - ui.canvas.normal.x);
    let top  = (ownerOffset.top -  ui.canvas.normal.y);

    this.$rep.css({
      left: left.px(),
      top:  top.px(),
      color: this.owner.data.fill
    });

    /*
    @rep.style.textShadow = @owner.data.strokeWidth.px()
    @rep.style.webkitTextStrokeWidth = @owner.data.strokeWidth.px()
    */

    this.$rep.css;

    this.owner.transformations.applyAsCSS(this.rep);

    // Hack
    let myOffset = this.$rep.offset();

    if (resetToBlank) {
      this.$rep.text('');
      this.owner.rep.textContent = '';
    }

    return this.$rep.css({
      left: ((left + ownerOffset.left) - myOffset.left).px(),
      top: ((top + ownerOffset.top) - myOffset.top).px()
    });
  }


  show() {
    // We rebuild the rep every single time we want it
    // because it's inexpensive and it more reliably
    // avoids weird focus/blur issues.
    this.$rep = $(`\
<div class="text" contenteditable="true"
   quarantine spellcheck="false">${this.owner.content}</div>\
`);
    this.rep = this.$rep[0];

    $('#typography').append(this.$rep);

    this.$rep.one('blur', () => {
      this.commit();
      return this.owner.displayMode();
    });

    this.rep.style.display = "block";

    return this.refresh();
  }

  hide() {
    if ((this.rep == null)) { return; }
    this.rep.remove();
    return this.rep = undefined;
  }

  focus() {
    return this.$rep.focus();
  }

  commit() {
    let oldOr = this.owner.originRotated();
    this.owner.setContent(this.$rep.text().replace(/$\s+/g, ''));
    let newOr = this.owner.originRotated();
    return this.owner.nudge(oldOr.x - newOr.x, oldOr.y - newOr.y);
  }
}







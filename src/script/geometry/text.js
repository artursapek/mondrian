import Monsvg from 'script/geometry/monsvg'

/*


 */


class Text extends Monsvg {
  static initClass() {
    this.prototype.type = 'text';
  
    this.prototype.caching = false;
  }


  constructor(data, content) {

    this.data = data;
    if (content == null) { content = ""; }
    this.content = content;
    this.data = $.extend({
      x: 0,
      y: 0,
      'font-size': ui.utilities.typography.sizeControl.read(),
      'font-family': ui.utilities.typography.faceControl.selected.val
    }
    , this.data);

    this.data.x = float(this.data.x);
    this.data.y = float(this.data.y);

    super(this.data);

    this.transformations = new Transformations(this, [
      new RotateTransformation(0),
      new ScaleTransformation(1, 1),
      new TranslateTransformation(0, 0)
    ]);

    this.origin = new Posn(this.data.x, this.data.y);
    this.textEditable = new TextEditable(this);

    this;
  }

  setContent(content) {
    this.content = content;
    return this.commit();
  }

  setSize(size) {
    return this.data['font-size'] = size;
  }

  setFace(face) {
    return this.data['font-family'] = face;
  }

  commit() {
    this.data.x = this.origin.x;
    this.data.y = this.origin.y;
    this.rep.textContent = this.content;
    this.transformations.commit();
    return super.commit(...arguments);
  }

  editableMode() {
    this.textEditable.show();
    this.hide();
    ui.textEditing = this;
    return ui.selection.elements.deselectAll();
  }

  displayMode() {
    this.textEditable.hide();
    this.show();
    ui.textEditing = undefined;
    return this.adjustForScale();
  }

  show() {
    return this.rep.style.display = "block";
  }

  hide() {
    return this.rep.style.display = "none";
  }

  originRotated() {
    return this.origin.clone().rotate(this.metadata.angle, this.center());
  }

  simulateInSandbox() {
    return $("#text-sandbox").text(this.content).css({
      'font-size':   this.data['font-size'],
      'font-family': this.data['font-family']});
  }

  selectAll() {
    this.editableMode();
    this.textEditable.focus();
    document.execCommand('selectAll', false, null);
  }

  delete() {
    super.delete(...arguments);
    // Make sure we never leave behind stray textEditable divs
    return this.textEditable.hide();
  }

  toSVG() {
    // Text elements are not self-closing so
    // we need to do a bit more work here
    let self = super.toSVG(...arguments);
    self.textContent = this.content;
    return self;
  }

  normalizedOrigin() {
    return this.origin.clone().rotate(-this.metadata.angle, this.center());
  }

  nudge(x, y) {
    this.origin.nudge(x, y);
    this.adjustForScale();
    return this.commit();
  }

  rotate(a, origin, adjust) {
    if (origin == null) { origin = this.center(); }
    if (adjust == null) { adjust = true; }
    this.metadata.angle += a;
    this.metadata.angle %= 360;

    let oc = this.center();
    let nc = this.center().rotate(a, origin);

    // Don't use nudge method because we don't want adjustments made
    this.origin.nudge(nc.x - oc.x, oc.y - nc.y);
    this.transformations.get('rotate').rotate(a);

    if (adjust) { this.adjustForScale(); }

    return this.commit();
  }

  scale(x, y, origin) {
    // Look at path.coffee#scale for better annotations of this same procedure
    let { angle } = this.metadata;

    if (angle !== 0) {
      // Normalize rotation
      this.rotate(360 - angle, origin);
    }

    // The only real point in text objects is the origin
    this.origin.scale(x, y, origin);
    this.transformations.get('scale').scale(x, y);
    this.adjustForScale();

    if (angle !== 0) {
      // Rotate back into place
      this.rotate(angle, origin);
    }

    return this.commit();
  }

  adjustForScale() {
    let scale = this.transformations.get('scale');
    let translate = this.transformations.get('translate');

    let a = this.metadata.angle;
    this.rotate(-a, this.center(), false);
    translate.y = ((scale.y - 1) / scale.y) * -this.origin.y;
    translate.x = ((scale.x - 1) / scale.x) * -this.origin.x;
    this.rotate(a, this.center(), false);
    return this.commit();
  }


  hover() {
    if (ui.selection.elements.all.has(this)) { return; }
    /*
    $("#text-underline").show().css
      left: @origin.x * ui.canvas.zoom
      top:  @origin.y * ui.canvas.zoom
      width: "#{@width() * ui.canvas.zoom}px"
    */
  }

  unhover() {
    return $("#text-underline").hide();
  }

  drawToCanvas() {}

  clone() {
    let cloned = super.clone(...arguments);
    cloned.setContent(this.content);
    return cloned;
  }

  width() {
    this.simulateInSandbox();
    return $("#text-sandbox")[0].clientWidth * this.transformations.get('scale').x;
  }

  height() {
    return this.data['font-size'] * this.transformations.get('scale').y;
  }

  xRange() {
    return new Range(this.origin.x, this.origin.x + this.width());
  }

  yRange() {
    return new Range(this.origin.y - this.height(), this.origin.y);
  }

  overlapsRect(rect) {
    return this.bounds().toRect().overlaps(rect);
  }

  setupToCavnas(context) {
    let scale = this.transformations.get('scale');
    let orr = this.originRotated();

    context.translate(orr.x, orr.y);
    context.rotate(this.metadata.angle * (Math.PI / 180));

    context.scale(scale.x, scale.y);

    context.font = `${this.data['font-size']}px ${this.data['font-family']}`;
    return context;
  }

  drawToCanvas(context) {
    let scale = this.transformations.get('scale');
    context = this.setupToCavnas(context);

    context.fillText(this.content.strip(), 0, 0);
    return context = this.finishToCanvas(context);
  }

  finishToCanvas(context) {
    let scale = this.transformations.get('scale');
    let orr = this.originRotated();

    context.scale(1 / scale.x, 1 / scale.y);

    context.rotate(-this.metadata.angle * (Math.PI / 180));
    context.translate(-orr.x, -orr.y);
    return context;
  }
}
Text.initClass();


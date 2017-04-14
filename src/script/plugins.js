/*

  jQuery plugins
  Baw baw baw. Let's use these with moderation.

*/


$.fn.hotkeys = function(hotkeys) {
  // Grant an input field its own hotkeys upon focus.
  // On blur, reset to the app hotkeys.
  let self = this;

  return $(this).attr("h", "").focus(function() {
    ui.hotkeys.enable();
    return ui.hotkeys.using = {
      context: self,
      ignoreAllOthers: false,
      down: hotkeys.down,
      up: hotkeys.up,
      always: hotkeys.always
    };}).blur(function() {});
};
    //ui.hotkeys.use "app"



$.fn.nudge = function(x, y, min, max) {
  let minmax;
  if (min == null) { min = {x: -1/0, y: -1/0}; }
  if (max == null) { max = {x: 1/0, y: 1/0}; }
  let $self = $(this);
  let left = $self.css("left");
  let top = $self.css("top");

  if ($self.attr("drag-x")) {
    minmax = $self.attr("drag-x").split(" ").map(x => parseInt(x, 10));
    min.x = minmax[0];
    max.x = minmax[1];
  }
  if ($self.attr("drag-y")) {
    minmax = $self.attr("drag-y").split(" ").map(x => parseInt(x, 10));
    min.y = minmax[0];
    max.y = minmax[1];
  }

  $self.css({
    left: Math.max(min.x, Math.min(max.x, (parseFloat(left) + x))).px(),
    top:  Math.max(min.y, Math.min(max.y, (parseFloat(top) + y))).px()
  });
  return $self.trigger("nudge");
};


$.fn.fitToVal = function(add) {
  if (add == null) { add = 0; }
  let $self = $(this);
  let resizeAction = function(e) {
    let val = $self.val();
    let $ghost = $(`<div id=\"ghost\">${val}</div>`).appendTo(dom.$body);
    $self.css({
      width: `${$ghost.width() + add}px`});
    return $ghost.remove();
  };

  $self.unbind('keyup.fitToVal').on('keyup.fitToVal', resizeAction);
  return resizeAction();
};

$.fn.disable = function() {
  let $self = $(this);
  return $self.attr("disabled", "");
};

$.fn.enable = function() {
  let $self = $(this);
  return $self.removeAttr("disabled");
};

$.fn.error = function(msg) {
  let $self = $(this);
  let $err = $self.siblings('.error-display').show();
  $err.find('.lifespan').removeClass('empty');
  $err.find('.msg').text(msg);
  async(() => $err.find('.lifespan').addClass('empty'));
  return setTimeout(() => $err.hide()
  , 5 * 1000);
};

$.fn.pending = function(html) {
  let $self = $(this);
  let oghtml = $self.html();
  $self.addClass("pending");
  $self.html(html);
  return function() {
    $self.html(oghtml);
    return $self.removeClass("pending");
  };
};


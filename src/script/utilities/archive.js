import ui from 'script/ui/ui';
import Utility from 'script/utilities/utility';
import Slider from 'script/controls/slider';

ui.utilities.history = new Utility({

  setup() {
    this.$rep = $("#archive-ut");
    this.rep = this.$rep[0];
    this.$container = $("#archive-thumbs");
    this.container = this.$container[0];
    this.$controls = $("#archive-controls");
    this.controls = this.$controls[0];

    return this.stepsSlider = new Slider({
      rep: $("#archive-steps-slider")[0],
      commit: val => {},
      valueTipFormatter: val => {
        return `${Math.round(this.maxSteps * val) + 1}`;
      },
      onRelease: val => {
        return this.build(Math.round(this.maxSteps * val) + 1);
      },
      inverse: true
    });
  },

  thumbsCache: {},

  deleteThumbsCached(after) {
    let toDelete = [];
    for (var key of Object.keys(this.thumbsCache || {})) {
      let thumb = this.thumbsCache[key];
      if (parseInt(key, 10) > after) {
        toDelete.push(key);
      }
    }
    for (key of Array.from(toDelete)) {
      delete this.thumbsCache[key];
    }
    return this;
  },

  shouldBeOpen() { return false; },

  open() {
    this.show();

    // Set this to just return true to keep it open
    this.shouldBeOpen = () => true;

    // Build it async so the window pops open and shows
    // the loading progress while it's compiling the thumbnails
    return async(() => {
      return this.build();
    });
  },

  close() {
    this.$container.empty();
    this.shouldBeOpen = () => false;
    return this.hide();
  },

  toggle() {
    if (this.visible) { return this.close(); } else { return this.open(); }
  },


  build(every) {
    this.every = every;
    if (archive.events.length < 3) {
      this.$controls.hide();
      this.every = 1;
      return this.$container.html('<div empty>Make changes to this file to get a visual history of it.</div>');
    }

    this.$controls.show();

    // Calculate max value for steps slider
    this.maxSteps = Math.round(archive.events.length / 4);

    if ((this.every == null)) {
      this.every = Math.round(this.maxSteps / 2);
      this.stepsSlider.write(0.5);
    }

    // Remember where we were
    this.$container.html('<div empty>Processing <br> file history... <br> <span percentage></span></div>');
    return async(() => {
      return this.buildThumbs(this.every);
    });
  },


  buildThumbs(every, startingAt) {

    // If we're redrawing the entire thumbs list
    // clear whatever was in there before be it old thumbs
    // or the empty message
    this.every = every;
    if (startingAt == null) { startingAt = 0; }
    if (startingAt < 2) { this.$container.empty(); }

    let cp = archive.currentPosition();
    let cs = ui.selection.elements.zIndexes();

    ui.canvas.petrify();

    // Put the archive in simulating mode to omit
    // unnecessary UI actions
    archive.simulating = true;

    // Go to where we want to start going up from
    archive.goToEvent(startingAt);

    this.thumbs = [];

    return this._buildRecursive(archive.currentPosition(), this.every, () => {

      // Go back to where we started from
      archive.goToEvent(cp);

      archive.simulating = false;

      ui.canvas.depetrify();

      ui.selection.elements.deselectAll();
      for (let zi of Array.from(cs)) {
        ui.selection.elements.selectMore(queryElemByZIndex(zi));
      }

      if (startingAt === 0) { this.$container.empty(); }

      this.thumbs.map($thumb => {
        return this.$container.prepend($thumb);
      });

      return this.refreshThumbs(archive.currentPosition());
    });
  },


  _buildRecursive(i, every, done) {
    let src;
    this.every = every;
    let percentage = Math.min(Math.round((i / archive.events.length) * 100), 100);
    this.$container.find('[percentage]').text(`${percentage}%`);

    archive.goToEvent(i);

    if (this.thumbsCache[i] != null) {
      src = this.thumbsCache[i];

    } else {
      let contents = io.makeFile();
      src = io.makePNGURI(ui.elements, 150);
      this.thumbsCache[i] = src;
    }

    let img = new Image();
    img.src = src;

    let $thumb = $(`<div class=\"archive-thumb\" position=\"${i}\"></div>`);
    $thumb.prepend(img);
    $thumb.off("click").on("click", function() {
      let $self = $(this);
      i = parseInt($self.attr("position"), 10);
      archive.goToEvent(i);
      return ui.utilities.history.refreshThumbs.call($thumb, i);
  });

    this.thumbs.push($thumb);
    return async(() => {
      if (i < (archive.events.length - 1)) {
        return this._buildRecursive(Math.min(i + this.every, archive.events.length - 1), this.every, done);
      } else {
        return done();
      }
    });
  },


  refreshThumbs(i) {
    // Go to this event's index, and update all the other
    $(".archive-thumb").removeClass("future");
    return $(".archive-thumb").each(function() {
      let $self = $(this);
      if (parseInt($self.attr("position"), 10) > i) {
        return $self.addClass("future");
      }
    });
  }
});




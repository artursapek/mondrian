import setup from 'script/setup';
import ui from 'script/ui/ui';
import Utility from 'script/utilities/utility';

/*


  archive

  Undo/redos

  Manages a stack of Events that describe exactly how the file was put together.
  The Archive is designed to describe the calculations needed to reconstruct the file
  step by step without actually saving the results of any of those calculations.

  It merely retains the bare minimum information to carry that calculation out again.

  For example, if we nudged a certain shape, we won't be saving the old and new point values,
  which could look like a big wall of characters like "M 434.37889,527.30393 C 434.37378,524.01..."
  Instead we just say "move shape 3 over 23 pixels and up 5 pixels."

  Since that procedure is 100% reproducable we can save just that information and always be able
  to do it again.


  This design is much faster and more efficient and allows us to save the entire history for a file on
  S3 and pull it back down regardless of where and when the file is opened again.

  The trade-off is we need to have lots of different Event subclasses that do different things, and
  practically operation in the program needs to be custom-fitted to an Event call.

  Again, doing things this way instead of a simpler one-size-fits-all solution gives us more control
  over what is happening and only store the bare minimum details we need in order to offer a
  full start-to-finish file history.


  Events are serialized in an extremely minimal way. For example, here is a MapEvent that describes a nudge:

  {"t":"m:n","i":[5],"a":{"x":0,"y":-10}}

  What this is saying, in order of appearance is:
    - The type of this event is "map: nudge"
    - We're applying this event to the element at the z-index 5
    - The arguments for the nudge operation are x = 0, y = -10

  That's just an example of how aggressively minimal this system is.


  History is saved as pure JSON on S3 under this scheme:

    development: s3.amazonaws.com/mondy_archives_dev/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json
    prodution:   s3.amazonaws.com/mondy_archives/(USER EMAIL)/( MD5 OF FILE CONTENTS ).json

  "Waboom"


*/


window.archive = {

  // docready setup, just start with a base-case empty fake event

  setup() {
    return this.events = [{ do() {}, undo() {}, position: 0, current: true }];
  },


  // Core UI endpoints into the archive: undo and redo

  undo() {
    return this.goToEvent(this.currentPosition() - 1);
  },

  redo() {
    return this.goToEvent(this.currentPosition() + 1);
  },


  // A couple more goto shortcuts

  goToEnd() {
    return this.goToEvent(this.events.length - 1);
  },

  goToBeginning() {
    return this.goToEvent(0);
  },


  eventsUpToCurrent() {
    // Get the events with anything after the current event sliced off
    return this.events.slice(0, this.currentPosition() + 1);
  },


  currentEvent() {
    // Get the current event
    let ce = this.events.filter(e => e.current);
    if (ce != null) {
      return ce[0];
    } else {
      return null;
    }
  },


  currentPosition() {
    // Get the current event's position
    let ce = this.currentEvent();
    if (ce != null) {
      return ce.position;
    } else {
      return -1;
    }
  },


  // A couple boolean checks

  currentlyAtEnd() {
    return this.currentPosition() === (this.events.length - 1);
  },

  currentlyAtBeginning() {
    return this.currentPosition() === 0;
  },


  // Happens every time a new event is created, meaning every time a user does anything

  addEvent(event) {
    // Cut off the events after the current event
    // and push the new event to the end
    if (this.events.length) { this.events = this.eventsUpToCurrent(); }

    // Clear the thumbnails cached in the visual history utility
    ui.utilities.history.deleteThumbsCached(this.currentPosition());

    // Give it the proper position number
    event.position = this.events.length;

    // The current event is no longer current!
    __guard__(this.currentEvent(), x => x.current = false);

    // We have a new king in town
    event.current = true;
    this.events.push(event);

    // Is the visual history utility open?
    // Automatically update it if it is.
    let uh = ui.utilities.history;
    // If it falls as an event that is included
    // given the history utility's thumb frequency,
    // add it in.
    if ((event.position % uh.every) === 0) {
      return uh.buildThumbs(uh.every, event.position);
    }
  },

  // Each Event subclass gets its own add method

  addMapEvent(fun, elems, data) {
    return this.addEvent(new MapEvent(fun, elems, data));
  },

  addExistenceEvent(elem) {
    return this.addEvent(new ExistenceEvent(elem));
  },

  addPointExistenceEvent(elem, point, at) {
    return this.addEvent(new PointExistenceEvent(elem, point, at));
  },

  addAttrEvent(indexes, attr, value) {
    if (indexes.length === 0) { return; }
    return this.addEvent(new AttrEvent(indexes, attr, value));
  },

  addZIndexEvent(indexesBefore, indexesAfter, direction) {
    if ((indexesBefore.length + indexesAfter) === 0) { return; }
    return this.addEvent(new ZIndexEvent(indexesBefore, indexesAfter, direction));
  },


  goToEvent(ep) {
    // Go to a specific event and execute all the events on the way there.
    //
    // I/P:
    //   ep: event position, an int

    // Old event position, where we just were
    let position;
    let oep = this.currentPosition();

    // Mark the previously current event as not current
    let currentEvent = this.currentEvent();

    if (currentEvent) {
      currentEvent.current = false;
    }

    // Execute all the events between the old event and the new event
    // First determine which direction we're going in: backwards of forwards

    let diff = Math.abs(ep - oep);

    // Upper and lower bounds - don't let ep
    // exceed what we have available in @events

    if (ep > (this.events.length - 1)) {
      // We can't go after the last event
      ep = this.events.length - 1;
      this.events[ep].current = true;
    }

    if (ep < 0) {
      // We can't go before the first event
      ep = 0;
      this.events[0].current = true;

    } else {
      // Otherwise we're good. This should usually be the case
      this.events[ep].current = true;
    }


    if (ep > oep) {
      // Going forward, execute prereqs from old event + 1 to new event
      for (start = oep + 1, position = start, end = ep, asc = start <= end; asc ? position <= end : position >= end; asc ? position++ : position--) {
        var asc, end, start;
        if (this.events[position] != null) {
          this.events[position].do();
        }
      }
    } else if (ep < oep) {
      // Going backward
      for (position = oep, end1 = ep + 1, asc1 = oep <= end1; asc1 ? position <= end1 : position >= end1; asc1 ? position++ : position--) {
        var asc1, end1;
        if (this.events[position] != null) {
          this.events[position].undo();
        }
      }
    }
    // Otherwise we're not moving so don't do anything

    if (!this.simulating) {
      return ui.selection.refresh();
    }
  },

    //@saveDiffState()


  runThrough(speed, i) {
    if (speed == null) { speed = 30; }
    if (i == null) { i = 0; }
    this.goToEvent(i);
    if (i < this.events.length) {
      return setTimeout(() => {
        return this.runThrough(speed, i + 1);
      }
      , speed);
    }
  },


  diffState() {
    let diff = {};
    dom.$main.children().each(function(ind, shape) {
      diff[ind] = {};
      return Array.from(shape.attributes).map((attr) =>
        (diff[ind][attr.name] = attr.value));
    });
    return diff;
  },


  saveDiffState() {
    this.lastDiffState = this.diffState();
    return this.atMostRecentEvent = io.makeFile();
  },


  fileAt(ep) {
    let cp = this.currentPosition();
    this.goToEvent(ep);
    let file = io.makeFile();
    this.goToEvent(cp);
    return file;
  },


  toJSON() {
    if (this.events.length > 1) {
      return {
        f: hex_md5(io.makeFile()),
        e: this.events.slice(1),
        p: this.currentPosition()
      };
    } else {
      return {};
    }
  },


  toString() {
    return JSON.stringify(this.toJSON());
  },


  loadFromString(saved, checkMD5) {
    // Super hackish right now, I'm tired.
    if (checkMD5 == null) { checkMD5 = true; }
    saved = JSON.parse(saved);

    if (Object.keys(saved).length === 0) {
      // Return empty if we just have an empty object
      return this.setup();
    }

    if (checkMD5) {
      if (saved.f !== hex_md5(ui.file.contents)) {
        // Return empty if the file md5 hashes don't line up,
        // meaning this history is invalid for this file
        console.log("File contents md5 mismatch");
        return this.setup();
      }
    }

    let events = saved.e;
    let parsedEvents = events.map(x => new Event().fromJSON(x));
    let i = 1;
    parsedEvents.map(function(x) {
      x.position = i;
      return i += 1;
    });
    // Rebuild the initial empty event
    this.setup();
    // Add in the parsed events
    this.events = this.events.concat(parsedEvents);

    // By default the 0 index event is current. Disable this
    this.events[0].current = false;

    // Set the correct current event
    return __guard__(this.events[parseInt(saved.p, 10)], x => x.current = true);
  },

  put() {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/baddeley/put`,
      type: "POST",
      dataType: "json",
      data: {
        session_token: ui.account.session_token,
        file_hash: hex_md5(ui.file.contents),
        archive: archive.toString()
      },
      success(data) {}
    });
  },

  get() {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/baddeley/get`,
      data: {
        session_token: ui.account.session_token,
        file_hash: hex_md5(ui.file.contents)
      },
      dataType: "json",
      success: data => {
        return this.loadFromString(data.archive);
      }
    });
  }
};



setup.push(function() {
  if ((ui.file == null)) {
    return archive.setup();
  }
});


function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

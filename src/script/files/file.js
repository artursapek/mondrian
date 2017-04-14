/*

  File

  An SVG file representation in Mondy.
  Extends into various subclasses that are designed to
  work with different file Services.

*/


export default class File {
  static initClass() {
  
    this.prototype.readonly = false;
  }
  constructor(key, name, path, thumbnail, contents) {
    // I/P
    //   name:      Display file name
    //   path:      Display path
    //   key:       Key used to retrieve the file from its service.
    //              Different for different kinds of files (different services)
    //   thumbnail: SRC attribute for the thumbnail image representing this file.
    //   contents:  You have the option of passing in the file contents immediately.
    //              For services where the file sits on S3, or another server like Dropbox,
    //              you usually won't want to do this right away. So the file will call
    //              a GET request on its service if it's opened by the user.
    // O/P:
    //   self
    //
    // Note:
    //   200 success callbacks are more succinctly referred to as "ok"

    this.key = key;
    this.name = name;
    this.path = path;
    this.thumbnail = thumbnail;
    this.contents = contents;
    this;
  }


  fromService(service) {
    // Give it a service, and it will give you the constructor
    // for that service's file.
    switch (service) {
      case services.local:
        return key => new LocalFile(key);
      case services.permalink:
        return key => new PermalinkFile(key);
      case services.dropbox:
        return (name, path, modified) => new DropboxFile(name, path, modified);
    }
  }


  use(overwrite) {
    if (overwrite == null) { overwrite = false; }
    ui.file = this;
    ui.menu.refresh();

    // Get out of a permalink URL if we're on one
    if (`${window.location.pathname}${window.location.search}` !== this.expectedURL()) {
      history.replaceState("", "", this.expectedURL());
    }
    ui.menu.items.filename.refresh();

    // Ensure it's loaded if we're gonna be using it
    if (this.contents != null) {
      if (overwrite) {
        // Load the file in
        io.parseAndAppend(this.contents);

        if (this.archive != null) {
          // Load the archive for this file
          archive.loadFromString(this.archive);
          ui.utilities.history.deleteThumbsCached().build();
          delete this.archive;
        } else {
          // If we haven't gotten any saved archive data,
          // set up the archive for a new file.
          console.log("No saved archive found that matches the file, starting with a fresh one.");
          archive.setup();
        }
      }

    } else {
      this.load(() => {
        return this.use();
      });
    }

    return this;
  }


  get(ok, error) {
    // Get this file at its most up-to-date state from its service
    // and run a callback on it.
    // Does not overwrite this File instance's contents.
    this.service.get(this.key, ok, error);
    return this;
  }


  put(ok, error) {
    // Persist this file to its service
    this.service.put(this.key, this.contents, ok, error);
    return this;
  }


  set(contents) {
    // Simply set this File's contents attribute.
    // Defaults to the current drawing.
    if (contents == null) { contents = io.makeFile(); }
    this.contents = contents;
    return this;
  }


  save(ok) {
    // Save the current drawing to this file,
    // and persist it to its service.
    this.set();
    this.put(ok);
    return this;
  }


  hasChanges() {
    return this.contents !== io.makeFile();
  }


  toString() {
    let data = {
      key: this.key,
      name: this.name,
      path: this.path,
      service: this.service.name
    };
    return data.toString();
  }


  expectedURL() {
    switch (this.constructor) {
      case PermalinkFile:
        return `/?p=${this.key}`;
      default:
        return "/";
    }
  }
}
File.initClass();

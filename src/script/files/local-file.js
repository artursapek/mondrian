import services from 'script/services/services';
import File from 'script/files/file';

export default class LocalFile extends File {
  constructor(key) {
    super(key, key, '', undefined, undefined);

    this.key = key;
    this.service = services.local;

    // A LocalFile's key is its name
    this.name = this.key;

    // A LocalFile has no path
    this.path = "";

    this.displayLocation = "local storage";

    // Go ahead and get it right away
    this.load();
  }

  load(ok) {
    // Get the file contents
    if (ok == null) { ok = function() {}; }
    this.get(data => {
      // Set the file contents
      this.contents = data.contents;
      this.archive = data.archive;

      // Use it as the current file!
      if (this === ui.file) { this.use(true); }
      return ok(data);
    });
    return this;
  }
}


window.LocalFile = LocalFile;

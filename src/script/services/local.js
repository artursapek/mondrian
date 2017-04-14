/*

  Storing files in localStorage!
  SVG files are so lightweight that for now we'll just do this as a nice
  2.5mb local storage solution, since only Google has the balls to implement
  the FileSystem API.

*/

services.local = new Service({

  name: "local",

  // This doesn't even make calls to Meowset so it doesn't have a module name
  //
  // Therefore it also has to duplicate the root service methods
  // in its own implementation using localStorage.
  //
  // This service is sort of a bastard child, it only halfway matches
  // the Service class implentation, but we're still going to keep it
  // as such because it lets us cut a few corners as opposed to
  // writing it as a completely unique Object.

  setup() {
    if (localStorage.getItem("local-files") === null) {
      // This should only happen the first time they open Mondy.
      localStorage.setItem("local-files", "[]");
      localStorage.removeItem("file-content");
      localStorage.removeItem("file-metadata");
      // Set up demo files
      return (() => {
        let result = [];
        for (let title in demoFiles) {
          var f;
          let contents = demoFiles[title];
          result.push(f = new LocalFile(`${title}.svg`).set(contents).put());
        }
        return result;
      })();
    }
  },


  activate() {},


  lastKey: undefined,


  getSVGs(ok) {
    // Return all the stored LocalFiles as an array of objects
    if (ok == null) { ok = function() {}; }
    let files = [];

    for (let name of Array.from(this.files())) {
      files.push(new LocalFile(name));
    }

    return ok(files);
  },


  getSaveLocations(path, ok) {
    if (ok == null) { ok = function() {}; }
    return ok({}, this.files().map(f => ({ path: `/${f}` })));
  },


  get(key, ok) {
    // Pull out the file and if it isn't null run the success callback
    let file = localStorage.getItem(`local-${key}`);
    let archiveData = localStorage.getItem(`local-${key}-archive`);

    if (file !== null) {
      return ok({ contents: file, archive: archiveData });
    } else {
      // File not found. Probably a new file being made under this name.
      return;
    }
  },


  put(name, contents, ok) {
    // Just provide this with the contents, no path.
    // Keeping the parameters the same so it works
    // with methods that use the other Services.

    if (name == null) { ({ name } = ui.file); }
    if (contents == null) { contents = io.makeFile(); }
    if (ok == null) { ok = function() {}; }
    name = name.replace(/^\//gi, '');

    // Save the contents under the name
    localStorage.setItem(`local-${name}`, contents);

    // Save the history as well
    localStorage.setItem(`local-${name}-archive`, archive.toString());

    // Keep track of the file
    let files = this.files();
    if (!files.has(name)) {
      files.push(name);
    }
    this.files(files);

    return ok();
  },


  delete(name) {
    // Delete the localStorage item
    localStorage.removeItem(`local-${name}`);
    localStorage.removeItem(`local-${name}-archive`);

    // Stop tracking it
    let files = this.files();
    files = files.remove(name);
    return this.files(files);
  },


  deleteAll() {
    // WARNING
    // This deletes all locally stored files homie.
    // Use with discretion.
    return this.files().map(name => this.delete(name));
  },


  files(updated) {
    // This method does two things in one:
    // If no argument is provided, it returns the currently stored files.
    // Otherwise, it updates the currently stored files with the given array.

    if (updated != null) {
      localStorage.setItem("local-files", JSON.stringify(updated));
      return updated;
    } else {
      return JSON.parse(localStorage.getItem("local-files"));
    }
  },


  nextDefaultName() {
    let files = this.files();
    let untitleds = files.filter(f => f.substring(0, 9) === "untitled-");
    let nums = untitleds.map(name => name.match(/\d+/gi)[0])
      .map(num => parseInt(num, 10));

    if (untitleds.length === 0) {
      if (!files.has("untitled.svg")) {
        return "untitled.svg";
      }
    }

    let x = 1;

    while (true) {
      if (nums.has(x)) {
        x += 1;
      } else {
        return `untitled-${x}.svg`;
      }
    }
  },





  clearAllLocalHistory() {
    // WARNING: this is permanent
    return Array.from(this.files()).map((file) =>
      localStorage.removeItem(`local-${file}-archive`));
  }
});





setup.push(() => services.local.setup());


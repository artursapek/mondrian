/*

  A modular frontend for the file storage service API.
  Communicates with the backend version in Meowset.

  Basically just does AJAX calls.

*/

window.services = {};

class Service {
  static initClass() {
  
    this.prototype.fileSystem = {
      contents: {},
      is_dir: true,
      path: "/"
    };
  }
  constructor(attrs) {
    for (let i of Object.keys(attrs || {})) {
      let x = attrs[i];
      this[i] = x;
    }
    if (this.setup != null) {
      setup.push(() => this.setup());
    }
  }

  open() {
    // Standard function
    return ui.gallery.open(this);
  }

  getSVGs(ok) {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/svgs`,
      type: "GET",
      dataType: "json",
      data: {
        session_token: ui.account.session_token
      },
      success: response => {
        return ok(response.map(f => {
          let fl = new File().fromService(this)(f.key);
          fl.modified = f.last_modified;
          fl.thumbnail = f.thumbnail;
          return fl;
        }));
      }
    });
  }

  getSaveLocations(at, success) {
    let files, folders;
    let path = at.split("/").slice(1);
    let traversed = this.fileSystem.contents;

    // See if we already have this shit cached locally.
    // If we do, then chill.
    // If not, then chall.
    if (path[0] !== "") { // This means the path is just the root: "/"
      for (let dir of Array.from(path)) {
        dir = path[0];
        if (traversed[dir] != null) {
          traversed = traversed[dir].contents;
          if (Object.keys(traversed).length !== 0) {
            path = path.slice(1);
          } else {
            break;
          }
        }
      }
    }
    if (path.length === 0) {
      // Chill
      if (traversed.empty) {
        folders = [];
        files = [];
      } else {
        let all = objectValues(traversed);
        folders = all.filter(x => x.is_dir);
        files = all.filter(x => !x.is_dir);
      }
      return success(folders, files);

    } else {
      // Chall
      return $.ajax({
        url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/metadata`,
        type: "GET",
        dataType: "json",
        data: {
          session_token: ui.account.session_token,
          path: at,
          pluck: "save_locations",
          contentsonly: true
        },
        success(response) {
          folders = response.filter(x => x.is_dir);
          files = response.filter(x => !x.is_dir);

          if ((folders.length + files.length) === 0) {
            traversed.empty = true;
          } else {
            for (let folder of Array.from(folders)) {
              traversed[folder.path.match(/\/[^\/]*$/)[0].substring(1)] = {
                contents: {},
                is_dir: true,
                path: `${folder.path}`
              };
            }
          }

          for (let file of Array.from(files)) {
            traversed[file.path.match(/\/[^\/]*$/)[0].substring(1)] = {
              is_dir: false,
              path: `${file.path}`
            };
          }

          return success(folders, files);
        }
      });
    }
  }



  get(key, success) {
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/get`,
      type: "GET",
      dataType: "json",
      data: {
        session_token: ui.account.session_token,
        path: key
      },
      success(response) {
        return success(response);
      }
    });
  }


  put(key, contents, success) {
    if (success == null) { success = function() {}; }
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/put`,
      type: "POST",
      dataType: "json",
      data: {
        contents,
        session_token: ui.account.session_token,
        fn: key
      },
      success(response) {
        return success(response);
      }
    });
  }

  contents(path, success) {
    if (success == null) { success = function() {}; }
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/metadata`,
      type: "GET",
      dataType: "json",
      data: {
        contentsonly: true,
        session_token: ui.account.session_token,
        path
      },
      success(response) {
        return success(response);
      }
    });
  }

  defaultName(path, success) {
    if (success == null) { success = function() {}; }
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/default-name`,
      type: "GET",
      dataType: "json",
      data: {
        session_token: ui.account.session_token,
        path
      },
      success(response) {
        return success(response.name);
      }
    });
  }

  putHistory(key, contents, success) {
    if (success == null) { success = function() {}; }
    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/${this.module}/put-history`,
      type: "POST",
      dataType: "json",
      data: {
        contents,
        session_token: ui.account.session_token,
        fn: key
      },
      success(response) {
        return success(response);
      }
    });
  }
}
Service.initClass();



import setup from 'script/setup';
import ui from 'script/ui/ui';
import File from 'script/files/file';
import services from 'script/services/services';
/*

  Managing the persistent file state we save in the browser.


  This is like a psuedo-file. It saves and shows you whatever you had open last time
  right away with localStorage. This just makes the experience feel faster and eliminates
  the amount of time people will have to look at a blank screen.

  The only time this doesn't happen is with permalinks. It's unlikely you will already
  have had the same permalink open right before clicking on one (does that make sense?)

  Since local files load instantenly, the only real lag is with files from Dropbox.
  (And Google Drive/SkyDrive in the future)

  Doesn't matter: before anyone gets clicking on their file the true file should
  have loaded even if it's from Dropbox.

*/

ui.browserFile = {
  save(force) {
    if (force == null) { force = false; }
    if (ui.afk.active && (!force)) { return; } // Don't bother if the user is afk

    if ((ui.file == null)) {
      new LocalFile(services.local.nextDefaultName()).use();
    }

    if (ui.file.service === services.permalink) { return; }

    // Save some metadata regarding the file and state of the UI
    localStorage.setItem("file-metadata", ui.file.toString());

    // Save everything the user has done
    localStorage.setItem("file-content", io.makeFile());
    return localStorage.setItem("file-archive", archive.toString());
  },

  load() {

    let fileContent = localStorage.getItem("file-content");

    let fileArchive = localStorage.getItem("file-archive");

    if (fileContent != null) {
      io.parseAndAppend(localStorage.getItem("file-content"));

      // Get the file metadata from localStorage, and build the most recently open file.
      let fileMetadata = JSON.parse(localStorage.getItem("file-metadata")) || {};

      // Default to untitled if there's no file data saved whatsoever
      if ((fileMetadata.name == null)) {
        fileMetadata.name = "untitled.svg";
      }

      // Given the service and key, rebuild the file and use() it.
      let service = fileMetadata.service.toLowerCase();
      File.fromService(services[service])(fileMetadata.key).use();

      if (fileArchive != null) {
        return archive.loadFromString(fileArchive, false);
      }

    } else {
      // If for whatever reason there is no browser file saved
      // just create a new local file to work from
      new LocalFile(services.local.nextDefaultName()).use();
      return ui.file.save();
    }
  }
};


// Set up an interval to save the browser file every second.
setup.push(function() {
  if ((ui.file == null)) { ui.browserFile.load(); }

  return setInterval(() => ui.browserFile.save()
  , 1000);
});


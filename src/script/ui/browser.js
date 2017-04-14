import ui from 'script/ui/ui';
/*

  File location browser/chooser
  Used for Save as

*/

ui.browser = {

  service: undefined,

  saveToPath: '/',

  open(service1) {

    this.service = service1;
    this.saveToPath = '/';

    let $so = dom.$serviceBrowser.find("#service-options");
    $so.empty();

    this.removeDirectoryColumnsAfter(1);

    for (let service of Array.from(ui.account.services)) {
      $so.append(this.serviceButton(service));
    }

    // Open the file browser
    ui.changeTo("browser");

    $('#current-file-saving-name-input').val(ui.file.name.replace(".svg", "")).fitToVal(20);

    $('#service-search-input').attr('placeholder', 'Search for folder');
    $('#cancel-save-file').unbind('click').on('click', () => ui.changeTo("draw"));
    $('#confirm-save-file').unbind('click').on('click', () => this.save());

    let $loadingIndicator = dom.$serviceBrowser.find('.loading');
    $loadingIndicator.hide();

    if (this.service != null) {
      $so.addClass("has-selection");
      $so.find(`.${this.service.name}`).addClass("selected");
      $('.service-logo').attr("class", `service-logo ${this.service.name.toLowerCase()}`);
      $loadingIndicator.text(`Conecting to ${this.service.name}...`).show();
      return this.addDirectoryColumn("/", 1, () => $loadingIndicator.hide());
    }
  },



  save() {
    let fn = `${ $("#current-file-saving-name-input").val() }.svg`;
    ui.changeTo("draw");
    return this.service.put(`${this.saveToPath}${fn}`, io.makeFile(), response => {
      debugger;
      return new File().fromService(this.service)(fn).use();
    });
  },


  addDirectoryColumn(path, index, success) {

    if (success == null) { success = function() {}; }
    this.removeDirectoryColumnsAfter(index);

    return this.service.getSaveLocations(path, (folders, files) => {
      // Build the new directory column and append it to the main directory
      success();
      return $("#browser-directory").append(this.directoryColumn(folders, files, index));
    });
  },

      // Expensive operation:
      //@recursivePreload folders

  recursivePreload(folders) {
    return this.service.getSaveLocations(folders[0].path, () => {
      if (folders.length > 1) {
        return this.recursivePreload(folders.slice(1));
      }
    });
  },

  removeDirectoryColumnsAfter(index) {
    // Remove any columns we may have had open that are
    // past the current index of focus.
    return $(".scrollbar-screen-directory-col").each(function() {
      let $self = $(this);
      if (parseInt($self.attr("index"), 10) >= index) { return $self.remove(); }
    });
  },


  directoryColumn(directories, files, index) {
    // Build the col and make sure it's at the right horizontal location
    let $colContainer = $(`\
<div class=\"scrollbar-screen-directory-col\" index=\"${index}\">
  <div class=\"directory-col\"></div>
</div>\
`).css({
      left: `${201 * index}px`});

    let $col = $colContainer.find('.directory-col');

    // Add the directory buttons first
    if (directories.length > 0) {
      $col.append($("<div folders></div>"));
      for (let dir of Array.from(directories)) {
        $col.find("[folders]").append(this.directoryButton(dir.path, dir.path.match(/\/[^\/]*$/)[0].substring(1), index));
      }
    }

    // Add the file buttons below them
    if (files.length > 0) {
      $col.append($("<div files></div>"));
      for (let file of Array.from(files)) {
        $col.find("[files]").append(this.fileButton(file.path, file.path.match(/\/[^\/]*$/)[0].substring(1), index));
      }
    }

    return $colContainer;
  },


  directoryButton(path, name, index) {
    return $(`<div class=\"directory-button\">${name}</div>`).on("click", function() {
      let $self = $(this);
      // If it's not already selected, then select it
      if (!$self.hasClass("selected")) {
        ui.browser.saveToPath = `${path}/`;
        ui.browser.addDirectoryColumn(`${path}`, index + 1);
        $("#current-file-saving-directory-path").text(`${path}/`);
        $self.parent().parent().find('.directory-button').removeClass('selected');
        return $self.addClass("selected").parent().parent().addClass("has-selection");
      } else {
        $self.removeClass("selected").parent().parent().removeClass("has-selection");
        return ui.browser.removeDirectoryColumnsAfter((index + 1));
      }
    });
  },

  fileButton(path, name, index) {
    return $(`<div class=\"file-button\">${name}</div>`).on("click", () => $('#current-file-saving-name-input').val(name.replace(".svg", "")).trigger("keyup"));
  },

  serviceButton(name) {
    return $(`<div class=\"service-button ${name}\">${name[0].toUpperCase() + name.substring(1)} </div>`).on("click", () => {
      return this.open(services[name]);
    });
  }
};




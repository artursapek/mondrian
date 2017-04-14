import setup from 'script/setup';
/*

  File Gallery

  Plugs into Dropbox to showcase SVG files available for editing lets user open any by clicking it.
  Made to be able to plug into any other service later on given a standard, simple API. :)

*/

ui.gallery = {

  service: undefined,

  open(service) {
    // Start the file open dialog given a specific service (Dropbox, Drive, Skydrive...)

    // Some UI tweaks to set up the gallery
    this.service = service;
    ui.changeTo("gallery");
    $('.service-logo').attr("class", `service-logo ${this.service.name.toLowerCase()}`);
    $(".file-listing").css("opacity", "1.0");
    $('#service-search-input').attr('placeholder', 'Search for files');
    $('#cancel-open-file').one('click', function() {
      ui.clear();
      ui.file.load();
      return ui.changeTo("draw");
    });
    let $loadingIndicator = dom.$serviceGallery.find('.loading');
    let serviceNames = ui.account.services.map(s => services[s].name);
    $loadingIndicator.text(`Connecting to ${serviceNames.join(', ')}...`).show();

    // Ask the service for the SVGs we can open.
    // When we get these, draw them to the gallery.

    dom.$serviceGalleryThumbs.empty();

    return async(() => {

      return (() => {
        let result = [];
        for (service of Array.from(ui.account.services)) {
          result.push(services[service].getSVGs(response => {

            // Hide "Connecting to Dropbox..."
            $loadingIndicator.hide();

            // Clear the search bar and autofocus on it.
            dom.$currentService.find('input:text').val("").focus();

            // Write the status message.
            $('#service-file-gallery-message').text(`${response.length} SVG files found`);

            // Draw the file listings
            if (response.length > 0) { return this.draw(response); }
          }));
        }
        return result;
      })();
    });
  },


  choose($fileListing) {
    // Given a jQuerified .file-listing div,
    // download the contents of that file and start editing it.

    let path = $fileListing.attr("path");
    let name = $fileListing.attr("name");
    let key = $fileListing.attr("key");
    let service = $fileListing.attr("service");

    ui.clear();

    // Call the service for the file contents we want.
    new File().fromService(services[service])(key).use(true);

    ui.changeTo("draw");

    // Some shmancy UI work to bring visual focus to the clicked file,
    // reinforcing the selection was recognized.

    return (() => {
      let result = [];
      for (let file of Array.from($(".file-listing"))) {
        let item;
        let $file = $(file);
        if (($file.attr("name") !== name) || ($file.attr("path") !== path)) {
          item = $file.css("opacity", 0.2).unbind("click");
        }
        result.push(item);
      }
      return result;
    })();
  },


  draw(response) {
    // Clear out the gallery of old thumbnails
    //dom.$serviceGalleryThumbs.empty()
    ui.canvas.setZoom(1.0);

    for (let file of Array.from(response)) {
      let $fileListing = this.fileListing(file);
      dom.$serviceGalleryThumbs.append($fileListing);
      $fileListing.one("click", function() {
        return ui.gallery.choose($(this));
      });
    }

    return this.drawThumbnails(response[0], response.slice(1));
  },


  drawThumbnails(hd, tl) {
    let $thumb = $(`.file-listing[key=\"${hd.key}\"] .file-thumbnail-img`);

    if (hd.thumbnail != null) {
      // If the thumbnail has been generated previously and it's up to date,
      // fetch it and put that up.
      // Meowset takes care of making sure it's up to date and everything. Basically,
      // we get a "thumbnail" attr if we should use one and we don't if we should generate a new one.

      let img = new Image();
      img.onload = () => {
        return this.appendThumbnail(hd.thumbnail, $thumb);
      };
      img.src = hd.thumbnail;

    } else {
      // If the file has no thumbnail in S3, we're gonna actually fetch its source and
      // generate a thumbnail for it here on the client. When we finish that we're gonna send
      // it back to Meowset, who will save it to S3 for next time.

      hd.service.get(`${hd.path}${hd.name}`, response => {
        let { contents } = response;
        let shit = dom.$main.children().length;
        let bounds = io.getBounds(contents);


        let dimen = bounds.fitTo(new Bounds(0, 0, 260, 260));


        let png = io.makePNGURI(contents, 260);


        if (dom.$main.children().length !== shit) {
          debugger;
        }

        this.appendThumbnail(png, $thumb, dimen);

        if (hd.service !== services.local) {
          // Don't bother making thumbnails when we're working out of
          // local storage. It's faster and cheaper to
          // generate the thumbnails on the client every time
          // because we're not getting the source from Meowset anyway.
          return $.ajax({
            url: `${SETTINGS.MEOWSET.ENDPOINT}/files/thumbnails/put`,
            type: "POST",
            data: {
              session_token: ui.account.session_token,
              full_path: `${hd.path}${hd.name}`,
              last_modified: `${hd.modified}`,
              content: png
            }
          });
        }
      });
    }

    // Recursion
    if (tl.length > 0) {
      return this.drawThumbnails(tl[0], tl.slice(1));
    }
  },


  fileListing(file) {
    // Ad-hoc templating
    let $l;
    return $l = $(`\
<div class="file-listing" service="${file.service.name.toLowerCase()}" path="${file.path}" name="${file.name}" key="${file.key}" quarantine>
  <div class="file-thumbnail">
    <div class="file-thumbnail-img"></div>
  </div>
  <div class="file-name">${file.name}</div>
  <div class="file-path">in ${file.displayLocation}</div>
</div>\
`);
  },


  appendThumbnail(png, $thumb, dimen) {
    let img = new Image();
    img.onload = function() {
      $thumb.append(this);
      let $img = $(img);
      return img.style.margin = `${(300 - $img.height()) / 2}px ${(300 - $img.width()) / 2}px`;
    };
    return img.src = png;
  }
};


setup.push(() =>
  $("#service-search-input").on("keyup.gs", function(e) {
    let $self = $(this);
    let val = $self.val().toLowerCase();

    if (val === "") {
      return $(".file-listing").show();
    } else {
      return $(".file-listing").each(function() {
        let $fl = $(this);
        let path = $fl.attr("path");
        let name = $fl.attr("name");
        let key = $fl.attr("key");

        if (name.toLowerCase().indexOf(val) > -1) {
          return $fl.show();
        } else {
          return $fl.hide();
        }
      });
    }
  })
);



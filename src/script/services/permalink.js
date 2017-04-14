/*

  Permalink file service
  Works closely with local file service

*/


services.permalink = new Service({

  name: "permalink",


  open() { return services.local.open(); },


  get(public_key, success) {
    return $.getJSON(`${SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/get`,
      { public_key },
      function(response) {
        success({
          contents: response.content,
          file_name: response.file_name,
          readonly: response.readonly
        });
        return trackEvent("Permalinks", "Open", public_key);
    });
  },


  put(public_key, contents, success, emails) {
    if (public_key == null) { public_key = undefined; }
    if (contents == null) { contents = io.makeFile(); }
    if (success == null) { success = function() {}; }
    if (emails == null) { emails = ""; }
    let thumb = io.makePNGURI(ui.elements, 400);

    let data = {
      file_name: ui.file.name,
      svg: contents,
      thumb,
      emails
    };

    if (public_key != null) {
      data.public_key = public_key;
    }

    if (ui.account.session_token != null) {
      data['session_token'] = ui.account.session_token;
    }

    return $.ajax({
      url: `${SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/put`,
      type: "POST",
      dataType: "json",
      data,
      success(response) {
        if ((public_key == null)) {
          new PermalinkFile(response.public_key).use();
          // If no public_key was given, we created a new permalink.
          // So redirect the browser to that new permanent url.
          switch (public_key) {
            case "":
              trackEvent("Permalinks", "Create", response.public_key);
              break;
            default:
              trackEvent("Permalinks", "Save", response.public_key);
          }
        } else {
          console.log("saved");
        }
        return (typeof success === 'function' ? success() : undefined);
      }
    });
  }
});


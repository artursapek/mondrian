###

  Permalink file service
  Works closely with local file service

###


services.permalink = new Service

  name: "permalink"


  open: -> services.local.open()


  get: (public_key, success) ->
    $.getJSON "#{SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/get",
      { public_key: public_key },
      (response) ->
        success(
          contents: response.content
          file_name: response.file_name
          readonly: response.readonly
        )
        trackEvent "Permalinks", "Open", public_key


  put: (public_key = undefined, contents = io.makeFile(), success = (->), emails = "") ->
    thumb = io.makePNGURI(ui.elements, 400)

    data =
      file_name: ui.file.name
      svg: contents
      thumb: thumb
      emails: emails

    if public_key?
      data.public_key = public_key

    if ui.account.session_token?
      data['session_token'] = ui.account.session_token

    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/files/permalinks/put"
      type: "POST"
      dataType: "json"
      data: data
      success: (response) ->
        if !public_key?
          new PermalinkFile(response.public_key).use()
          # If no public_key was given, we created a new permalink.
          # So redirect the browser to that new permanent url.
          switch public_key
            when ""
              trackEvent "Permalinks", "Create", response.public_key
            else
              trackEvent "Permalinks", "Save", response.public_key
        else
          console.log "saved"
        success?()


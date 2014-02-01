###

  A modular frontend for the file storage service API.
  Communicates with the backend version in Meowset.

  Basically just does AJAX calls.

###

window.services = {}

class Service
  constructor: (attrs) ->
    for own i, x of attrs
      @[i] = x
    if @setup?
      setup.push => @setup()

  fileSystem:
    contents: {}
    is_dir: true
    path: "/"

  open: ->
    # Standard function
    ui.gallery.open @

  getSVGs: (ok) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/svgs"
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
      success: (response) =>
        ok(response.map((f) =>
          fl = new File().fromService(@)(f.key)
          fl.modified = f.last_modified
          fl.thumbnail = f.thumbnail
          fl
        ))

  getSaveLocations: (at, success) ->
    path = at.split("/").slice 1
    traversed = @fileSystem.contents

    # See if we already have this shit cached locally.
    # If we do, then chill.
    # If not, then chall.
    if path[0] != "" # This means the path is just the root: "/"
      for dir in path
        dir = path[0]
        if traversed[dir]?
          traversed = traversed[dir].contents
          if Object.keys(traversed).length != 0
            path = path.slice 1
          else
            break
    if path.length is 0
      # Chill
      if traversed.empty
        folders = []
        files = []
      else
        all = objectValues(traversed)
        folders = all.filter (x) -> x.is_dir
        files = all.filter (x) -> not x.is_dir
      return success(folders, files)

    else
      # Chall
      $.ajax
        url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/metadata",
        type: "GET"
        dataType: "json"
        data:
          session_token: ui.account.session_token
          path: at
          pluck: "save_locations"
          contentsonly: true
        success: (response) ->
          folders = response.filter((x) -> x.is_dir)
          files = response.filter((x) -> not x.is_dir)

          if folders.length + files.length == 0
            traversed.empty = true
          else
            for folder in folders
              traversed[folder.path.match(/\/[^\/]*$/)[0].substring(1)] =
                contents: {}
                is_dir: true
                path: "#{folder.path}"

          for file in files
            traversed[file.path.match(/\/[^\/]*$/)[0].substring(1)] =
              is_dir: false
              path: "#{file.path}"

          success(folders, files)



  get: (key, success) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/get",
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        path: key
      success: (response) ->
        success(response)


  put: (key, contents, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/put"
      type: "POST"
      dataType: "json"
      data:
        contents: contents
        session_token: ui.account.session_token
        fn: key
      success: (response) ->
        success(response)

  contents: (path, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/metadata"
      type: "GET"
      dataType: "json"
      data:
        contentsonly: true
        session_token: ui.account.session_token
        path: path
      success: (response) ->
        success(response)

  defaultName: (path, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/default-name"
      type: "GET"
      dataType: "json"
      data:
        session_token: ui.account.session_token
        path: path
      success: (response) ->
        success(response.name)

  putHistory: (key, contents, success = ->) ->
    $.ajax
      url: "#{SETTINGS.MEOWSET.ENDPOINT}/#{@module}/put-history"
      type: "POST"
      dataType: "json"
      data:
        contents: contents
        session_token: ui.account.session_token
        fn: key
      success: (response) ->
        success(response)



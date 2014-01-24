###

  File

  An SVG file representation in Mondy.
  Extends into various subclasses that are designed to
  work with different file Services.

###


class File
  constructor: (@key, @name, @path, @thumbnail, @contents) ->
    # I/P
    #   name:      Display file name
    #   path:      Display path
    #   key:       Key used to retrieve the file from its service.
    #              Different for different kinds of files (different services)
    #   thumbnail: SRC attribute for the thumbnail image representing this file.
    #   contents:  You have the option of passing in the file contents immediately.
    #              For services where the file sits on S3, or another server like Dropbox,
    #              you usually won't want to do this right away. So the file will call
    #              a GET request on its service if it's opened by the user.
    # O/P:
    #   self
    #
    # Note:
    #   200 success callbacks are more succinctly referred to as "ok"

    @


  fromService: (service) ->
    # Give it a service, and it will give you the constructor
    # for that service's file.
    switch service
      when services.local
        return (key) -> new LocalFile(key)
      when services.permalink
        return (key) -> new PermalinkFile(key)
      when services.dropbox
        return (name, path, modified) -> new DropboxFile(name, path, modified)


  use: (overwrite = no) ->
    ui.file = @
    ui.menu.refresh()

    # Get out of a permalink URL if we're on one
    if "#{window.location.pathname}#{window.location.search}" != @expectedURL()
      history.replaceState "", "", @expectedURL()
    ui.menu.items.filename.refresh()

    # Ensure it's loaded if we're gonna be using it
    if @contents?
      if overwrite
        # Load the file in
        io.parseAndAppend @contents

        if @archive?
          # Load the archive for this file
          archive.loadFromString @archive
          ui.utilities.history.deleteThumbsCached().build()
          delete @archive
        else
          # If we haven't gotten any saved archive data,
          # set up the archive for a new file.
          console.log "No saved archive found that matches the file, starting with a fresh one."
          archive.setup()

    else
      @load =>
        @use()

    @


  get: (ok, error) ->
    # Get this file at its most up-to-date state from its service
    # and run a callback on it.
    # Does not overwrite this File instance's contents.
    @service.get(@key, ok, error)
    @


  put: (ok, error) ->
    # Persist this file to its service
    @service.put(@key, @contents, ok, error)
    @


  set: (@contents = io.makeFile()) ->
    # Simply set this File's contents attribute.
    # Defaults to the current drawing.
    @


  save: (ok) ->
    # Save the current drawing to this file,
    # and persist it to its service.
    @set()
    @put(ok)
    @


  hasChanges: ->
    @contents != io.makeFile()


  toString: ->
    data =
      key: @key
      name: @name
      path: @path
      service: @service.name
    data.toString()


  expectedURL: ->
    switch @constructor
      when PermalinkFile
        "/?p=#{@key}"
      else
        "/"

  readonly: false

window.LocalFile = LocalFile
window.File      = File

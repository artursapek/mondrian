class LocalFile extends File
  constructor: (@key) ->
    @service = services.local

    # A LocalFile's key is its name
    @name = @key

    # A LocalFile has no path
    @path = ""

    @displayLocation = "local storage"

    # Go ahead and get it right away
    @load()

    super @key, @name, @path, @thumbnail, @contents

    @

  load: (ok = ->) ->
    # Get the file contents
    @get (data) =>
      # Set the file contents
      @contents = data.contents
      @archive = data.archive

      # Use it as the current file!
      @use(true) if @ == ui.file
      ok(data)
    @


window.LocalFile = LocalFile

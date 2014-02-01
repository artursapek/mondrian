class DropboxFile extends File
  constructor: (@key) ->
    @service = services.dropbox

    #@key = "#{@path}#{@name}"

    @name = @key.match(/[^\/]+$/)[0]
    @path = @key.substring(0, @key.length - @name.length)

    @displayLocation = @key

    super @key, @name, @path, @thumbnail


  load: (ok = ->) ->
    @get ((data) =>
      @contents = data.contents

      archive.get()

      @use(true) if @ == ui.file
      ok(data)
    ), ((error) =>
      @contents = io.makeFile()
      @use(true) if @ == ui.file
    )
    @

  put: (ok) ->
    archive.put()
    super ok


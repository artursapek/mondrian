class PermalinkFile extends File
  constructor: (@key) ->
    @service = services.permalink
    @path = ""

    @displayLocation = "permalink "

    super @key, @name, @path, @thumbnail

  load: ->
    @get (data) =>
      @contents = data.contents
      @name = data.file_name
      @use() if @ == ui.file
    @

  use: (overwrite) ->
    super overwrite
    history.replaceState "", "", "/?p=#{@key}" if @contents?



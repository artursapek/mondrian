###

  Storing files in localStorage!
  SVG files are so lightweight that for now we'll just do this as a nice
  2.5mb local storage solution, since only Google has the balls to implement
  the FileSystem API.

###

services.local = new Service

  name: "local"

  # This doesn't even make calls to Meowset so it doesn't have a module name
  #
  # Therefore it also has to duplicate the root service methods
  # in its own implementation using localStorage.
  #
  # This service is sort of a bastard child, it only halfway matches
  # the Service class implentation, but we're still going to keep it
  # as such because it lets us cut a few corners as opposed to
  # writing it as a completely unique Object.

  setup: ->
    if localStorage.getItem("local-files") is null
      # This should only happen the first time they open Mondy.
      localStorage.setItem("local-files", "[]")
      localStorage.removeItem("file-content")
      localStorage.removeItem("file-metadata")
      # Set up demo files
      for title, contents of demoFiles
        f = new LocalFile("#{title}.svg").set(contents).put()


  activate: ->


  lastKey: undefined


  getSVGs: (ok = ->) ->
    # Return all the stored LocalFiles as an array of objects
    files = []

    for name in @files()
      files.push(new LocalFile name)

    ok files


  getSaveLocations: (path, ok =->) ->
    ok {}, @files().map (f) -> { path: "/#{f}" }


  get: (key, ok) ->
    # Pull out the file and if it isn't null run the success callback
    file = localStorage.getItem("local-#{key}")
    archiveData = localStorage.getItem("local-#{key}-archive")

    if file != null
      ok { contents: file, archive: archiveData }
    else
      # File not found. Probably a new file being made under this name.
      return


  put: (name = ui.file.name, contents = io.makeFile(), ok = ->) ->
    # Just provide this with the contents, no path.
    # Keeping the parameters the same so it works
    # with methods that use the other Services.

    name = name.replace(/^\//gi, '')

    # Save the contents under the name
    localStorage.setItem("local-#{name}", contents)

    # Save the history as well
    localStorage.setItem("local-#{name}-archive", archive.toString())

    # Keep track of the file
    files = @files()
    if not files.has(name)
      files.push name
    @files(files)

    ok()


  delete: (name) ->
    # Delete the localStorage item
    localStorage.removeItem("local-#{name}")
    localStorage.removeItem("local-#{name}-archive")

    # Stop tracking it
    files = @files()
    files = files.remove name
    @files(files)


  deleteAll: ->
    # WARNING
    # This deletes all locally stored files homie.
    # Use with discretion.
    @files().map (name) => @delete name


  files: (updated) ->
    # This method does two things in one:
    # If no argument is provided, it returns the currently stored files.
    # Otherwise, it updates the currently stored files with the given array.

    if updated?
      localStorage.setItem("local-files", JSON.stringify(updated))
      return updated
    else
      return JSON.parse(localStorage.getItem("local-files"))


  nextDefaultName: ->
    files = @files()
    untitleds = files.filter((f) -> f.substring(0, 9) == "untitled-")
    nums = untitleds.map((name) -> name.match(/\d+/gi)[0])
      .map((num) -> parseInt(num, 10))

    if untitleds.length is 0
      if not files.has "untitled.svg"
        return "untitled.svg"

    x = 1

    while true
      if nums.has x
        x += 1
      else
        return "untitled-#{x}.svg"





  clearAllLocalHistory: ->
    # WARNING: this is permanent
    for file in @files()
      localStorage.removeItem("local-#{file}-archive")





setup.push -> services.local.setup()


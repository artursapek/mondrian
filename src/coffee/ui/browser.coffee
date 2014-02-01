###

  File location browser/chooser
  Used for Save as

###

ui.browser =

  service: undefined

  saveToPath: '/'

  open: (@service) ->

    @saveToPath = '/'

    $so = dom.$serviceBrowser.find("#service-options")
    $so.empty()

    @removeDirectoryColumnsAfter 1

    for service in ui.account.services
      $so.append @serviceButton service

    # Open the file browser
    ui.changeTo "browser"

    $('#current-file-saving-name-input').val(ui.file.name.replace(".svg", "")).fitToVal(20)

    $('#service-search-input').attr('placeholder', 'Search for folder')
    $('#cancel-save-file').unbind('click').on('click', -> ui.changeTo("draw"))
    $('#confirm-save-file').unbind('click').on('click', => @save())

    $loadingIndicator = dom.$serviceBrowser.find('.loading')
    $loadingIndicator.hide()

    if @service?
      $so.addClass("has-selection")
      $so.find(".#{@service.name}").addClass("selected")
      $('.service-logo').attr("class", "service-logo #{@service.name.toLowerCase()}")
      $loadingIndicator.text("Conecting to #{@service.name}...").show()
      @addDirectoryColumn("/", 1, -> $loadingIndicator.hide())



  save: ->
    fn = "#{ $("#current-file-saving-name-input").val() }.svg"
    ui.changeTo("draw")
    @service.put "#{@saveToPath}#{fn}", io.makeFile(), (response) =>
      debugger
      new File().fromService(@service)(fn).use()


  addDirectoryColumn: (path, index, success = ->) ->

    @removeDirectoryColumnsAfter index

    @service.getSaveLocations path, (folders, files) =>
      # Build the new directory column and append it to the main directory
      success()
      $("#browser-directory").append(@directoryColumn folders, files, index)

      # Expensive operation:
      #@recursivePreload folders

  recursivePreload: (folders) ->
    @service.getSaveLocations folders[0].path, =>
      if folders.length > 1
        @recursivePreload(folders.slice 1)

  removeDirectoryColumnsAfter: (index) ->
    # Remove any columns we may have had open that are
    # past the current index of focus.
    $(".scrollbar-screen-directory-col").each ->
      $self = $(@)
      $self.remove() if parseInt($self.attr("index"), 10) >= index


  directoryColumn: (directories, files, index) ->
    # Build the col and make sure it's at the right horizontal location
    $colContainer = $("""
      <div class=\"scrollbar-screen-directory-col\" index=\"#{index}\">
        <div class=\"directory-col\"></div>
      </div>
    """).css
      left: "#{201 * index}px"

    $col = $colContainer.find('.directory-col')

    # Add the directory buttons first
    if directories.length > 0
      $col.append $("<div folders></div>")
      for dir in directories
        $col.find("[folders]").append @directoryButton(dir.path, dir.path.match(/\/[^\/]*$/)[0].substring(1), index)

    # Add the file buttons below them
    if files.length > 0
      $col.append $("<div files></div>")
      for file in files
        $col.find("[files]").append @fileButton(file.path, file.path.match(/\/[^\/]*$/)[0].substring(1), index)

    $colContainer


  directoryButton: (path, name, index) ->
    $("<div class=\"directory-button\">#{name}</div>").on("click", ->
      $self = $ @
      # If it's not already selected, then select it
      if not $self.hasClass "selected"
        ui.browser.saveToPath = "#{path}/"
        ui.browser.addDirectoryColumn("#{path}", index + 1)
        $("#current-file-saving-directory-path").text("#{path}/")
        $self.parent().parent().find('.directory-button').removeClass('selected')
        $self.addClass("selected").parent().parent().addClass("has-selection")
      else
        $self.removeClass("selected").parent().parent().removeClass("has-selection")
        ui.browser.removeDirectoryColumnsAfter (index + 1)
    )

  fileButton: (path, name, index) ->
    $("<div class=\"file-button\">#{name}</div>").on("click", ->
      $('#current-file-saving-name-input').val(name.replace(".svg", "")).trigger("keyup")
    )

  serviceButton: (name) ->
    $("<div class=\"service-button #{name}\">#{name[0].toUpperCase() + name.substring(1)} </div>").on("click", =>
      @open(services[name])
    )




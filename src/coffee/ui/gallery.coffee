###

  File Gallery

  Plugs into Dropbox to showcase SVG files available for editing lets user open any by clicking it.
  Made to be able to plug into any other service later on given a standard, simple API. :)

###

ui.gallery =

  service: undefined

  open: (@service) ->
    # Start the file open dialog given a specific service (Dropbox, Drive, Skydrive...)

    # Some UI tweaks to set up the gallery
    ui.changeTo "gallery"
    $('.service-logo').attr("class", "service-logo #{@service.name.toLowerCase()}")
    $(".file-listing").css("opacity", "1.0")
    $('#service-search-input').attr('placeholder', 'Search for files')
    $('#cancel-open-file').one('click', ->
      ui.clear()
      ui.file.load()
      ui.changeTo("draw")
    )
    $loadingIndicator = dom.$serviceGallery.find('.loading')
    serviceNames = ui.account.services.map (s) -> services[s].name
    $loadingIndicator.text("Connecting to #{serviceNames.join(', ')}...").show()

    # Ask the service for the SVGs we can open.
    # When we get these, draw them to the gallery.

    dom.$serviceGalleryThumbs.empty()

    async =>

      for service in ui.account.services
        services[service].getSVGs (response) =>

          # Hide "Connecting to Dropbox..."
          $loadingIndicator.hide()

          # Clear the search bar and autofocus on it.
          dom.$currentService.find('input:text').val("").focus()

          # Write the status message.
          $('#service-file-gallery-message').text("#{response.length} SVG files found")

          # Draw the file listings
          @draw response if response.length > 0


  choose: ($fileListing) ->
    # Given a jQuerified .file-listing div,
    # download the contents of that file and start editing it.

    path = $fileListing.attr "path"
    name = $fileListing.attr "name"
    key = $fileListing.attr "key"
    service = $fileListing.attr "service"

    ui.clear()

    # Call the service for the file contents we want.
    new File().fromService(services[service])(key).use(yes)

    ui.changeTo("draw")

    # Some shmancy UI work to bring visual focus to the clicked file,
    # reinforcing the selection was recognized.

    for file in $(".file-listing")
      $file = $(file)
      if ($file.attr("name") isnt name) or ($file.attr("path") isnt path)
        $file.css("opacity", 0.2).unbind("click")


  draw: (response) ->
    # Clear out the gallery of old thumbnails
    #dom.$serviceGalleryThumbs.empty()
    ui.canvas.setZoom 1.0

    for file in response
      $fileListing = @fileListing file
      dom.$serviceGalleryThumbs.append $fileListing
      $fileListing.one "click", ->
        ui.gallery.choose $ @

    @drawThumbnails response[0], response.slice 1


  drawThumbnails: (hd, tl) ->
    $thumb = $(".file-listing[key=\"#{hd.key}\"] .file-thumbnail-img")

    if hd.thumbnail?
      # If the thumbnail has been generated previously and it's up to date,
      # fetch it and put that up.
      # Meowset takes care of making sure it's up to date and everything. Basically,
      # we get a "thumbnail" attr if we should use one and we don't if we should generate a new one.

      img = new Image()
      img.onload = =>
        @appendThumbnail(hd.thumbnail, $thumb)
      img.src = hd.thumbnail

    else
      # If the file has no thumbnail in S3, we're gonna actually fetch its source and
      # generate a thumbnail for it here on the client. When we finish that we're gonna send
      # it back to Meowset, who will save it to S3 for next time.

      hd.service.get "#{hd.path}#{hd.name}", (response) =>
        contents = response.contents
        shit = dom.$main.children().length
        bounds = io.getBounds contents


        dimen = bounds.fitTo(new Bounds(0, 0, 260, 260))


        png = io.makePNGURI(contents, 260)


        if dom.$main.children().length != shit
          debugger

        @appendThumbnail(png, $thumb, dimen)

        if hd.service != services.local
          # Don't bother making thumbnails when we're working out of
          # local storage. It's faster and cheaper to
          # generate the thumbnails on the client every time
          # because we're not getting the source from Meowset anyway.
          $.ajax
            url: "#{SETTINGS.MEOWSET.ENDPOINT}/files/thumbnails/put"
            type: "POST"
            data:
              session_token: ui.account.session_token
              full_path: "#{hd.path}#{hd.name}"
              last_modified: "#{hd.modified}"
              content: png

    # Recursion
    if tl.length > 0
      @drawThumbnails(tl[0], tl.slice 1)


  fileListing: (file) ->
    # Ad-hoc templating
    $l = $("""
        <div class="file-listing" service="#{file.service.name.toLowerCase()}" path="#{file.path}" name="#{file.name}" key="#{file.key}" quarantine>
          <div class="file-thumbnail">
            <div class="file-thumbnail-img"></div>
          </div>
          <div class="file-name">#{file.name}</div>
          <div class="file-path">in #{file.displayLocation}</div>
        </div>
      """)


  appendThumbnail: (png, $thumb, dimen) ->
    img = new Image()
    img.onload = ->
      $thumb.append @
      $img = $(img)
      img.style.margin = "#{(300 - $img.height()) / 2}px #{(300 - $img.width()) / 2}px"
    img.src = png


setup.push ->
  $("#service-search-input").on("keyup.gs", (e) ->
    $self = $ @
    val = $self.val().toLowerCase()

    if val is ""
      $(".file-listing").show()
    else
      $(".file-listing").each(->
        $fl = $ @
        path = $fl.attr("path")
        name = $fl.attr("name")
        key = $fl.attr("key")

        if name.toLowerCase().indexOf(val) > -1
          $fl.show()
        else
          $fl.hide()
      )
  )



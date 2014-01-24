
ui.utilities.typography = new Utility
  setup: ->
    @$rep = $("#typography-ut")
    @rep = @$rep[0]

    @$faces = @$rep.find("#font-faces-dropdown")
    @$size = @$rep.find("#font-size-val")

    @sizeControl = new NumberBox
      rep: @$size[0]
      value: 24
      min: 1
      max: 1000
      places: 2
      commit: (val) =>
        @setSize val

    @faceControl = new Dropdown
      options: @faces
      rep:     @$faces[0]
      callback: (val) =>
        @setFace(val)

  faces: new FontFaceOption(fontFace) for fontFace in ['Arial', 'Arial Black', 'Cooper Black', 'Georgia', 'Monaco', 'Verdana', 'Impact', 'Gill Sans']

  setFace: (face) ->
    ui.selection.elements.ofType("text").map (t) ->
      t.setFace face
      t.commit()
    ui.transformer.refresh()


  setSize: (val) ->
    ui.selection.elements.ofType("text").map (t) ->
      t.setSize val
      t.commit()
    ui.transformer.refresh()

  refresh: ->
    sizes = []
    ui.selection.elements.ofType("text").map (t) ->
      fs = t.data['font-size']
      if not sizes.has fs
        sizes.push fs
    if sizes.length is 1
      @sizeControl.write sizes[0]
    @faceControl.close()

  onshow: ->
    @refresh()

  shouldBeOpen: ->
    (ui.selection.elements.ofType("text").length > 0) or (ui.uistate.get('tool') is tools.type) # TEXT EDITING AHH


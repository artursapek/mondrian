###

  TextEditable

  A content-editable <p> that lives in the #typography div
  Used to edit the contents of a Text object, each of which
  are tied to one of these.

###

class TextEditable

  constructor: (@owner) ->


  refresh: ->
    @$rep.text(@owner.content)
    if @owner.data['font-size']?
      @$rep.css 'font-size': float(@owner.data['font-size']) * ui.canvas.zoom + 'px'

    if @owner.data['font-family']?
      @$rep.css 'font-family': @owner.data['font-family']

    tr = @owner.transformations.get('translate')

    if @owner.rep.textContent is ''
      # $.fn.offset returns 0, 0 if the contents are empty
      resetToBlank = true
      @owner.rep.textContent = '[FILLER]'
      @$rep.text '[FILLER]'

    ownerOffset = @owner.$rep.offset()

    left = (ownerOffset.left - ui.canvas.normal.x)
    top  = (ownerOffset.top -  ui.canvas.normal.y)

    @$rep.css
      left: left.px()
      top:  top.px()
      color: @owner.data.fill

    ###
    @rep.style.textShadow = @owner.data.strokeWidth.px()
    @rep.style.webkitTextStrokeWidth = @owner.data.strokeWidth.px()
    ###

    @$rep.css

    @owner.transformations.applyAsCSS(@rep)

    # Hack
    myOffset = @$rep.offset()

    if resetToBlank
      @$rep.text ''
      @owner.rep.textContent = ''

    @$rep.css
      left: (left + ownerOffset.left - myOffset.left).px()
      top: (top + ownerOffset.top - myOffset.top).px()


  show: ->
    # We rebuild the rep every single time we want it
    # because it's inexpensive and it more reliably
    # avoids weird focus/blur issues.
    @$rep = $("""
      <div class="text" contenteditable="true"
         quarantine spellcheck="false">#{@owner.content}</div>
    """)
    @rep = @$rep[0]

    $('#typography').append @$rep

    @$rep.one 'blur', =>
      @commit()
      @owner.displayMode()

    @rep.style.display = "block"

    @refresh()

  hide: ->
    return if not @rep?
    @rep.remove()
    @rep = undefined

  focus: ->
    @$rep.focus()

  commit: ->
    oldOr = @owner.originRotated()
    @owner.setContent @$rep.text().replace(/$\s+/g, '')
    newOr = @owner.originRotated()
    @owner.nudge(oldOr.x - newOr.x, oldOr.y - newOr.y)







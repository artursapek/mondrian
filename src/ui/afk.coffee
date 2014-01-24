###

  Keeping track of when the user is away from keyboard.
  We can do calculations and stuff when this happens, and
  not bother doing certain things like re-saving the browser file state.

###

ui.afk =

  active: false

  activate: ->
    @active = true

    @startTasks()

  activateTimerId: undefined

  reset: ->
    @active = false

    clearTimeout @activateTimerId

    @activateTimerId = setTimeout =>
      @activate()
    , 2000

  tasks: {}

  do: (key, fun) ->
    @tasks[key] = fun

  stop: (key) ->
    delete @tasks[key]

  startTasks: (tasks = objectValues @tasks) ->
    # Recursively go through the tasks one at a time and execute
    # them one at a time as long as we're still in active afk mode
    hd = tasks[0]
    hd?()

    # If we're still on active afk time
    # keep churning through the tasks
    if tasks.length > 1 and @active
      @startTasks(tasks.slice 1)



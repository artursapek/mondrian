/*

  Keeping track of when the user is away from keyboard.
  We can do calculations and stuff when this happens, and
  not bother doing certain things like re-saving the browser file state.

*/

ui.afk = {

  active: false,

  activate() {
    this.active = true;

    return this.startTasks();
  },

  activateTimerId: undefined,

  reset() {
    this.active = false;

    clearTimeout(this.activateTimerId);

    return this.activateTimerId = setTimeout(() => {
      return this.activate();
    }
    , 2000);
  },

  tasks: {},

  do(key, fun) {
    return this.tasks[key] = fun;
  },

  stop(key) {
    return delete this.tasks[key];
  },

  startTasks(tasks) {
    // Recursively go through the tasks one at a time and execute
    // them one at a time as long as we're still in active afk mode
    if (tasks == null) { tasks = objectValues(this.tasks); }
    let hd = tasks[0];
    if (typeof hd === 'function') {
      hd();
    }

    // If we're still on active afk time
    // keep churning through the tasks
    if ((tasks.length > 1) && this.active) {
      return this.startTasks(tasks.slice(1));
    }
  }
};



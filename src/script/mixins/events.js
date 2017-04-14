/*

  Standard event system

*/
export default {

  _handlers: {},

  on(event, handler) {
    if (this._handlers[event] == null) { this._handlers[event] = []; }
    return this._handlers[event].push(handler);
  },

  off(event) {
    return delete this._handlers[event];
  },

  trigger() {
    // I/P: event name, then arbitrary amt of arguments
    // ex: @trigger('change', @title, @message)

    return (this._handlers[arguments[0]] != null ? this._handlers[arguments[0]].forEach(function(handler) {
      let args = Array.prototype.slice.call(arguments, 1);
      return handler.apply(this, args);
    }) : undefined);
  }
};


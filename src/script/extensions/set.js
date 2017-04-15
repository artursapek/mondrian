// Simple yet helpful lil' guy

class Set extends Array {

  constructor(array) {
    super(...arguments);

    for (let elem of Array.from(array)) {
      if (!this.has(elem)) {
        this.push(elem);
      }
    }
  }

  push(elem) {
    if (this.has(elem)) { return; }
    return super.push(elem);
  }
}

window.Set = Set;

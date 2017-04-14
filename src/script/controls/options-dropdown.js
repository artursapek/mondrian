/*

  Options Dropdown

  ----------
  | 5px  V |
  ----------
  | 1px    |
  ----------
  | 2px    |
  ----------
  | 5px    |
  ----------
  | 10px   |
  ----------

*/


// I started this for the stroke width control,
// and then I realized that a number-box would be better anyway.
// So this is sitting here now. Maybe I'll find a use for it.
// Excluding it from the source for now.

class OptionsDropdown {

  constructor(attrs) {
    super(attrs);

    this.$label = this.$rep.find(".label");
    this.$ul = this.$rep.find("ul").first();

    this.draw();
  }




  draw() {
    this.$ul.empty();
    return Array.from(this.options).map((option) =>
      this.$ul.append($(`<li>${option}</li>`)));
  }


  setOptions(options) {
    this.options = options;
    return this.draw();
  }


  read() {
    return this.$label.text();
  }


  write(value) {
    return this.$label.text(value);
  }
}





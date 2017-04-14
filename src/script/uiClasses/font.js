/*

  Management class for fontfaces

*/

class Font {
  constructor(name) {
    this.name = name;
  }

  toListItem() {
    return $(`\
<div class="dropdown-item" style="font-family: '${this.name}'">
  ${this.name}
</div>\
`);
  }
}




class PermalinkFile extends File {
  constructor(key) {
    this.key = key;
    this.service = services.permalink;
    this.path = "";

    this.displayLocation = "permalink ";

    super(this.key, this.name, this.path, this.thumbnail);
  }

  load() {
    this.get(data => {
      this.contents = data.contents;
      this.name = data.file_name;
      if (this === ui.file) { return this.use(); }
    });
    return this;
  }

  use(overwrite) {
    super.use(overwrite);
    if (this.contents != null) { return history.replaceState("", "", `/?p=${this.key}`); }
  }
}



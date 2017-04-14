class DropboxFile extends File {
  constructor(key) {
    this.key = key;
    this.service = services.dropbox;

    //@key = "#{@path}#{@name}"

    this.name = this.key.match(/[^\/]+$/)[0];
    this.path = this.key.substring(0, this.key.length - this.name.length);

    this.displayLocation = this.key;

    super(this.key, this.name, this.path, this.thumbnail);
  }


  load(ok) {
    if (ok == null) { ok = function() {}; }
    this.get((data => {
      this.contents = data.contents;

      archive.get();

      if (this === ui.file) { this.use(true); }
      return ok(data);
    }
    ), (error => {
      this.contents = io.makeFile();
      if (this === ui.file) { return this.use(true); }
    })
    );
    return this;
  }

  put(ok) {
    archive.put();
    return super.put(ok);
  }
}


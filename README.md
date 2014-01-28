# Mondrian

Mondrian is a smart and easy-to-learn vector graphics web app.

Try it at [mondrian.io](http://mondrian.io).

[![mondrian.io](/build/img/screenshot.png)](http://mondrian.io)

## Features

#### Basic

Mondrian offers all the tools needed to create, modify, and export simple SVG files.

  - Basic editing capabilities
    - Strict drawing with the pen tool
    - Loose drawing with the crayon tool
    - Shape manipulation (scaling & rotation)
    - Individual point manipulation with bezier controls
    - Basic typography
    - Zoom, eyedropper
    - Smooth, efficient tools & operations
  - File import (via `FileReader`)
    - SVG
  - File export
    - SVG
    - PNG (via `canvas` API)
  - Clean UI
    - Minimal "flat" aesthetic with little visual distraction
    - A smart UI that shows only utilities that can be used at that moment
  - Layout
    - Basic dot grid with snapping for layout

#### Innovations

Mondrian also supports undo/redo through a *(somewhat rough and unstable)* file history API that

  - stores operations, not states
  - is tiny and JSON-serializable, so it can be persisted to a server and loaded back up in another session
  - can visually reconstruct a file's entire history step-by-step

There are no tests written for this system. It's a big todo.

## Building the app

The app works out of the box. It's a simple static site. To run it locally:

```
git clone git@github.com:artursapek/mondrian.git
cd mondrian
npm install
coffee server.coffee --nodejs
```

Then, open [`localhost:3000`](http://localhost:3000) in your web browser, and there you have it!

You can also access the latest stable build at [mondrian.io](http://mondrian.io).

#### Installing Dependencies

`npm install`

#### Building the JavaScript

Run the build task to compile all of the files into the executable [`build.js`](build/build.js):

`cake build`

It features a dumb progress bar that's based off the last compile time. It's actually pretty accurate.

```
> cake build
Compiling 16455 lines
[██████------------------------] 14 seconds remaining
```

The entire app is written in [Coffeescript](http://coffeescript.org/). You have
to manually compile the app every time you make changes.

The source files are specified in an ordered map in [`build.yml`](build.yml).
They are nested under their directory names. You can specify a different
directory name using the `_dir:` key. `null` means no directory.

For example,

```yml
src: !!omap
  - setup:
    - _dir: null
    - settings
    - setup
  - userInterface:
    - _dir: ui
    - selection
  - geometry:
    - posn
    - line-segment
```

refers to

```
src/settings.coffee
src/setup.coffee
src/ui/selection.coffee
src/geometry/posn.coffee
src/geometry/line-segment.coffee
```

#### Building the CSS

The stylesheets are written in LESS, and compiled into CSS like so:

`cake styles`

## Contributing

There's a lot to do! Read [CONTRIBUTING.md](CONTRIBUTING.md) for a list of what you can work on,
context around the project, and guidelines.

## Supported Browsers

Mondrian officially supports only the latest desktop stable versions of Chrome, Firefox, and Safari.

## License

All of the Mondrian code and documentation is available under the [MIT License](LICENSE).

## Contact

You're welcome to contact me at [me@artur.co](mailto:me@artur.co).

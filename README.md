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

  - Stores operations, not states
  - Is tiny and JSON-serializable, so it can be persisted to a server and loaded back up in another session
  - Can visually reconstruct a file's entire history step-by-step

There are no tests written for this system. It's a big todo.

## Installing

There's nothing to install; it's a static site. You can access the latest stable build 
at [mondrian.io](http://mondrian.io) or run it locally:

```
git clone git@github.com:artursapek/mondrian.git
cd mondrian
coffee server.coffee --nodejs
```

Then, open `localhost:3000` in your web browser.

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

#### Building the CSS

The stylesheets are written in LESS, and compiled into CSS like so:

`cake styles`

#### Todo

If you want to help, there's a lot that can be done. Check the issues for bugs and feature requests,
or you could pick something off of this laundry list:

  - Set up a good unit test suite with Phantomjs or another headless browser
  - Add support for missing SVG elements
    - Quadratic bezier (convert to cubic with two matching control points)
    - Elliptical arc
  - More file format import/export abilities (will probably require converter on backend)
    - PDF
    - AI
  - Refactor the monolithic `ui/ui.coffee` into smaller files
    - UI states
    - Mouse event routing
    - Tool management
  - Clean up hacks and rushed features
  - Pathfinder shape manipulation (union, subtraction, overlap)
  - More tools for manipulating bezier curvers
  - Guide lines, a more solid grid system
  - Responsive layout for smaller screens

However I'm open to Pull Requests dealing with any part of the app. It's a fun project in general.

#### Source

The build files are specified in an ordered map in [`build.yml`](build.yml).
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

## Supported Browsers

Mondrian officially supports only the latest versions of Chrome, Firefox, and Safari.

## License

All of the Mondrian code is available under the MIT License.

## Contact

You're welcome to contact me at [me@artur.co](mailto:me@artur.co).

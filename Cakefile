# Cakefile for Mondrian
# Builds the app and the test files

fs     = require 'fs'
{exec} = require 'child_process'
lessc  = require 'less'
colors = require 'colors'
haml   = require 'haml'

ROOT_BUILD_DIRECTORY = 'build'

SOURCE_HEADER = '''
                ###
                Mondrian vector editor
                http://mondrian.io

                This software is available under the MIT License. Have fun with it.
                Contact: me@artur.co
                ###
                '''

filePaths = (callback, keys) ->
  # Build file paths from build.yml
  # Requires js-yaml node package

  paths = []

  src = require('js-yaml').safeLoad(fs.readFileSync('build.yml', 'utf8')).src;

  if keys?
    src = src.filter (module) ->
      keys.indexOf(Object.keys(module)[0]) > -1

  src.forEach (module) ->
    key = Object.keys(module)[0]
    fns = module[key]

    if typeof(fns[0]) == 'object' and fns[0]._dir != undefined
      dir = fns[0]._dir
      fns = fns.slice 1
    else
      dir = key

    paths = paths.concat ("src/coffee/#{dir or ''}#{if dir then '/' else ''}#{fn}.coffee" for fn in fns)

  callback paths

validateBuildFiles = (paths) ->
  # Ensures all files referenced in build.yml actually exist
  for path in paths
    if not fs.existsSync path
      throw "#{path} does not exist"

log = (status, msg) ->
  switch status
    when "ok"
      console.log "[OK] ".green + msg
    when "error"
      console.log "[ERROR] ".red + msg

compileCSS = (pairs) ->
  pairs.forEach (config) ->
    startTime = new Date()
    fs.readFile config.source, 'utf-8', (e, data) ->
      lessc.render data, (e, css) ->
        if not e
          fs.writeFile config.dest, css
          compileTime = (new Date().valueOf() - startTime.valueOf()) / 1000
          log "ok", "Compiled #{config.source} => #{config.dest} in #{compileTime} seconds"
        else
          console.log lessc.formatError e, { color: true } if e

compileHAML = (pairs) ->
  pairs.forEach (config) ->
    startTime = new Date()
    fs.readFile config.source, 'utf-8', (e, data) ->
      html = haml.render data
      fs.writeFile config.dest, html
      compileTime = (new Date().valueOf() - startTime.valueOf()) / 1000
      log "ok", "Compiled #{config.source} => #{config.dest} in #{compileTime} seconds"


fileLengths = (paths) ->
  lineLengths = paths.map (p) -> p.length
  maxPathLength = Math.max.apply(Math, lineLengths)

  lengths = []

  for path in paths
    file = fs.readFileSync path, 'utf8'
    for i in [0..maxPathLength - path.length + 2]
      path += " "
    lengths.push [path, file.match(/\n/gi)?.length or 0]

  # Sort by longest
  lengths.sort (a, b) ->
    if a[1] < b[1]
      return 1
    else if a[1] > b[1]
      return -1
    else
      return 0

  for len in lengths
    console.log len.join('')


concatSrcFiles = (paths) ->
  contents = ''
  counter = 0
  for path in paths
    contents += fs.readFileSync path, 'utf8'
  contents


compileCoffee = (src, outputFile = "#{ROOT_BUILD_DIRECTORY}/assets/javascript/build.js", callback = ->) ->
  # Write temp file
  tmpFile = outputFile.replace /\.js/, '.coffee'
  fs.writeFile tmpFile, src, 'utf8', (err) ->
    throw err if err
    exec "coffee --compile #{tmpFile}", (err, stdout) ->
      if err
        log "error", "Coffee compilation failed                           "
        throw err
      callback()


task 'build', 'Build project', ->
  compileCSS([
    { source: 'src/less/ui.less',           dest: "#{ROOT_BUILD_DIRECTORY}/assets/style/app.css" }
    { source: 'src/less/embed.less',        dest: "#{ROOT_BUILD_DIRECTORY}/assets/style/embed.css" }
    { source: 'src/less/page.less',         dest: "#{ROOT_BUILD_DIRECTORY}/assets/style/page.css" }
    { source: 'src/less/contributing.less', dest: "#{ROOT_BUILD_DIRECTORY}/assets/style/contributing.css" }
    { source: 'src/less/testing.less',      dest: "#{ROOT_BUILD_DIRECTORY}/assets/style/testing.css" }
  ])

  compileHAML([
    { source: "src/haml/xml.haml",          dest: "#{ROOT_BUILD_DIRECTORY}/xml/index.html" }
    { source: "src/haml/contributing.haml", dest: "#{ROOT_BUILD_DIRECTORY}/contributing/index.html" }
  ])

  barLength = 15

  if fs.existsSync '.compiletime'
    lastCompileTime = fs.readFileSync '.compiletime', 'utf8'
  else
    lastCompileTime = 20000 # Generous default

  lastCompileTime = parseInt lastCompileTime, 10

  filePaths (paths) ->
    # Ensure all files exist
    validateBuildFiles paths
    # Concat files
    completeSrc = "#{SOURCE_HEADER}\n#{concatSrcFiles paths}"

    # Progress bar
    compileStart = new Date()

    compileProgress = 0
    progressInterval = lastCompileTime / barLength

    barInterval = setInterval (->
      return if compileProgress == barLength
      compileProgress += 1
      bar = "["
      for x in [0...compileProgress]
        bar += "█"
      for x in [0...barLength - compileProgress]
        bar += " "
      bar += "] #{Math.round((lastCompileTime - ((compileProgress / barLength) * lastCompileTime)) / 1000)} seconds remaining  \r"
      process.stdout.write bar
    ), progressInterval

    compileCoffee completeSrc, "#{ROOT_BUILD_DIRECTORY}/assets/javascript/build.js", ->
      compileTime = new Date().valueOf() - compileStart.valueOf()
      finishedMessage = "Compiled JavaScript blob #{compileTime / 1000} seconds"
      for x in [0...(barLength - finishedMessage.length) + 30]
        finishedMessage += " "
      log "ok", finishedMessage
      clearInterval barInterval
      exec "echo #{compileTime} > .compiletime"


task 'lengths', 'Print source file lengths', ->
  filePaths (paths) ->
    fileLengths paths


option '-n', '--name [NAME]', 'Test name'
option '-c', '--console', 'Test name'
task 'tests', 'Run unit tests cuz', (options) ->
  name = options.name

  filePaths (paths) ->
    paths.unshift "src/settings.coffee"
    paths.unshift "src/constants.coffee"
    paths.unshift "src/utils.coffee"
    # Include Test class
    paths.push "tests/test.coffee"
    # Include tests
    paths.push "tests/#{name}.coffee"

    validateBuildFiles paths
    completeSrc = concatSrcFiles paths
    compileCoffee completeSrc, "tests/#{name}.test.js", ->
      
      if Object.keys(options).indexOf("console") > -1
        startTime = new Date().valueOf()
        exec "node tests/#{name}.test.js", (err, stdout) ->
          throw err if err
          endTime = new Date().valueOf()
          console.log stdout

          console.log "Tests ran in #{endTime - startTime} ms"
  , ['uiClasses', 'geometry', name] # Include named section from build files


task 'styles', 'Compile CSS', ->
  console.log "Build script changed. Build CSS with 'cake build'."


task 'minify', 'Minify source code', ->
    exec "uglifyjs #{ROOT_BUILD_DIRECTORY}/assets/javascript/build.js > #{ROOT_BUILD_DIRECTORY}/assets/javascript/build.min.js", (err, stdout, stderr) ->
        throw err if err
        console.log "Minified JavaScript in #{ROOT_BUILD_DIRECTORY}/assets/"

task 'dependencies', 'Install node dependencies', ->
  dependencies = [
    'js-yaml'
  ]

  dependencies.forEach (dep) ->
    exec "npm install #{dep} --skip-installed -g"


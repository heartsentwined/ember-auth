fs     = require 'fs'
{exec} = require 'child_process'
util   = require 'util'

appFiles = [
  'auth'
  , 'config'
  , 'routes/auth'
  , 'controllers/sign-in'
  , 'controllers/sign-out'
  , 'rest-adapter'
  , 'module'
  , 'modules/remember-me'
]

appFiles = ("src/#{file}.coffee" for file in appFiles)

# helpers

concatFile = (files, output, callback) ->
  contents = []
  remaining = files.length
  for file, index in files then do (file, index) ->
    fs.readFile file, 'utf8', (err, fileContents) ->
      throw err if err
      contents[index] = fileContents
      write() if --remaining == 0
  write = ->
    fs.writeFile output, contents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      callback?()

unlink = (file, callback) ->
  fs.unlink file, (err) ->
    throw err if err
    callback?()

shell = (cmd, callback) ->
  exec cmd, (err, stdout, stderr) ->
    throw err if err
    util.log stdout + stderr if stdout || stderr
    callback?()

# tasks

task 'build', 'Build single application file from source files', ->
  do concatApp = ->
    concatFile appFiles, 'lib/ember-auth.coffee', -> compile()
  compile = ->
    shell 'coffee --compile lib/ember-auth.coffee', -> cleanUpApp()
  cleanUpApp = ->
    unlink 'lib/ember-auth.coffee', -> minify()
  minify = ->
    shell 'uglifyjs lib/ember-auth.js -o lib/ember-auth.min.js'
    util.log 'Application file built.'

task 'watch', 'Watch source files to invoke build task on change', ->
  util.log 'Watching application directory for changes...'
  for file in appFiles then do (file) ->
    fs.watchFile file, (curr, prev) ->
      if +curr.mtime != +prev.mtime
        util.log "[#{file}] modified. Running build task."
        invoke 'build'

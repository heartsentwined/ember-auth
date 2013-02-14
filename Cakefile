fs     = require 'fs'
{exec} = require 'child_process'
util   = require 'util'

appFiles = [
  'auth',
  'config',
  'routes/auth',
  'controllers/sign-in',
  'controllers/sign-out',
  'rest-adapter'
]

task 'build', 'Build single application file from source files', ->
  appContents = new Array remaining = appFiles.length
  for file, index in appFiles then do (file, index) ->
    fs.readFile "src/#{file}.coffee", 'utf8', (err, fileContents) ->
      throw err if err
      appContents[index] = fileContents
      process() if --remaining is 0
  process = ->
    fs.writeFile 'lib/ember-auth.coffee', appContents.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee --compile lib/ember-auth.coffee', (err, stdout, stderr) ->
        throw err if err
        util.log stdout + stderr if stdout || stderr
        fs.unlink 'lib/ember-auth.coffee', (err) ->
          throw err if err
          exec 'uglifyjs lib/ember-auth.js -o lib/ember-auth.min.js'
          util.log 'Application file built.'

task 'watch', 'Watch source files to invoke build task on change', ->
  util.log 'Watching application directory for changes...'
  for file in appFiles then do (file) ->
    fs.watchFile "src/#{file}.coffee", (curr, prev) ->
      if +curr.mtime != +prev.mtime
        util.log "[src/#{file}.coffee] modified. Running build task."
        invoke 'build'

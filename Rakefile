# bundler tasks
require 'bundler/gem_tasks'

# jasmine rake tasks
begin
  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'
rescue LoadError
  task :jasmine do
    abort 'Jasmine is not available. In order to run jasmine, you must: (sudo) gem install jasmine'
  end
end

# load asset:precompile task with appropriate settings
require 'uglifier'
require File.expand_path(File.join('..', 'application'), __FILE__)
class EmberAuth::Application
  paths['public'] = ['dist']
  config.assets.prefix = ''
  config.assets.debug = false
  config.assets.js_compressor = :uglifier
  config.assets.precompile = ['ember-auth.js']
end
EmberAuth::Application.initialize!
EmberAuth::Application.load_tasks

desc 'Build distribution js files'
task :dist do
  puts 'Removing existing dist files...'
  Dir['dist/*'].each { |f| File.delete f }

  puts 'Compiling js distribution...'
  Rake::Task['assets:precompile'].invoke

  puts 'Minifying js distribution...'
  File.write File.join('dist', 'ember-auth.min.js'),
    Uglifier.compile(File.read(File.join('dist', 'ember-auth.js')))

  puts 'Cleaning up...'
  File.delete File.join('dist', 'ember-auth.js.gz')
  File.delete File.join('dist', 'manifest.yml')

  puts 'Successfully built ember-auth at dist/'
end

task :default => [:dist]

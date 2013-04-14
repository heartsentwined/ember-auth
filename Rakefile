# bundler tasks
require 'bundler/gem_tasks'

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

# appraisal
require 'appraisal'

desc 'Run tests'
task :test, :timeout do |t, args|
  timeout = args.timeout ? "--server-timeout=#{args.timeout}" : ''
  exit system "guard-jasmine #{timeout}"
end

task :default => [:dist]

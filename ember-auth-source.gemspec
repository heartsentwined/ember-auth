# -*- encoding: utf-8 -*-
require 'json'

package = JSON.parse(File.read('package.json'))

Gem::Specification.new do |gem|
  gem.name        =  'ember-auth-source'
  gem.version     =  package['version']
  gem.authors     =  ['heartsentwined']
  gem.email       =  ['heartsentwined@cogito-lab.com']
  gem.date        =  Time.now.strftime('%Y-%m-%d')
  gem.summary     =  'Ember-auth source code wrapper'
  gem.description =  'Ember-auth source code wrapper for ruby libs.'
  gem.homepage    =  'https://github.com/heartsentwined/ember-auth'

  gem.files       =  Dir['dist/*.js']
  gem.files       << 'lib/ember-auth/source.rb'

  gem.add_dependency 'ember-rails', ['~> 0.10']

  gem.license     =  'GPL-3'
end

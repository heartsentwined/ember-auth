# -*- encoding: utf-8 -*-
require 'json'

package = JSON.parse(File.read('package.json'))

Gem::Specification.new do |gem|
  gem.name        = 'ember-auth-source'
  gem.version     = package['version']
  gem.authors     = ['heartsentwined']
  gem.email       = ['heartsentwined.me@gmail.com']
  gem.date        = Time.now.strftime('%Y-%m-%d')
  gem.summary     = 'Ember-auth source code wrapper'
  gem.description = 'Ember-auth source code wrapper for ruby libs.'
  gem.homepage    = 'https://github.com/heartsentwined/ember-auth'

  gem.files       = ['dist/ember-auth.js', 'lib/ember-auth/source.rb']

  gem.add_dependency 'ember-source', '>= 1.0.0.rc6.2'

  gem.license     = 'MIT'
end

# -*- encoding: utf-8 -*-
require 'json'

package = JSON.parse(File.read('package.json'))

Gem::Specification.new do |gem|
  gem.name        = 'ember-auth-source'
  gem.version     = package['version']
  gem.authors     = ['heartsentwined']
  gem.email       = ['heartsentwined@cogito-lab.com']
  gem.date        = Time.now.strftime('%Y-%m-%d')
  gem.summary     = 'Ember-auth source code wrapper'
  gem.description = 'Ember-auth source code wrapper for ruby libs.'
  gem.homepage    = 'https://github.com/heartsentwined/ember-auth'

  gem.files       = ['dist/ember-auth.js', 'lib/ember-auth/source.rb']

  gem.add_dependency 'ember-source', [
    '>= 0.0.2',
    '!= 1.0.0.pre4.1', '!= 1.0.0.rc1.0.0', '!= 1.0.0.rc1.1', '!= 1.0.0.rc1.2'
  ]

  gem.license     = 'GPL-3'
end

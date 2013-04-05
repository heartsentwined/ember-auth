require 'action_controller/railtie'
require 'jasminerice'
require 'guard/jasmine'
require 'sprockets/railtie'
require 'jquery-rails'
require 'ember-rails'
require 'json'

module EmberAuth
  class Application < Rails::Application
    routes.append do
      mount Jasminerice::Engine => '/jasmine'
    end

    package = JSON.parse(File.read('package.json'))

    config.cache_classes = true
    config.active_support.deprecation = :log
    config.assets.enabled = true
    config.assets.debug = true
    config.assets.paths << 'vendor'
    config.assets.paths << 'lib'
    config.assets.version = package['version']
    config.secret_token = '5b534c1cd19ae00aa366cc8062ff93b8ecf65d08a639bb796d0ea20b2ae4daf1a926d352be68382c94dfa80b9566230e1e2186b2224e5f18d637cf9a2d1b10ed'

    config.ember.variant = :development
  end
end

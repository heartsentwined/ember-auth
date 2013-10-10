Em.onLoad 'Ember.Application', (application) ->
  application.initializer
    name: 'ember-auth'

    initialize: (container, app) ->
      app.register 'auth:main', (app.Auth || Em.Auth), { singleton: true }

      app.inject 'route',      'auth', 'auth:main'
      app.inject 'controller', 'auth', 'auth:main'
      app.inject 'view',       'auth', 'auth:main'

  application.initializer
    name: 'ember-auth-load'
    after: 'ember-auth'

    initialize: (container, app) ->
      container.lookup 'auth:main' # eager-load to force init call

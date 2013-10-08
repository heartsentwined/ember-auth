Em.onLoad 'Ember.Application', (application) ->
  application.initializer
    name: 'ember-auth'

    initialize: (container, app) ->
      app.register 'auth:main', app.Auth || Em.Auth

      app.register 'authRequest:jquery', Em.Auth.JqueryAuthRequest
      app.register 'authRequest:dummy',  Em.Auth.DummyAuthRequest

      app.register 'authResponse:json',  Em.Auth.JsonAuthResponse
      app.register 'authResponse:dummy', Em.Auth.DummyAuthResponse

      app.register 'authStrategy:token', Em.Auth.TokenAuthStrategy
      app.register 'authStrategy:dummy', Em.Auth.DummyAuthStrategy

      app.register 'authSession:cookie',       Em.Auth.CookieAuthSession
      app.register 'authSession:localStorage', Em.Auth.LocalStorageAuthSession
      app.register 'authSession:dummy',        Em.Auth.DummyAuthSession

      app.register 'authModule:actionRedirectable', Em.Auth.ActionRedirectableAuthModule
      app.register 'authModule:authRedirectable',   Em.Auth.AuthRedirectableAuthModule
      app.register 'authModule:rememberable',       Em.Auth.RememberableAuthModule
      app.register 'authModule:urlAuthenticatable', Em.Auth.UrlAuthenticatableAuthModule
      app.register 'authModule:timeoutable',        Em.Auth.TimeoutableAuthModule

      app.register 'authModule:emberData',  Em.Auth.EmberDataAuthModule
      app.register 'authModule:epf',        Em.Auth.EpfAuthModule
      app.register 'authModule:emberModel', Em.Auth.EmberModelAuthModule

      app.inject 'route',      'auth', 'auth:main'
      app.inject 'controller', 'auth', 'auth:main'
      app.inject 'view',       'auth', 'auth:main'

exports = exports ? this

extend = (opts) ->
  container = if opts.container? then opts.container else new Em.Container()

  container.register 'authRequest:jquery', Em.Auth.JqueryAuthRequest
  container.register 'authRequest:dummy',  Em.Auth.DummyAuthRequest

  container.register 'authResponse:json',  Em.Auth.JsonAuthResponse
  container.register 'authResponse:dummy', Em.Auth.DummyAuthResponse

  container.register 'authStrategy:token', Em.Auth.TokenAuthStrategy
  container.register 'authStrategy:dummy', Em.Auth.DummyAuthStrategy

  container.register 'authSession:cookie',       Em.Auth.CookieAuthSession
  container.register 'authSession:localStorage', Em.Auth.LocalStorageAuthSession
  container.register 'authSession:dummy',        Em.Auth.DummyAuthSession

  container.register 'authModule:actionRedirectable', Em.Auth.ActionRedirectableAuthModule
  container.register 'authModule:authRedirectable',   Em.Auth.AuthRedirectableAuthModule
  container.register 'authModule:rememberable',       Em.Auth.RememberableAuthModule
  container.register 'authModule:urlAuthenticatable', Em.Auth.UrlAuthenticatableAuthModule
  container.register 'authModule:timeoutable',        Em.Auth.TimeoutableAuthModule

  container.register 'authModule:emberData',  Em.Auth.EmberDataAuthModule
  container.register 'authModule:epf',        Em.Auth.EpfAuthModule
  container.register 'authModule:emberModel', Em.Auth.EmberModelAuthModule

  def =
    request:  'dummy'
    response: 'dummy'
    strategy: 'dummy'
    session:  'dummy'
    modules:  []
    container: container
  Em.Auth.extend jQuery.extend true, def, opts

create = (opts) ->
  extend(opts).create()

exports.authTest = { create: create, extend: extend }

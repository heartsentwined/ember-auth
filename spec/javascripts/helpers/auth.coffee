exports = exports ? this

container = null

extend = (opts = {}) ->
  def =
    request:  'dummy'
    response: 'dummy'
    strategy: 'dummy'
    session:  'dummy'
    modules:  []
  auth = Em.Auth.extend jQuery.extend true, def, opts

  container = if opts.container? then opts.container else new Em.Container()

  container.register 'auth:main', auth

  container.register 'authRequest:dummy',  Em.Auth.DummyAuthRequest
  container.register 'authResponse:dummy', Em.Auth.DummyAuthResponse
  container.register 'authStrategy:dummy', Em.Auth.DummyAuthStrategy
  container.register 'authSession:dummy',  Em.Auth.DummyAuthSession

  container.injection 'authRequest:dummy',  'auth', 'auth:main'
  container.injection 'authResponse:dummy', 'auth', 'auth:main'
  container.injection 'authStrategy:dummy', 'auth', 'auth:main'
  container.injection 'authSession:dummy',  'auth', 'auth:main'

  auth.reopen { container: container }

create = (opts) ->
  extend opts
  container.lookup 'auth:main'

exports.authTest = { create: create, extend: extend }

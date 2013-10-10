exports = exports ? this

extend = (opts = {}) ->
  container = if opts.container? then opts.container else new Em.Container()

  container.register 'authRequest:dummy',  Em.Auth.DummyAuthRequest
  container.register 'authResponse:dummy', Em.Auth.DummyAuthResponse
  container.register 'authStrategy:dummy', Em.Auth.DummyAuthStrategy
  container.register 'authSession:dummy',  Em.Auth.DummyAuthSession

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

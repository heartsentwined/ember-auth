class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @_request?  || (@_request  = Em.Auth.Request.create  { auth: this })
    @_response? || (@_response = Em.Auth.Response.create { auth: this })
    @_strategy? || (@_strategy = Em.Auth.Strategy.create { auth: this })
    @_session?  || (@_session  = Em.Auth.Session.create  { auth: this })
    @_module?   || (@_module   = Em.Auth.Module.create   { auth: this })

  # =====================
  # Config
  # =====================

  requestAdapter:  'jquery'
  responseAdapter: 'json'
  strategyAdapter: 'token'
  sessionAdapter:  'cookie'

  # module
  modules: ['emberData']

  # request
  signInEndPoint: null
  signOutEndPoint: null
  baseUrl: null

  # session
  userModel: null

  # strategy.token
  tokenKey: null
  tokenIdKey: null
  tokenLocation: 'param'
  tokenHeaderKey: null

  # module.rememberable
  rememberableTokenKey: null
  rememberablePeriod: 14
  rememberableAutoRecall: true

  # module.urlAuthenticatable
  urlAuthenticatableParamsKey: null

  # module.authRedirectable
  authRedirectableRoute: 'index'

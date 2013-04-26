class Em.Auth extends Em.Object with Em.Evented
  _request:  null
  _strategy: null
  _session:  null
  _module:   null

  init: ->
    @_request  ||= Em.Auth.Request.create  { auth: this }
    @_strategy ||= Em.Auth.Strategy.create { auth: this }
    @_session  ||= Em.Auth.Session.create  { auth: this }
    @_module   ||= Em.Auth.Module.create   { auth: this }

  # =====================
  # Config
  # =====================

  requestAdapter:  'jquery'
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

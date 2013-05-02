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
  signInEndPoint: null  # req
  signOutEndPoint: null # req
  baseUrl: null

  # session
  userModel: null

  # strategy.token
  tokenKey: null # req
  tokenIdKey: null #req
  tokenLocation: 'param'
  tokenHeaderKey: null

  # module.rememberable
  rememberable:
    tokenKey: null # req
    period: 14
    autoRecall: true

  # module.urlAuthenticatable
  urlAuthenticatable:
    paramsKey: null # req

  # module.authRedirectable
  authRedirectable:
    route: 'index'

  # module.actionRedirectable
  actionRedirectable:
    signInRoute: false # or string for route name
    signOutRoute: false # ditto
    signInSmart: false
    signOutSmart: false
    signInBlacklist: [] # list of routes that should redir to fallback
    signOutBlacklist: [] # ditto

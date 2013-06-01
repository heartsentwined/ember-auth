class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @_request?  || (@_request  = Em.Auth.Request.create  { auth: this })
    @_response? || (@_response = Em.Auth.Response.create { auth: this })
    @_strategy? || (@_strategy = Em.Auth.Strategy.create { auth: this })
    @_session?  || (@_session  = Em.Auth.Session.create  { auth: this })
    @_module?   || (@_module   = Em.Auth.Module.create   { auth: this })

  trigger: ->
    @syncEvent.apply this, arguments
    super.apply this, arguments

  syncEvent: ->
    @_request.syncEvent.apply @_request, arguments
    @_response.syncEvent.apply @_response, arguments
    @_strategy.syncEvent.apply @_strategy, arguments
    @_session.syncEvent.apply @_session, arguments
    @_module.syncEvent.apply @_module, arguments

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
    
  # module.browsersessionable
  browsersessionable:
    tokenkey: null # req
    autoRecall: true

  # module.urlAuthenticatable
  urlAuthenticatable:
    paramsKey: null # req

  # module.authRedirectable
  authRedirectable:
    route: null

  # module.actionRedirectable
  actionRedirectable:
    signInRoute: false # or string for route name
    signOutRoute: false # ditto
    signInSmart: false
    signOutSmart: false
    signInBlacklist: [] # list of routes that should redir to fallback
    signOutBlacklist: [] # ditto

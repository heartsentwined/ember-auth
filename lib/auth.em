class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @request  = Em.Auth.Request.create  { auth: this }
    @strategy = Em.Auth.Strategy.create { auth: this }
    @session  = Em.Auth.Session.create  { auth: this }
    Em.Auth.Module.create { auth: this }

  # =====================
  # Config
  # =====================

  requestAdapter:  'jquery'
  strategyAdapter: 'token'
  sessionAdapter:  'cookie'

  # module
  modules: ['ember-data']

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

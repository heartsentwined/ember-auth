class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @session  = Em.Auth.Session.create  { auth: this }
    @request  = Em.Auth.Request.create  { auth: this }
    @strategy = Em.Auth.Strategy.create { auth: this }
    @storage  = Em.Auth.Storage.create  { auth: this }
    Em.Auth.Module.create { auth: this }

  # =====================
  # Config
  # =====================

  requestAdapter:  'jquery'
  strategyAdapter: 'token'
  storageAdapter:  'cookie'

  modules: ['ember-data']

  # =====================
  # Public API
  # =====================

  # Holds auth token
  authToken: ~> @session.authToken

  # Holds current user ID
  currentUserId: ~> @session.currentUserId

  # Holds current user model
  currentUser: ~> @session.currentUser

  # =====================
  # End of Public API
  # =====================

  # Holds prev route for smart redirect.
  prevRoute: null

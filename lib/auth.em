class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @request  = Em.Auth.Request.create { auth: this }
    @strategy = Em.Auth.Strategy.create { auth: this }
    @storage  = Em.Auth.Storage.create { auth: this }
    @session  = Em.Auth.Session.create { auth: this }

  # =====================
  # Config
  # =====================

  requestAdapter:  'jquery'
  strategyAdapter: 'token'
  storageAdapter:  'cookie'

  # =====================
  # Public API
  # =====================

  # Holds auth token
  authToken: ~> @session.authToken
  #authToken: null

  # Holds current user ID
  currentUserId: ~> @session.currentUserId
  #currentUserId: null

  # Holds current user model
  currentUser: @session.currentUser
  #currentUser: null

  # =====================
  # End of Public API
  # =====================

  # Holds prev route for smart redirect.
  prevRoute: null

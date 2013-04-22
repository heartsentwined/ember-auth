class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @registry = Em.Auth.Registry.create()

  # =====================
  # Public API
  # =====================

  # shortcuts to access public API registry items
  authToken:     ~> @registry.authToken
  currentUserId: ~> @registry.currentUserId
  currentUser:   ~> @registry.currentUser
  jqxhr:         ~> @registry.jqxhr
  json:          ~> @registry.json

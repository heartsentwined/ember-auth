class Em.Auth extends Em.Object with Em.Evented

  # =====================
  # Public API
  # =====================

  # Holds auth token
  authToken: null

  # Holds current user ID
  currentUserId: null

  # Holds current user model
  currentUser: null

  # Holds jqxhr object from token API resonses
  jqxhr: null

  # Holds JSON object on successful API responses
  json: null

  # =====================
  # End of Public API
  # =====================

  # Holds prev route for smart redirect.
  prevRoute: null

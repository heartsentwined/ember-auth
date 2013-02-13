Auth.Config = Em.Object.create
  # =====================
  # Token API config
  # =====================

  # REQUIRED
  # You must implement this hook:
  # It should return the URL of API end point for token creation (sign in).
  # e.g. '/api/sign_in'
  #   will POST /api/sign_in with sign in credentials to get auth token
  tokenCreateUrl: null

  # REQUIRED
  # You must implement this hook:
  # It should return the URL of API end point for token destruction (sign out).
  # e.g. '/api/sign_out'
  #   will DELETE /api/token with sign out credentials to destroy auth token
  tokenDestroyUrl: null

  # REQUIRED
  # You must implement this hook:
  # It should return the name of the key of auth token in your API's response.
  # e.g.
  #   if POST /api/token returns {auth_token: 'fjlja8hfhf4'},
  #   set this to 'auth_token'
  tokenKey: null

  # REQUIRED
  # You must implement this hook:
  # It should return the name of the key of user ID in your API's response.
  # e.g.
  #   if POST /api/token returns {user_id: 3},
  #   set this to 'user_id'
  idKey: null

  # =====================
  # Redirection config
  # =====================

  # You must implement this hook if you use smart redirect.
  # It should return the name of your sign in route.
  signInRoute: null

  # Whether we should use 'smart' redirects after signing in.
  # If this hook returns true, will remember and redirect to prev route;
  # if prev route not available (e.g. entry route is the sign in route),
  # then will use fallback sign in redirect route.
  # @see signInRedirectRoute
  smartSignInRedirect: true

  # Whether we should use 'smart' redirects after signing out.
  # If this hook returns true, will remember and redirect to prev route;
  # if prev route not available (e.g. entry route is the sign out route),
  # then will use fallback sign out redirect route.
  # @see signOutRedirectRoute
  smartSignOutRedirect: true

  # Implement this hook to specify a fallback sign in redirect route
  # It should return the name of a route.
  signInRedirectRoute:  'index'

  # Implement this hook to specify a fallback sign out redirect route
  # It should return the name of a route.
  signOutRedirectRoute: 'index'

  # Implement this hook and return true to disable redirect.
  disableRedirect: false

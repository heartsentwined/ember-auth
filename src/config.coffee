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
  #   if POST /api/token returns {auth_token: "fjlja8hfhf4"},
  #   set this to 'auth_token'
  tokenKey: null

  # REQUIRED
  # You must implement this hook:
  # It should return the name of the key of user ID in your API's response.
  # e.g.
  #   if POST /api/token returns {user_id: 3},
  #   set this to 'user_id'
  idKey: null

  # Implement this hook and return your user model
  # if you want to auto-load the current user object in Auth.currentUser.
  # ember-auth will call find() with Auth.currentUserId to auto-load.
  # e.g.
  #   if your user model is App.User,
  #   set this to App.User.
  #   (**not** a string 'App.User')
  userModel: null

  # Implement this hook if base url for authentication API end points is
  # different from ember application host.
  # e.g.
  #   your API lives at http://api.example.com/,
  #   but your ember application lives at http://example.com/,
  #   then set this to 'http://api.example.com'
  baseUrl: null
  
  # If this hook returns true, the auth token will be passed in the request 
  # header instead the data hash.
  requestHeaderAuthorization: false
  
  # You must implement this hook if requestHeaderAuthorization returns true:
  # It should return the name of the header to use for sending the auth token.
  # e.g. 
  #   if you set this to 'X-API-TOKEN' a header will automatically be sent with 
  #   each request: headers { "X-API-TOKEN": Auth.get('authToken') }
  requestHeaderKey: null

  # =====================
  # Redirection config
  # =====================

  # This hooks is used in some redirect mode calculations:
  #   * auth-only route redirect
  #   * smart post-sign in redirect
  # It should return the name of your sign in route.
  signInRoute: null

  # This hooks is used in some redirect mode calculations:
  #   * smart post-sign out redirect
  # It should return the name of your sign out route.
  signOutRoute: null

  # If this hook returns true, visiting an Auth.Route before authentification
  # will redirect to the @signInRoute
  authRedirect: false

  # Whether we should use 'smart' redirects after signing in.
  # If this hook returns true, will remember and redirect to prev route;
  # if prev route not available (e.g. entry route is the sign in route),
  # then will use fallback sign in redirect route.
  # If this hook returns false, it will always use the fallback route.
  # @see signInRedirectRoute
  smartSignInRedirect: false

  # Whether we should use 'smart' redirects after signing out.
  # If this hook returns true, will remember and redirect to prev route;
  # if prev route not available (e.g. entry route is the sign out route),
  # then will use fallback sign out redirect route.
  # If this hook returns false, it will always use the fallback route.
  # @see signOutRedirectRoute
  smartSignOutRedirect: false

  # Implement this hook to specify a fallback sign in redirect route
  # It should return the name of a route.
  signInRedirectFallbackRoute: 'index'

  # Implement this hook to specify a fallback sign out redirect route
  # It should return the name of a route.
  signOutRedirectFallbackRoute: 'index'

  # =====================
  # Remember me
  # =====================

  # Implement this hook and return true to enable remember me feature.
  rememberMe: false

  # REQUIRED if you want to use remember me
  # Your token creation API end point should accept polymorphic parameters:
  #   either the regular set of sign in credentials,
  #   or a remember me token.
  # This hook should return the name of the key of remember token in your API,
  # both in response and in accepted params.
  # e.g.
  #   if POST /api/token accepts {remember_token: "fjlja8hfhf4"}
  #                  and returns {remember_token: "fjlja8hfhf4"},
  #   set this to 'remember_token'
  rememberTokenKey: null

  # Implement this hook to customize the remember cookie valid period.
  # It should return the number of days to remember a user for.
  # Defaults to two weeks.
  rememberPeriod: 14

  # Implement this hook and return false if you want to disable auto-recall.
  # By default, autoRecall is enabled, and Remember Me will try to sign in the
  # user from local cookie whenever one accesses an Auth.Route (only if one
  # is not already signed in).
  rememberAutoRecall: true

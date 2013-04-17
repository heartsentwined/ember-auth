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

  # Where to include the authentication token on API requests
  # Valid values are 'param', 'authHeader' and 'customHeader'
  # - 'param': include in data/param hash, e.g. POST body
  # - 'authHeader': send an Authorization Header (RFC 1945)
  # - 'customHeader': send a custom Header, e.g. X-prefixed header
  # Defaults to 'param'.
  requestTokenLocation: 'param'

  # You must implement this hook if you use any of the *Header settings in
  # requestTokenLocation.
  # Polymorphic effects:
  # - requestTokenLocation = 'authHeader': treated as Authorization Method.
  #   e.g. if this is set to 'TOKEN', the following header will be sent:
  #   "Authorization: TOKEN auth_token_value"
  # - requestTokenLocation = 'customHeader': treated as Header Key.
  #   e.g. if this is set to 'X-API-TOKEN', the following header will be sent:
  #   "X-API-TOKEN: auth_token_value"
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

  # Implement this hook and return 'both' if you want auto-recall behavior to
  # apply to regular Em.Route as well.
  # Defaults to 'auth' - auto recall only happens in Auth.Routes.
  # Valid values are 'auth' and 'both'
  rememberAutoRecallRouteScope: 'auth'

  # Which storage medium to use for storing the remember me session.
  # Valid values are 'cookie' and 'localStorage'
  # Defaults to 'cookie'
  # - Note: localStorage does not support an expiry date.
  rememberStorage: 'cookie'

  # =====================
  # URL Authentication
  # =====================

  # Implement this hook and return true to enable URL authentication.
  #
  # A sign in attempt will be performed if the URL query string contains
  # one or more params at the key specified at
  # Auth.Config.urlAuthenticationParamsKey.
  # The sign in attempt will pass along all params under the specified key,
  # unmodified except for stripping a trailing slash (if any)
  # It is up to your server to determine what to do with the params.
  #
  # Caveat: if you use the `hash` routing strategy, the query parameters
  # must exist before the Ember route hash.
  # e.g.
  #   http://www.example.com/?auth[remember]=1&auth[key]=fja8hfhf4/#/posts/5
  urlAuthentication: false

  # REQUIRED if you want to use URL authentication
  # This should return the key within which all params to be passed in the
  # sign in call are located.
  # e.g.
  #   If this is set to 'auth',
  #   and given a URL
  #     http://www.example.com/?auth[remember]=1&auth[key]=fja8hfhf4/#/posts/5
  #   a sign in attempt will be to the token creation API, with the params
  #     remember = 1, key = fja8hfhf4
  urlAuthenticationParamsKey: null

  # Implement this hook and return 'both' if you want url authentication to
  # be available in regular Em.Routes as well.
  # Defaults to 'auth' - url authentication only happens in Auth.Routes.
  # Valid values are 'auth' and 'both'
  urlAuthenticationRouteScope: 'auth'

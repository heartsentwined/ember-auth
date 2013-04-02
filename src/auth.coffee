evented = Em.Object.extend(Em.Evented)

window.Auth = evented.create
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

  # Holds prev route for smart redirect.
  prevRoute: null

  # Sign in method
  #
  # This will make an API call to retrieve auth token.
  #
  # On success:
  #   It will store auth token in @authToken
  #   and its associated user model ID in @currentUserId.
  #
  # It will store the jqxhr object in @jqxhr regardless of success.
  #
  # @param {data} object params to pass to API end point in ajax call
  #   data.async = false for synchronous request;
  #     it will be stripped from final POST data
  signIn: (data = {}) ->
    async = if data.async? then data.async else true
    delete data['async'] if data.async?
    @ajax @resolveUrl(Auth.Config.get('tokenCreateUrl')), 'POST',
      data: data
      async: async
      success: (json, status, jqxhr) =>
        @set 'authToken', json[Auth.Config.get('tokenKey')]
        @set 'currentUserId', json[Auth.Config.get('idKey')]
        if model = Auth.Config.get('userModel')
          @set 'currentUser', model.find(@get 'currentUserId')
        @set 'json', json
        @set 'jqxhr', jqxhr
        @trigger 'signInSuccess'
      error: (jqxhr) =>
        @set 'jqxhr', jqxhr
        @trigger 'signInError'
      complete: (jqxhr) =>
        @set 'prevRoute', null
        @set 'jqxhr', jqxhr
        @trigger 'signInComplete'

  # Sign out method
  #
  # This will make an API call to destroy auth token.
  # It will pass the auth token along as a param,
  # using the key set at @tokenKey.
  #
  # On success:
  #   It will set @authToken and @currentUserId to null.
  #
  # It will store the jqxhr object in @jqxhr regardless of success.
  #
  # @param {data} object params to pass to API end point in ajax call
  #   data.async = false for synchronous request;
  #     it will be stripped from final POST data
  signOut: (data = {}) ->
    data[Auth.Config.get('tokenKey')] = @get('authToken')
    async = if data.async? then data.async else true
    delete data['async'] if data.async?
    @ajax @resolveUrl(Auth.Config.get('tokenDestroyUrl')), 'DELETE',
      data: data
      async: async
      success: (json, status, jqxhr) =>
        @set 'authToken', null
        @set 'currentUserId', null
        @set 'jqxhr', jqxhr
        @trigger 'signOutSuccess'
      error: (jqxhr) =>
        @set 'jqxhr', jqxhr
        @trigger 'signOutError'
      complete: (jqxhr) =>
        @set 'prevRoute', null
        @set 'jqxhr', jqxhr
        @trigger 'signOutComplete'

  # =====================
  # End of Public API
  # =====================

  # different base url support
  resolveUrl: (path) ->
    base = Auth.Config.get('baseUrl')
    if base && base[base.length-1] == '/'
      base = base.substr(0, base.length - 1)
    if path?[0] == '/'
      path = path.substr(1, path.length)

    [base, path].join('/')

  # Resolves redirect destination
  # @param {type} string 'signIn' or 'signOut'
  resolveRedirectRoute: (type) ->
    return null unless type in ['signIn', 'signOut']

    typeClassCase = "#{type[0].toUpperCase()}#{type.slice(1)}"
    isSmart   = Auth.Config.get "smart#{typeClassCase}Redirect"
    fallback  = Auth.Config.get "#{type}RedirectFallbackRoute"
    sameRoute = Auth.Config.get "#{type}Route"

    return fallback unless isSmart

    if !@prevRoute? || @prevRoute == sameRoute
      fallback
    else
      @prevRoute

  ajax: (url, type, hash) ->
    hash.url         = url
    hash.type        = type
    hash.dataType    = 'json'
    hash.contentType = 'application/json; charset=utf-8'

    if hash.data && type != 'GET'
      hash.data = JSON.stringify(hash.data)

    jQuery.ajax(hash)

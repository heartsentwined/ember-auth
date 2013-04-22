exports = exports ? this

evented = Em.Object.extend(Em.Evented)

exports.Auth = evented.create
  isInit: true # XXX - redir use
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

  # Holds JSON object on successful API responses
  json: null

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
    @ajax
      url: @resolveUrl Auth.Config.get 'tokenCreateUrl'
      type: 'POST'
      data: data
      async: async
    .done (json, status, jqxhr) =>
      @set 'authToken', json[Auth.Config.get('tokenKey')]
      @set 'currentUserId', json[Auth.Config.get('idKey')]
      if model = Auth.Config.get('userModel')
        @set 'currentUser', model.find(@get 'currentUserId')
      @set 'json', json
      @set 'jqxhr', jqxhr
      @trigger 'signInSuccess'
    .fail (jqxhr) =>
      @set 'jqxhr', jqxhr
      @trigger 'signInError'
    .always (jqxhr) =>
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
    @ajax
      url: @resolveUrl Auth.Config.get 'tokenDestroyUrl'
      type: 'DELETE'
      data: data
      async: async
    .done (json, status, jqxhr) =>
      @set 'authToken', null
      @set 'currentUserId', null
      @set 'currentUser', null
      @set 'jqxhr', jqxhr
      @set 'json', json
      @trigger 'signOutSuccess'
    .fail (jqxhr) =>
      @set 'jqxhr', jqxhr
      @trigger 'signOutError'
    .always (jqxhr) =>
      @set 'prevRoute', null
      @set 'jqxhr', jqxhr
      @trigger 'signOutComplete'

  # =====================
  # End of Public API
  # =====================

  # different base url support
  # @param {path} string the path for resolving full URL
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

    # XXX
    endsWith = (haystack, needle) ->
      d = haystack.length - needle.length
      d >= 0 && haystack.lastIndexOf(needle) == d

    # strip .index from args
    if endsWith(fallback, '.index')
      fallback = fallback.substr(0, fallback.lastIndexOf('.index'))
    if endsWith(sameRoute, '.index')
      sameRoute = sameRoute.substr(0, sameRoute.lastIndexOf('.index'))
    if prevRoute = @get 'prevRoute'
      if endsWith(prevRoute, '.index')
        prevRoute = prevRoute.substr(0, prevRoute.lastIndexOf('.index'))

    if @isInit # initial visit XXX
      if prevRoute # on other pages
        return null
      else # on sign in page
        return fallback
    else if prevRoute == sameRoute # visiting sign in page
      return fallback
    else # visiting other pages
      return null

  # ajax calls with auth token
  # @param {settings} jQuery.ajax options
  #   Defaults will be overrided by those set in this param
  ajax: (settings = {}) ->
    def = {}
    def.dataType = 'json'

    if settings.data && !settings.contentType? && settings.type != 'GET'
      def.contentType = 'application/json; charset=utf-8'
      settings.data = JSON.stringify(settings.data)

    settings = jQuery.extend def, settings

    if token = @get('authToken')
      switch Auth.Config.get 'requestTokenLocation'
        when 'param'
          settings.data ||= {}
          switch typeof settings.data
            when 'object'
              settings.data[Auth.Config.get('tokenKey')] ||= @get('authToken')
            when 'string'
              try
                data = JSON.parse(settings.data)
                data[Auth.Config.get('tokenKey')] ||= @get('authToken')
                settings.data = JSON.stringify(data)
              catch e
                # do nothing
        when 'authHeader'
          settings.headers ||= {}
          settings.headers['Authorization'] ||=
            "#{Auth.Config.get('requestHeaderKey')} #{@get('authToken')}"
        when 'customHeader'
          settings.headers ||= {}
          settings.headers[Auth.Config.get('requestHeaderKey')] ||=
            @get('authToken')

    jQuery.ajax(settings)

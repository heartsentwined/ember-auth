class Em.Auth.TokenAuthStrategy extends Em.Auth.AuthStrategy
  init: ->
    @auth.reopen
      authToken: Em.computed.alias '_strategy.authToken'

  # @property [string|null] the auth token, if signed in; otherwise null
  authToken: null

  serialize: (opts) ->
    return opts unless @auth.signedIn

    switch @auth.tokenLocation
      when 'param'
        opts.data ||= {}
        if FormData? && opts.data instanceof FormData
          opts.data.append @auth.tokenKey, @authToken
        else
          opts.data[@auth.tokenKey] ||= @authToken
      when 'authHeader'
        opts.headers ||= {}
        opts.headers.Authorization ||= "#{@auth.tokenHeaderKey} #{@authToken}"
      when 'customHeader'
        opts.headers ||= {}
        opts.headers[@auth.tokenHeaderKey] ||= @authToken

    return opts

  deserialize: (data) ->
    @authToken            = data[@auth.tokenKey]
    @auth._session.userId = data[@auth.tokenIdKey] if @auth.tokenIdKey

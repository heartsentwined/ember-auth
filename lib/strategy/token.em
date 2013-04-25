class Em.Auth.Strategy.Token
  serialize: (opts = {}) ->
    return opts unless token = @auth.authToken

    switch @auth.tokenLocation
      when 'param'
        opts.data ||= {}
        if FormData && opts.data instanceof FormData
          opts.data.append @auth.tokenKey, token
        else
          opts.data[@auth.tokenKey] ||= token
      when 'authHeader'
        opts.headers ||= {}
        opts.headers.Authorization ||= "#{@auth.tokenHeaderKey} #{token}"
      when 'customHeader'
        opts.headers ||= {}
        opts.headers[@auth.tokenHeaderKey] ||= token

    return opts

  deserialize: (data = {}) ->
    @auth.session.authToken     = data[@auth.tokenKey]
    @auth.session.currentUserId = data[@auth.tokenIdKey]

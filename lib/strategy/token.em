class Em.Auth.Strategy.Token
  serialize: (opts = {}) ->
    return opts unless token = @auth.authToken

    switch @auth.tokenLocation
      when 'param'
        opts.data ||= {}
        switch typeof opts.data
          when 'object'
            if FormData && opts.data instanceof FormData
              opts.data.append @auth.tokenKey, token  # XXX defualt?
            else
              opts.data[@auth.tokenKey] ||= token
          when 'string'
            try
              json = JSON.parse(opts.data)
              json[@auth.tokenKey] ||= token
              opts.data = JSON.stringify(json)
            catch e
              '' # do nothing TODO pending CSR fix
      when 'authHeader'
        opts.headers ||= {}
        opts.headers['Authorization'] ||= "#{@auth.tokenHeaderKey} #{token}"
      when 'customHeader'
        opts.headers ||= {}
        opts.headers[@auth.tokenHeaderKey] ||= token

    return opts

  deserialize: (data = {}) ->
    @auth.authToken     = data[@auth.tokenKey]
    @auth.currentUserId = data[@auth.tokenIdKey]

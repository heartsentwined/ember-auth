class Em.Auth.Strategy.Token
  serialize: (opts = {}) ->
    return opts unless token = @auth.authToken

    switch @auth.requestTokenLocation
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
        opts.headers['Authorization'] ||= "#{@auth.requestHeaderKey} #{token}"
      when 'customHeader'
        opts.headers ||= {}
        opts.headers[@auth.requestHeaderKey] ||= token

    return opts

  deserialize: (data = {}) ->
    @auth.authToken     = data[@auth.tokenKey]
    @auth.currentUserId = data[@auth.idKey]
    if model = @auth.userModel
      @auth.currentUser = model.find(@auth.currentUserId)

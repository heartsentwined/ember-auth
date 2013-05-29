class Em.Auth.Strategy.Token
  init: ->
    @authToken? || (@authToken = null)
    @inject()

  serialize: (opts = {}) ->
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

  deserialize: (data = {}) ->
    @authToken            = data[@auth.tokenKey]
    @auth._session.userId = data[@auth.tokenIdKey] if @auth.tokenIdKey

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      authToken: Em.computed(=> @authToken).property('_strategy.adapter.authToken')

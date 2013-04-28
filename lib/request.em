class Em.Auth.Request
  init: ->
    unless @adapter?
      adapter = Em.String.classify @auth.requestAdapter
      if Em.Auth.Request[adapter]?
        @adapter = Em.Auth.Request[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Request.#{adapter}"

    @inject()

  signIn:  (opts) ->
    @adapter.signIn  @resolveUrl(@auth.signInEndPoint),  opts
  signOut: (opts) ->
    @adapter.signOut @resolveUrl(@auth.signOutEndPoint), opts
  send:    (opts) -> @adapter.send @auth._strategy.serialize(opts)

  # different base url support
  # @param {path} string the path for resolving full URL
  resolveUrl: (path) ->
    base = @auth.baseUrl
    if base && base[base.length-1] == '/'
      base = base.substr(0, base.length-1)
    if path?[0] == '/'
      path = path.substr(1, path.length)
    [base, path].join('/')

  inject: ->
    @auth.reopen
      signIn:  (opts) => @signIn  opts
      signOut: (opts) => @signOut opts
      send:    (opts) => @send    opts

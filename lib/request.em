class Em.Auth.Request
  init: ->
    unless @adapter?
      adapter = Em.String.capitalize Em.String.camelize @auth.requestAdapter
      if Em.Auth.Request[adapter]?
        @adapter = Em.Auth.Request[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Request.#{adapter}"

    @inject()

  syncEvent: ->
    @adapter.syncEvent.apply @adapter, arguments if @adapter.syncEvent?

  signIn:  (opts) ->
    @auth.ensurePromise =>
      url = @resolveUrl @auth.signInEndPoint
      @adapter.signIn  url, @auth._strategy.serialize(opts)
  signOut: (opts) ->
    @auth.ensurePromise =>
      url = @resolveUrl @auth.signOutEndPoint
      @adapter.signOut url, @auth._strategy.serialize(opts)
  send:    (opts) ->
    @auth.ensurePromise => @adapter.send @auth._strategy.serialize(opts)

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

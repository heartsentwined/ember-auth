class Em.Auth.AuthRequest
  init: ->
    @auth.reopen
      signIn:  Em.computed.alias '_request.signIn'
      signOut: Em.computed.alias '_request.signOut'
      send:    Em.computed.alias '_request.send'

  signIn:  mustImplement 'signIn'
  signOut: mustImplement 'signOut'
  send:    mustImplement 'send'

  # different base url support
  # @param {path} string the path for resolving full URL
  resolveUrl: (path) ->
    base = @auth.baseUrl
    if base && base[base.length-1] == '/'
      base = base.substr(0, base.length-1)
    if path?[0] == '/'
      path = path.substr(1, path.length)
    [base, path].join('/')

mustImplement = (method) ->
  ->
    throw new Em.Error "Your request adapter #{@toString()} must implement the required method `#{method}`"

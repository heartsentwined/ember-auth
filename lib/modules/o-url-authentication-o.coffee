Auth.Module.UrlAuthentication = Em.Object.create
  # try to sign in user from query parameter
  # @param {opts} authenticate options
  #   opts.async = false to send a synchronous sign in request
  authenticate: (opts = {}) ->
    return unless Auth.Config.get('urlAuthentication')
    return if Auth.get 'authToken'
    @canonicalizeParams()
    return if $.isEmptyObject @params
    data = {}
    data['async'] = opts.async if opts.async?
    data = $.extend data, @params
    Auth.signIn data

  retrieveParams: ->
    return unless Auth.Config.get('urlAuthentication')
    key = Auth.Config.get('urlAuthenticationParamsKey')
    @params = $.url().param(key)

  canonicalizeParams: (obj = @params) ->
    params = {}
    if !obj?
      params = {}
    else if $.isArray obj
      params[k] = v for v, k in obj
    else if typeof obj != 'object'
      params[String(obj)] = String(obj)
    else
      params = obj

    canonicalized = {}
    for k, v of params
      k = String(k)
      k = k.slice(0, -1) if k && k.charAt(k.length-1) == '/'
      if typeof v == 'object'
        canonicalized[k] = @canonicalizeParams(v)
      else
        v = String(v)
        v = v.slice(0, -1) if v && v.charAt(v.length-1) == '/'
        canonicalized[k] = v
    @params = canonicalized

# hijack the routing process to grab params
# before ember's routing sanitizes the URL
Em.Router.reopen
  init: ->
    if Auth.Config.get('urlAuthentication')
      Auth.Module.UrlAuthentication.retrieveParams()
    @_super.apply(this, arguments)

#= require jquery.url
$ = jQuery
class Em.Auth.Module.UrlAuthenticatable
  init: ->
    @params? || (@params = {})
    @patch()

  authenticate: (opts = {}) ->
    return if @auth.signedIn
    @canonicalizeParams()
    return if $.isEmptyObject @params
    opts.data = $.extend true, @params, (opts.data || {})
    @auth.signIn opts

  retrieveParams: ->
    @params = $.url().param(@auth.urlAuthenticatableParamsKey)

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

  patch: ->
    self = this
    Em.Route.reopen
      redirect: =>
        self.authenticate { async: false }

    # hijack the routing process to grab params
    # before ember's routing sanitizes the URL
    Em.Router.reopen
      init: ->
        self.retrieveParams()
        super.apply(this, arguments)

#= require jquery.url
class Em.Auth.Module.UrlAuthenticatable
  init: ->
    @patch()

  authenticate: (opts = {}) ->
    return if @auth.signedIn
    @canonicalizeParams()
    return if jQuery.isEmptyObject @params
    data = {}
    data.async = opts.async if opts.async?
    data = jQuery.extend data, @params
    @auth.signIn { data: data }

  retrieveParams: ->
    @params = jQuery.url().param(@auth.urlAuthenticatableParamsKey)

  canonicalizeParams: (obj = @params) ->
    params = {}
    if !obj?
      params = {}
    else if jQuery.isArray obj
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
    Em.Route.reopen
      redirect: =>
        @authenticate { async: false } unless @auth.authToken

    # hijack the routing process to grab params
    # before ember's routing sanitizes the URL
    Em.Router.reopen
      init: =>
        @retrieveParams()
        super

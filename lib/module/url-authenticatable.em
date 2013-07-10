#= require jquery.url
$ = jQuery
class Em.Auth.Module.UrlAuthenticatable
  init: ->
    @params? || (@params = {})
    @config? || (@config = @auth.urlAuthenticatable)
    @patch()

  authenticate: (opts = {}) ->
    @auth.wrapDeferred (resolve, reject) =>
      return resolve() if @auth.signedIn
      @canonicalizeParams()
      return resolve() if $.isEmptyObject @params
      opts.data = $.extend true, @params, (opts.data || {})
      # still resolve on failure:
      # - it means a signInError, let error handling proceed from that
      # - allows other codes to continue
      @auth.signIn(opts).then -> resolve(), -> resolve()

  retrieveParams: ->
    @params = $.url().param(@config.paramsKey)

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
      beforeModel: ->
        self.auth.followPromise super.apply(this, arguments), ->
          self.authenticate()

    # hijack the routing process to grab params
    # before ember's routing sanitizes the URL
    Em.Router.reopen
      init: ->
        self.retrieveParams()
        super.apply this, arguments

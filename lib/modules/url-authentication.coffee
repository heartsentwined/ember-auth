Auth.Module.UrlAuthentication = Em.Object.create

  # try to sign in user from query parameter
  # @param {opts} authenticate options
  #   opts.async = false to send a synchronous sign in request
  authenticate: (opts = {}) ->
    return unless Auth.Config.get('urlAuthentication')
    if !Auth.get('authToken') && token = @retrieveToken()
      data = {}
      data['async'] = opts.async if opts.async?
      data[Auth.Config.get('tokenKey')] = token
      Auth.signIn data

  retrieveToken: ->
    token = $.url().param(Auth.Config.get('tokenKey'))
    # Remove trailing slash
    token = token.slice(0, -1) if token && token.charAt(token.length-1) is '/'
    token
  retrieveParams: ->
    return unless Auth.Config.get('urlAuthentication')
    key = Auth.Config.get('urlAuthenticationParamsKey')
    @params = $.url().param(key)?[key]

# hijack the routing process to grab params
# before ember's routing sanitizes the URL
Em.Router.reopen
  init: ->
    if Auth.Config.get('urlAuthentication')
      Auth.Module.UrlAuthentication.retrieveParams()
    @_super.apply(this, arguments)

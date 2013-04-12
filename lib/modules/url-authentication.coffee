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
      if remember = @retrieveRemember()
        data[Auth.Config.get('rememberKey')] = true
      Auth.signIn data

  retrieveToken: ->
    token = $.url().param(Auth.Config.get('tokenKey'))
    # Remove trailing slash
    token = token.slice(0, -1) if token && token.charAt(token.length-1) is '/'
    token

  retrieveRemember: ->
    remember = $.url().param(Auth.Config.get('rememberKey'))
    remember
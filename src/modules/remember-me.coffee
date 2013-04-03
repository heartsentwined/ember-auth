Auth.Module.RememberMe = Em.Object.create
  init: ->
    Auth.on 'signInSuccess', =>
      @remember()

    Auth.on 'signInError', =>
      @forget()

    Auth.on 'signOutSuccess', =>
      @forget()

  # try to sign in user from local remember me cookie
  # @param {opts} recall options
  #   opts.async = false to send a synchronous sign in request
  recall: (opts = {}) ->
    return unless Auth.Config.get 'rememberMe'
    if !Auth.get('authToken') && token = @retrieveToken()
      data = {}
      data['async'] = opts.async if opts.async?
      data[Auth.Config.get('rememberTokenKey')] = token
      Auth.signIn data

  # set local remember me cookie
  remember: ->
    return unless Auth.Config.get 'rememberMe'
    token = Auth.get('json')[Auth.Config.get('rememberTokenKey')]
    @storeToken(token) if token && token != @retrieveToken()

  # destroy local remember me cookie
  forget: ->
    return unless Auth.Config.get 'rememberMe'
    @removeToken()

  retrieveToken: ->
    if Auth.Config.get 'rememberUsingLocalStorage'
      localStorage.getItem 'ember-auth-remember-me'
    else
      $.cookie 'ember-auth-remember-me'

  storeToken: (token) ->
    if Auth.Config.get 'rememberUsingLocalStorage'
      localStorage.setItem 'ember-auth-remember-me', token
    else
      $.cookie 'ember-auth-remember-me', token, expires: Auth.Config.get('rememberPeriod')

  removeToken: ->
    if Auth.Config.get 'rememberUsingLocalStorage'
      localStorage.removeItem 'ember-auth-remember-me'
    else
      $.removeCookie 'ember-auth-remember-me'

# monkey-patch Auth.Route to recall session (if any) before redirecting
Auth.Route.reopen
  redirect: ->
    if Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall')
      Auth.Module.RememberMe.recall { async: false }
    @_super()

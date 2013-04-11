Auth.Module.RememberMe = Em.Object.create
  init: ->
    Auth.on 'signInSuccess', =>
      @forget()
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

  # delegate to different token retrieval methods
  retrieveToken: ->
    switch Auth.Config.get 'rememberStorage'
      when 'localStorage' then localStorage.getItem 'ember-auth-remember-me'
      when 'cookie' then jQuery.cookie 'ember-auth-remember-me'

  # delegate to different token storage methods
  storeToken: (token) ->
    switch Auth.Config.get 'rememberStorage'
      when 'localStorage'
        localStorage.setItem 'ember-auth-remember-me', token
      when 'cookie'
        jQuery.cookie 'ember-auth-remember-me', token,
          expires: Auth.Config.get('rememberPeriod')

  # delegate to different token removal methods
  removeToken: ->
    switch Auth.Config.get 'rememberStorage'
      when 'localStorage' then localStorage.removeItem 'ember-auth-remember-me'
      when 'cookie' then jQuery.removeCookie 'ember-auth-remember-me'

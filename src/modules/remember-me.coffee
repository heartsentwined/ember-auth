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
    if !Auth.get('authToken') && token = $.cookie('ember-auth-remember-me')
      data = {}
      data['async'] = opts.async if opts.async?
      data[Auth.Config.get('rememberTokenKey')] = token
      Auth.signIn data

  # set local remember me cookie
  remember: ->
    return unless Auth.Config.get 'rememberMe'
    json = JSON.parse (Auth.get 'jqxhr').responseText
    token = json[Auth.Config.get('rememberTokenKey')]
    curToken = $.cookie 'ember-auth-remember-me'
    if token && token != curToken
      $.cookie 'ember-auth-remember-me', token,
        expires: Auth.Config.get 'rememberPeriod'

  # destroy local remember me cookie
  forget: ->
    return unless Auth.Config.get 'rememberMe'
    $.removeCookie 'ember-auth-remember-me'

# monkey-patch Auth.Route to recall session (if any) before redirecting
Auth.Route.reopen
  redirect: ->
    if Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall')
      if request = Auth.Module.RememberMe.recall(async: false)
        self = @
        callback = @_super
        return request.always ->
          callback.call(self)
    @_super()

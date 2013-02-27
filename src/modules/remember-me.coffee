Auth.Module.RememberMe = Em.Object.create
  init: ->
    Auth.on 'signInSuccess', =>
      @remember()

    Auth.on 'signInError', =>
      @forget()

    Auth.on 'signOutSuccess', =>
      @forget()

  # try to sign in user from local remember me cookie
  recall: ->
    return unless Auth.Config.get 'rememberMe'
    if !Auth.get('authToken') && token = $.cookie('ember-auth-remember-me')
      data = {}
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

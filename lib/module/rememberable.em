class Em.Auth.Module.Rememberable
  init: ->
    @auth.on 'signInSuccess',  => @remember()
    @auth.on 'signInError',    => @forget()
    @auth.on 'signOutSuccess', => @forget()
    @patch()

  recall: (opts = {}) ->
    if !@auth.authToken && token = @retrieveToken()
      @fromRecall = true
      data = {}
      data.async = opts.async if opts.async?
      data[@auth.rememberTokenKey] = token
      @auth.signIn { data: data }

  remember: ->
    if token = @auth.json[@auth.rememberTokenKey]
      @storeToken(token) if token != @retrieveToken()
    else
      @forget() unless @fromRecall
    @fromRecall = false

  forget: ->
    @removeToken()

  retrieveToken: ->
    @auth.storage.retrieve 'ember-auth-rememberable'

  storeToken: (token) ->
    @auth.storage.store 'ember-auth-rememberable', token,
      expires: @auth.rememberPeriod

  removeToken: ->
    @auth.storage.remove 'ember-auth-rememberable'

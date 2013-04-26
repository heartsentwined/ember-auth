class Em.Auth.Module.Rememberable
  init: ->
    @auth.on 'signInSuccess',  => @remember()
    @auth.on 'signInError',    => @forget()
    @auth.on 'signOutSuccess', => @forget()
    @patch()

  recall: (opts = {}) ->
    if !@auth.authToken && (token = @retrieveToken())
      @fromRecall = true
      opts.data ||= {}
      opts.data[@auth.rememberableTokenKey] = token
      @auth.signIn opts

  remember: ->
    if token = @auth.json[@auth.rememberableTokenKey]
      @storeToken(token) if token != @retrieveToken()
    else
      @forget() unless @fromRecall
    @fromRecall = false

  forget: ->
    @removeToken()

  retrieveToken: ->
    @auth._session.retrieve 'ember-auth-rememberable'

  storeToken: (token) ->
    @auth._session.store 'ember-auth-rememberable', token,
      expires: @auth.rememberablePeriod

  removeToken: ->
    @auth._session.remove 'ember-auth-rememberable'

  patch: ->
    Em.Route.reopen
      redirect: =>
        if !@auth.authToken && @auth.rememberableAutoRecall
          @recall { async: false }

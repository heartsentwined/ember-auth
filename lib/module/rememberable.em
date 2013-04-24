class Em.Auth.Module.Rememberable
  init: ->
    @auth.on 'signInSuccess',  => @remember()
    @auth.on 'signInError',    => @forget()
    @auth.on 'signOutSuccess', => @forget()
    @patch()

  recall: (opts = {}) ->
    if !@auth.authToken && (token = @retrieveToken())
      @fromRecall = true
      data = {}
      data.async = opts.async if opts.async?
      data[@auth.rememberableTokenKey] = token
      @auth.signIn { data: data }

  remember: ->
    if token = @auth.json[@auth.rememberableTokenKey]
      @storeToken(token) if token != @retrieveToken()
    else
      @forget() unless @fromRecall
    @fromRecall = false

  forget: ->
    @removeToken()

  retrieveToken: ->
    @auth.session.retrieve 'ember-auth-rememberable'

  storeToken: (token) ->
    @auth.session.store 'ember-auth-rememberable', token,
      expires: @auth.rememberablePeriod

  removeToken: ->
    @auth.session.remove 'ember-auth-rememberable'

  patch: ->
    Em.Route.reopen
      redirect: =>
        if !@auth.authToken && @auth.rememberableAutoRecall
          @recall { async: false }

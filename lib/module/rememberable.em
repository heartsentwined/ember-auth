class Em.Auth.Module.Rememberable
  init: ->
    @config? || (@config = @auth.rememberable)
    @patch()

  syncEvent: (name, args...) ->
    switch name
      when 'signInSuccess'  then @remember()
      when 'signInError'    then @forget()
      when 'signOutSuccess' then @forget()

  recall: (opts = {}) ->
    @auth.wrapDeferred (resolve, reject) =>
      if !@auth.signedIn && (token = @retrieveToken())
        @fromRecall = true
        opts.data ||= {}
        opts.data[@config.tokenKey] = token
        @auth.signIn(opts).then -> resolve(), -> reject()
      else
        resolve()

  remember: ->
    if token = @auth.response?[@config.tokenKey]
      @storeToken(token) unless token == @retrieveToken()
    else
      @forget() unless @fromRecall
    @fromRecall = false

  forget: ->
    @removeToken()

  retrieveToken: ->
    @auth._session.retrieve 'ember-auth-rememberable'

  storeToken: (token) ->
    @auth._session.store 'ember-auth-rememberable', token,
      expires: @config.period

  removeToken: ->
    @auth._session.remove 'ember-auth-rememberable'

  patch: ->
    self = this
    Em.Route.reopen
      beforeModel: ->
        self.auth.followPromise super.apply(this, arguments), ->
          self.recall() if self.config.autoRecall && !self.auth.signedIn

class Em.Auth.Module.Browsersessionable
  init: ->
    @config? || (@config = @auth.browsersessionable)
    @patch()

  syncEvent: (name, args...) ->
    switch name
      when 'signInSuccess'  then @storeSessionToken()
      when 'signInError'    then @deleteSessionToken()
      when 'signOutSuccess' then @deleteSessionToken()

  recall: (opts = {}) ->
    if !@auth.signedIn && (token = @retrieveToken())
      @fromRecall = true
      opts.data ||= {}
      opts.data[@config.tokenKey] = token
      @auth.signIn opts

  storeSessionToken: ->
    if token = @auth.response?[@config.tokenKey]
      @storeToken(token) unless token == @retrieveToken()
    else
      @deleteSessionToken() unless @fromRecall
    @fromRecall = false

  deleteSessionToken: ->
    @removeToken()

  retrieveToken: ->
    @auth._session.retrieve 'ember-auth-session'

  storeToken: (token) ->
    @auth._session.store 'ember-auth-session', token

  removeToken: ->
    @auth._session.remove 'ember-auth-session'

  patch: ->
    self = this
    Em.Route.reopen
      redirect: ->
        super.apply this, arguments
        if self.config.autoRecall && !self.auth.signedIn
          self.recall { async: false }

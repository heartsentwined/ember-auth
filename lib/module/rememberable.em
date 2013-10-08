class Em.Auth.RememberableAuthModule
  init: ->
    @config? || (@config = @auth.rememberable)
    @patch()

    @auth.addHandler 'signInSuccess',  @remember
    @auth.addHandler 'signInError',    @forget
    @auth.addHandler 'signOutSuccess', @forget

  # try to recall a remembered session, if any
  #
  # @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #   default: {}
  #
  # @return [Em.RSVP.Promise]
  #   if a remembered session is found, returns the auth.signIn() promise
  #   else returns a resolved empty promise
  recall: (opts = {}) ->
    if !@auth.signedIn && (token = @retrieveToken())
      opts.data ||= {}
      opts.data[@config.tokenKey] = token
      if @config.endPoint?
        url = @auth._request.resolveUrl @config.endPoint
        @auth.signIn url, opts
      else
        @auth.signIn opts
    else
      new Em.RSVP.resolve

  # clear any existing remembered session,
  # then extract any rememberable session info from sign in payload
  #
  # @param data [object] the `canonicalize`d data object
  remember: (data) ->
    # clear any existing remembered session first
    @forget()

    if token = data[@config.tokenKey]
      @storeToken(token) unless token == @retrieveToken()

  # clear any existing remembered session
  forget: ->
    @removeToken()

  # retreive the rememberable token from session storage
  #
  # @return [string|null|undefined] the rememberable token, or null/undef
  retrieveToken: ->
    @auth._session.retrieve 'ember-auth-rememberable'

  # store the rememberable token into session storage
  #
  # @param token [string] the rememberable token
  storeToken: (token) ->
    @auth._session.store 'ember-auth-rememberable', token,
      expires: @config.period

  # remove any rememberable token from session storage
  removeToken: ->
    @auth._session.remove 'ember-auth-rememberable'

  patch: ->
    self = this
    Em.Route.reopen
      beforeModel: ->
        ret = super.apply this, arguments
        return ret unless self.config.autoRecall && !self.auth.signedIn

        if typeof ret.then == 'function'
          ret.then -> self.recall()
        else
          self.recall()

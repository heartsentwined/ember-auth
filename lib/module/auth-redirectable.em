class Em.Auth.AuthRedirectableAuthModule
  init: ->
    @config? || (@config = @auth.authRedirectable)

    # register an authAccess handler type
    @auth._handlers.authAccess = []

    @patch()

  patch: ->
    self = this
    mixin @AuthRedirectable
      beforeModel: (transition) ->
        ret = super.apply this, arguments
        return ret if self.auth.signedIn

        promises = []
        promises.push handler(transition) for handler in @_handlers.authAccess

        if typeof ret.then == 'function'
          ret.then =>
            Em.RSVP.all(promises).then => @transitionTo self.config.route
        else
          Em.RSVP.all(promises).then => @transitionTo self.config.route

    @auth.AuthRedirectable = @AuthRedirectable

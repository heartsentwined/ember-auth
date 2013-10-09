class Em.Auth.AuthRedirectableAuthModule
  init: ->
    @config? || (@config = @auth.authRedirectable)

    # register an authAccess handler type
    @auth._handlers.authAccess = []

    @patch()

  patch: ->
    self = this
    Em.Route.reopen
      beforeModel: (queryParams, transition) ->
        ret = super.apply this, arguments
        return ret if self.auth.signedIn || !@authRedirectable

        transition = queryParams unless transition?

        promises = []
        for handler in self.auth._handlers.authAccess
          promises.push handler(transition)

        if typeof ret.then == 'function'
          ret.then =>
            Em.RSVP.all(promises).then => @transitionTo self.config.route
        else
          Em.RSVP.all(promises).then => @transitionTo self.config.route

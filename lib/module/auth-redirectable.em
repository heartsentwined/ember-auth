class Em.Auth.Module.AuthRedirectable
  init: ->
    @config? || (@config = @auth.authRedirectable)
    @patch()

  patch: ->
    self = this
    mixin @AuthRedirectable
      beforeModel: ->
        self.auth.followPromise super.apply(this, arguments), =>
          return if self.auth.signedIn
          self.auth.trigger 'authAccess'
          @transitionTo self.config.route
    @auth.AuthRedirectable = @AuthRedirectable

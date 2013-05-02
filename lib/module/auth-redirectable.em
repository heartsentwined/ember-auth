class Em.Auth.Module.AuthRedirectable
  init: ->
    @config? || (@config = @auth.authRedirectable)
    @patch()

  patch: ->
    self = this
    mixin @AuthRedirectable
      redirect: ->
        super.apply this, arguments
        unless self.auth.signedIn
          self.auth.trigger 'authAccess'
          @transitionTo self.config.route
    @auth.AuthRedirectable = @AuthRedirectable

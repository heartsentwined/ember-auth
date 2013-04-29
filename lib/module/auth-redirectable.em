class Em.Auth.Module.AuthRedirectable
  init: -> @patch()

  patch: ->
    self = this
    mixin @AuthRedirectable
      redirect: ->
        unless self.auth.get('signedIn')
          @transitionTo self.auth.authRedirectableRoute
    @auth.AuthRedirectable = @AuthRedirectable

Auth.SignInController = Em.Mixin.create
  registerRedirect: ->
    Auth.addObserver 'authToken', this, 'smartSignInRedirect'

  smartSignInRedirect: ->
    if Auth.get('authToken')
      @transitionToRoute Auth.resolveRedirectRoute('signIn')
      Auth.removeObserver 'authToken', this, 'smartSignInRedirect'

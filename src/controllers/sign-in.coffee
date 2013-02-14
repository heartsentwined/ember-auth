Auth.SignInController = Em.ObjectController.extend
  registerRedirect: ->
    Auth.addObserver 'authToken', this, 'smartSignInRedirect'

  smartSignInRedirect: ->
    if Auth.get('authToken')
      @get('target.router').transitionTo Auth.resolveRedirectRoute('signIn')
      Auth.removeObserver 'authToken', this, 'smartSignInRedirect'

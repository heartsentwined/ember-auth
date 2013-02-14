Auth.SignOutController = Em.ObjectController.extend
  registerRedirect: ->
    Auth.addObserver 'authToken', this, 'smartSignOutRedirect'

  smartSignOutRedirect: ->
    if !Auth.get('authToken')
      @get('target.router').transitionTo Auth.resolveRedirectRoute('signOut')
      Auth.removeObserver 'authToken', this, 'smartSignOutRedirect'

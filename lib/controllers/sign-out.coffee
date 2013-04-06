Auth.SignOutController = Em.Mixin.create
  registerRedirect: ->
    Auth.addObserver 'authToken', this, 'smartSignOutRedirect'

  smartSignOutRedirect: ->
    if !Auth.get('authToken')
      @transitionToRoute Auth.resolveRedirectRoute('signOut')
      Auth.removeObserver 'authToken', this, 'smartSignOutRedirect'

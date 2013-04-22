Auth.SignInController = Em.Mixin.create
  registerRedirect: ->
    Auth.addObserver 'authToken', this, 'smartSignInRedirect'

  smartSignInRedirect: -> # XXX
    if Auth.get('authToken')
      if route = Auth.resolveRedirectRoute('signIn') # got fallback route
        @transitionToRoute route
      else if Auth.get('isInit') # init path
        path = Auth.get('prevPath')
        router = @get 'target'
        router.location.setURL path
        router.handleURL path
      else if args = Auth.get('prevRouteArgs') # route with args
        @transitionToRoute.apply(this, args)
      else if route = Auth.get('prevRoute') # route without args
        @transitionToRoute route
      else
        # ???

      Auth.removeObserver 'authToken', this, 'smartSignInRedirect'

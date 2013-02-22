Auth.Route = Em.Route.extend Em.Evented,
  redirect: ->
    if !Auth.get 'authToken'
      @trigger 'authAccess'
      if Auth.Config.get 'authRedirect'
        Auth.set 'prevRoute', @routeName
        @transitionTo Auth.Config.get('signInRoute')

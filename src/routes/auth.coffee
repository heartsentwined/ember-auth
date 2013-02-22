Auth.Route = Em.Route.extend Em.Evented,
  redirect: ->
    if Auth.Config.get('authRedirect') && !Auth.get('authToken')
      @trigger 'authAccess'
      Auth.set 'prevRoute', @routeName
      @transitionTo Auth.Config.get('signInRoute')

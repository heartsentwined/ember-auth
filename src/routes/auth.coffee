Auth.Route = Em.Route.extend
  redirect: ->
    if Auth.Config.get('authRedirect') && !Auth.get('authToken')
      Auth.set 'prevRoute', @routeName
      @transitionTo Auth.Config.get('signInRoute')

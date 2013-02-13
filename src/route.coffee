Auth.Route = Em.Route.extend
  redirect: ->
    if Auth.Config.get('redirect') && !Auth.get('authToken')
      Auth.set 'prevRoute', @routeName
      @transitionTo Auth.Config.get('signInRoute')

Auth.Route = Em.Route.extend
  redirect: ->
    if !Auth.Config.get('disableRedirect') || Auth.get('authToken')
      Auth.set 'prevRoute', @routeName
      @transitionTo Auth.Config.get('signInRoute')

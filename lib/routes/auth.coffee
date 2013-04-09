Auth.Route = Em.Route.extend Em.Evented,
  redirect: ->
    
    return if Auth.get('authToken') 
    
    if Auth.Config.get('urlAuthentication')
      Auth.Module.UrlAuthentication.authenticate({ async: false })
      return if Auth.get('authToken')
    
    if Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall')
      Auth.Module.RememberMe.recall({ async: false })
      return if Auth.get('authToken')
      
    @trigger('authAccess')
    
    if Auth.Config.get('authRedirect')
      Auth.set('prevRoute', @routeName)
      @transitionTo Auth.Config.get('signInRoute')
      
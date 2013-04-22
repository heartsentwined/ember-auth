Em.Route.reopen
  redirect: ->
    if Auth.Config.get('urlAuthentication') \
    && Auth.Config.get('urlAuthenticationRouteScope') == 'both'
      Auth.Module.UrlAuthentication.authenticate({ async: false })
      return @_super.apply(this, arguments) if Auth.get('authToken')

    if Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall') \
    && Auth.Config.get('rememberAutoRecallRouteScope') == 'both'
      Auth.Module.RememberMe.recall({ async: false })
      return @_super.apply(this, arguments) if Auth.get('authToken')

    if Auth.Config.get('authRedirect') # XXX
      if !Auth.get('prevPath')
        Auth.set('prevPath', @router.get('location').getURL())

    @_super.apply(this, arguments)

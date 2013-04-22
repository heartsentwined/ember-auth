Em.Router.reopen
  transitionTo: ->
    args = Array::slice.call(arguments)
    lastArg = args.pop()
    unless typeof lastArg == 'object' && lastArg['log']?
      args.push(lastArg)
    if (!lastArg['log']? || lastArg['log']) && Auth.Config.get('authRedirect')
      Auth.set('isInit', false)
      Auth.set('prevRoute', args.slice(0, 1)[0])
      Auth.set('prevRouteArgs', args)
    @_super.apply(this, args)

  replaceWith: ->
    args = Array::slice.call(arguments)
    lastArg = args.pop()
    unless typeof lastArg == 'object' && lastArg['log']?
      args.push(lastArg)
    if (!lastArg['log']? || lastArg['log']) && Auth.Config.get('authRedirect')
      Auth.set('isInit', false)
      Auth.set('prevRoute', args.slice(0, 1)[0])
      Auth.set('prevRouteArgs', args)
    @_super.apply(this, args)

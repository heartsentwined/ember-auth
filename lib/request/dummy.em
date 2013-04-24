class Em.Auth.Request.Dummy
  signIn: (url, opts = {}) ->
    @send opts
    switch opts.status
      when 'success' then @auth.trigger 'signInsuccess'
      when 'error'   then @auth.trigger 'signInError'
    @trigger 'signInComplete'

  signOut: (url, opts = {}) ->
    @send opts
    switch opts.status
      when 'success' then @auth.trigger 'signOutsuccess'
      when 'error'   then @auth.trigger 'signOutError'
    @trigger 'signOutComplete'

  send: (opts = {}) ->
    @auth.strategy.deserialize(opts)

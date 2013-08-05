class Em.Auth.Request.Dummy
  signIn: (url, opts = {}) ->
    @send opts
    switch opts.status
      when 'success' then @auth.trigger 'signInSuccess'
      when 'error'   then @auth.trigger 'signInError'
    @auth.trigger 'signInComplete'

  signOut: (url, opts = {}) ->
    @send opts
    switch opts.status
      when 'success' then @auth.trigger 'signOutSuccess'
      when 'error'   then @auth.trigger 'signOutError'
    @auth.trigger 'signOutComplete'

  send: (opts = {}) ->
    @auth._response.canonicalize opts

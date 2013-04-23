class Em.Auth.Request
  init: ->
    adapter = Em.String.classify @auth.requestAdapter
    if Em.Auth.Request[adapter]?
      @adapter = Em.Auth.Request[adapter].create({ auth: @auth })
    else
      throw "Em.Auth.Request adapter not found: #{@auth.requestAdapter}"

  signIn:  (data) -> @adapter.signIn  @auth.strategy.serialize('signIn', data)
  signOut: (data) -> @adapter.signOut @auth.strategy.serialize('signOut', data)
  send:           -> @adapter.send.apply(this, arguments)

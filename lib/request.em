class Em.Auth.Request
  init: ->
    adapter = Em.String.classify @auth.requestAdapter
    if Em.Auth.Request[adapter]?
      @adapter = Em.Auth.Request[adapter].create({ auth: @auth })
    else
      throw "Em.Auth.Request adapter not found: #{@auth.requestAdapter}"

  signIn:  (opts) -> @adapter.signIn  @auth.strategy.serialize(opts)
  signOut: (opts) -> @adapter.signOut @auth.strategy.serialize(opts)
  send:           -> @adapter.send.apply(this, arguments)

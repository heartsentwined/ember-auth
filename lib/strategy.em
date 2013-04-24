class Em.Auth.Strategy
  init: ->
    adapter = Em.String.classify @auth.strategyAdapter
    if Em.Auth.Strategy[adapter]?
      @adapter = Em.Auth.Strategy[adapter].create { auth: @auth }
    else
      throw "Adapter not found: Em.Auth.Strategy.#{adapter}"

  serialize:   (opts) -> @adapter.serialize(opts)
  deserialize: (opts) -> @adapter.deserialize(opts)

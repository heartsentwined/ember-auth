class Em.Auth.Strategy
  init: ->
    adapter = Em.String.classify @auth.strategyAdapter
    if Em.Auth.Strategy[adapter]?
      @adapter = Em.Auth.Strategy[adapter].create({ auth: @auth })
    else
      throw "Adapter not found: Em.Auth.Strategy.#{adapter}"

  serialize:   (env, data) -> @adapter.serialize   env, data
  deserialize: (env, data) -> @adapter.deserialize env, data

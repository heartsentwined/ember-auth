class Em.Auth.Strategy
  init: ->
    unless @adapter?
      adapter = Em.String.capitalize Em.String.camelize @auth.strategyAdapter
      if Em.Auth.Strategy[adapter]?
        @adapter = Em.Auth.Strategy[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Strategy.#{adapter}"

  syncEvent: (name, args...) ->
    switch name
      when 'signInSuccess' then @deserialize()
    @adapter.syncEvent.apply @adapter, arguments if @adapter.syncEvent?

  serialize:   (opts) -> @adapter.serialize   opts
  deserialize:        -> @adapter.deserialize @auth.response

class Em.Auth.Strategy.Dummy
  serialize: (opts = {}) ->
    opts

  deserialize: (data = {}) ->
    for k, v of data
      @auth.set k, v

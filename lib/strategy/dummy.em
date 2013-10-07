class Em.Auth.DummyAuthStrategy extends Em.Auth.AuthStrategy
  serialize:   (opts) -> opts
  deserialize: (data) -> @auth.set k, v for k, v of data

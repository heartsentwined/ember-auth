class Em.Auth.DummyAuthSession extends Em.Auth.AuthSession
  session: {}

  retrieve: (key) ->
    @get "session.#{key}"

  store: (key, value) ->
    @set "session.#{key}", value

  remove: (key) ->
    delete @session[key]

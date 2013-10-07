class Em.Auth.DummyAuthSession extends Em.Auth.AuthSession
  _session: {}

  retrieve: (key) ->
    @get "_session.#{key}"

  store: (key, value) ->
    @set "_session.#{key}", value

  remove: (key) ->
    delete @_session[key]

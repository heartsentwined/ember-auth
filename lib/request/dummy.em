class Em.Auth.DummyAuthRequest extends Em.Auth.AuthRequest
  signIn: (url, opts) ->
    @send opts

  signOut: (url, opts) ->
    @send opts

  send: (opts) ->
    new Em.RSVP.Promise (resolve, reject) -> resolve opts

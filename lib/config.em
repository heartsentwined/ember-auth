Em.Auth.reopen
  # [string] (opt) request adapter;
  #   default: 'jquery'
  request:  'jquery'

  # [string] (opt) response adapter;
  #   default: 'json'
  response: 'json'

  # [string] (opt) strategy adapter;
  #   default: 'token'
  strategy: 'token'

  # [string] (opt) session adapter;
  #   default: 'cookie'
  session:  'cookie'

  # [array<string>] (opt) list of modules, loaded in order specified;
  #   default: []
  modules: []

  # [string] end point for sign in requests
  signInEndPoint: null

  # [string] end point for sign out requests
  signOutEndPoint: null

  # [string|null] (opt) a different base url for all ember-auth requests
  baseUrl: null

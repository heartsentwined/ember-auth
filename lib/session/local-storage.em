class Em.Auth.LocalStorageAuthSession
  retrieve: (key) ->
    localStorage.getItem key
  store: (key, value) ->
    localStorage.setItem key, value
  remove: (key) ->
    localStorage.removeItem key

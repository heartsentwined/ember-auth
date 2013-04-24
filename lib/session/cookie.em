class Em.Auth.Session.Cookie
  retrieve: (key, opts) ->
    jQuery.cookie key
  store: (key, value, opts) ->
    jQuery.cookie key, token, jQuery.extend(true, { path: '/' }, opts)
  remove: (key, opts) ->
    jQuery.removeCookie key, jQuery.extend(true, { path: '/' }, opts)

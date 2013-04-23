class Em.Auth.Session
  clear: ->
    @auth.authToken     = null
    @auth.currentUserid = null
    @auth.currentUser   = null

class Em.Auth.Session
  init: ->
    @inject()

  clear: ->
    @authToken     = null
    @currentUserid = null
    @currentUser   = null

  inject: ->
    self = this
    @auth.reopen
      authToken:     ~> self.authToken
      currentUserId: ~> self.currentUserId
      currentUser:   ~> self.currentUser

class Em.Auth.Session
  init: ->
    adapter = Em.String.classify @auth.sessionAdapter
    if Em.Auth.Session[adapter]?
      @adapter = Em.Auth.Session[adapter].create { auth: @auth }
    else
      throw "Adapter not found: Em.Auth.Session.#{adapter}"

    @auth.on 'signInSuccess',  => @findUser()
    @auth.on 'signOutSuccess', => @clear()

    @inject()

  findUser: ->
    if model = @auth.userModel
      @currentUser = model.find(@currentUserId)

  clear: ->
    @authToken     = null
    @currentUserid = null
    @currentUser   = null

  retrieve: (key, opts)        -> @adapter.retrieve key, opts
  store:    (key, value, opts) -> @adapter.store    key, value, opts
  remove:   (key, opts)        -> @adapter.remove   key, opts

  inject: ->
    self = this
    @auth.reopen
      authToken:     ~> self.authToken
      currentUserId: ~> self.currentUserId
      currentUser:   ~> self.currentUser

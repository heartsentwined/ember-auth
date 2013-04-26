class Em.Auth.Session
  authToken:     null
  currentUserId: null
  currentUser:   null

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
      @currentUser = model.find @currentUserId

  clear: ->
    @authToken     = null
    @currentUserId = null
    @currentUser   = null

  retrieve: (key, opts)        -> @adapter.retrieve key, opts
  store:    (key, value, opts) -> @adapter.store    key, value, opts
  remove:   (key, opts)        -> @adapter.remove   key, opts

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      authToken:     Em.computed(=> @authToken).property('_session.authToken')
      currentUserId: Em.computed(=> @currentUserId).property('_session.currentUserId')
      currentUser:   Em.computed(=> @currentUser).property('_session.currentUser')

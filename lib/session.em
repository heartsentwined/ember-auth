class Em.Auth.Session
  signedIn: false
  userId:   null
  user:     null

  init: ->
    adapter = Em.String.classify @auth.sessionAdapter
    if Em.Auth.Session[adapter]?
      @adapter = Em.Auth.Session[adapter].create { auth: @auth }
    else
      throw "Adapter not found: Em.Auth.Session.#{adapter}"

    @auth.on 'signInSuccess',  => @start()
    @auth.on 'signInSuccess',  => @findUser()
    @auth.on 'signOutSuccess', => @clear()

    @inject()

  findUser: ->
    if model = @auth.userModel
      @user = model.find @userId

  start: ->
    @signedIn = true

  clear: ->
    @signedIn = false
    @userId   = null
    @user     = null

  retrieve: (key, opts)        -> @adapter.retrieve key, opts
  store:    (key, value, opts) -> @adapter.store    key, value, opts
  remove:   (key, opts)        -> @adapter.remove   key, opts

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      signedIn: Em.computed(=> @signedIn).property('_session.signedIn')
      userId:   Em.computed(=> @userId  ).property('_session.userId')
      user:     Em.computed(=> @user    ).property('_session.user')

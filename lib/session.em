class Em.Auth.Session
  init: ->
    @signedIn? || (@signedIn = false)
    @userId?   || (@userId   = null)
    @user?     || (@user     = null)

    unless @adapter?
      adapter = Em.String.capitalize Em.String.camelize @auth.sessionAdapter
      if Em.Auth.Session[adapter]?
        @adapter = Em.Auth.Session[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Session.#{adapter}"

    @auth.on 'signInSuccess', => @start()
    @auth.on 'signOutSuccess', => @clear()

    @inject()

  syncEvent: (name, args...) ->
    @adapter.syncEvent.apply @adapter, arguments if @adapter.syncEvent?

  findUser: ->
    if @userId && (modelKey = @auth.userModel) && (model = Ember.get modelKey)
      @user = model.find @userId

  start: ->
    @signedIn  = true
    @startTime = new Date()
    @endTime   = null
    @findUser()

  clear: ->
    @signedIn  = false
    @userId    = null
    @user      = null
    @startTime = null
    @endTime   = new Date()

  retrieve: (key, opts)        -> @adapter.retrieve key, opts
  store:    (key, value, opts) -> @adapter.store    key, value, opts
  remove:   (key, opts)        -> @adapter.remove   key, opts

  create: (input) ->
    @auth._response.canonicalize input
    @auth.trigger 'signInSuccess'

  destroy: ->
    @auth._response.canonicalize ''
    @auth.trigger 'signOutSuccess'

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      signedIn:  Em.computed(=> @signedIn ).property('_session.signedIn')
      userId:    Em.computed(=> @userId   ).property('_session.userId')
      user:      Em.computed(=> @user     ).property('_session.user')
      startTime: Em.computed(=> @startTime).property('_session.startTime')
      endTime:   Em.computed(=> @endTime  ).property('_session.endTime')

      createSession:  (input) => @create input
      destroySession:         => @destroy()

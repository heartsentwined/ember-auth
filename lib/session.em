class Em.Auth.AuthSession
  init: ->
    @auth.reopen
      signedIn:  Em.computed.alias '_session.signedIn'
      userId:    Em.computed.alias '_session.userId'
      startTime: Em.computed.alias '_session.startTime'
      endTime:   Em.computed.alias '_session.endTime'

    @signedIn  = false
    @userId    = null
    @startTime = null
    @endTime   = null

  start: ->
    @signedIn  = true
    @startTime = new Date()
    @endTime   = null

  end: ->
    @signedIn  = false
    @userId    = null
    @startTime = null
    @endTime   = new Date()

  retrieve: mustImplement 'retrieve'
  store:    mustImplement 'store'
  remove:   mustImplement 'remove'

mustImplement = (method) ->
  ->
    throw new Em.Error "Your session adapter #{@toString()} must implement the required method `#{method}`"

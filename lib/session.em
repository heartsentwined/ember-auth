mustImplement = (method) ->
  ->
    throw new Em.Error "Your session adapter #{@toString()} must implement the required method `#{method}`"

class Em.Auth.AuthSession
  init: ->
    @auth.reopen
      signedIn:  Em.computed.alias '_session.signedIn'
      userId:    Em.computed.alias '_session.userId'
      startTime: Em.computed.alias '_session.startTime'
      endTime:   Em.computed.alias '_session.endTime'

    @auth.addHandler 'signInSuccess',  @start
    @auth.addHandler 'signOutSuccess', @end

  # @property [bool] whether a user has signed in
  signedIn:  false

  # @property [(any type)|null] the user ID, type depends on strategy adapter;
  #   null if not signed in
  userId:    null

  # @property [Date|null] last session start time, if signed in;
  #   otherwise null;
  #   will be reset to null when a session ends
  startTime: null

  # @property [Date|null] last session end time, if signed out from
  #   a previously existing session;
  #   otherwise null;
  #   will be reset to null when a session starts
  endTime:   null

  # start a session
  #
  # @param [object] object representing response payload, as `canonicalize`d
  #   by the response adapter
  start: ->
    @signedIn  = true
    @startTime = new Date()
    @endTime   = null

  # end/clear a session
  #
  # @param [object] object representing response payload, as `canonicalize`d
  #   by the response adapter
  end: ->
    @signedIn  = false
    @userId    = null
    @startTime = null
    @endTime   = new Date()

  # retrieve a variable from the session storage
  #
  # @param [string] key to the variable
  # @param [object] (opt) adapter-specific options
  #
  # @return [(any type)] the variable
  retrieve: mustImplement 'retrieve'

  # store a variable to the session storage
  #
  # @param [string] key to the variable
  # @param [(any type)] variable value
  # @param [object] (opt) adapter-specific options
  store:    mustImplement 'store'

  # remove a variable from the session storage
  #
  # @param [string] key to the variable
  # @param [object] (opt) adapter-specific options
  remove:   mustImplement 'remove'

class Em.Auth.TimeoutableAuthModule
  init: ->
    @config?          || (@config = @auth.timeoutable)
    @config.callback? || (@config.callback = => @auth.signOut())

    @auth.addHandler 'signInSuccess',  @register
    @auth.addHandler 'signInError',    @clear
    @auth.addHandler 'signOutSuccess', @clear

  # @property [Date|null] the start time of the current timeout count
  #   ! might not be same as session start time
  # @private
  _startTime: null

  # timeout the current session by config-ed callback
  timeout: ->
    return if @_startTime == null
    period = @config.period * 60 * 1000 # in ms
    return if @_startTime - new Date() < period
    @config.callback()

  # register a new timeout call
  register: ->
    @_startTime = @auth._session.startTime
    period = @config.period * 60 * 1000 # in ms
    setTimeout (=> @timeout()), period

  # reset the timeout time count
  reset: ->
    @register()
    @_startTime = new Date()

  # clear any pending timeouts
  clear: ->
    @_startTime = null

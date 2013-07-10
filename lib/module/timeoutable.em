class Em.Auth.Module.Timeoutable
  init: ->
    @config?          || (@config = @auth.timeoutable)
    @config.callback? || (@config.callback = => @auth.signOut())

  syncEvent: (name, args...) ->
    switch name
      when 'signInSuccess'  then @register()
      when 'signInError'    then @clear()
      when 'signOutSuccess' then @clear()

  timeout: ->
    return if @startTime == null
    period = @config.period * 60 * 1000 # in ms
    return if @startTime - new Date() < period
    @config.callback()

  register: ->
    @startTime = @auth._session.startTime
    period = @config.period * 60 * 1000 # in ms
    setTimeout (=> @timeout()), period

  reset: ->
    @register()
    @startTime = new Date()

  clear: ->
    @startTime = null

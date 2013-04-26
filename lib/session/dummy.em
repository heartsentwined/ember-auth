class Em.Auth.Session.Dummy
  init: ->
    @session = {}

  retrieve: (key) ->
    @get "session.#{key}"
  store: (key, value) ->
    @set "session.#{key}", value
  remove: (key) ->
    @set "session.#{key}", undefined
    delete @session[key]

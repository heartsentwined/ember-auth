class Em.Auth.Session.Dummy
  init: ->
    @session = {}

  retrieve: (key) ->
    @session[key]
  store: (key, value) ->
    @session[key] = value
  remove: (key) ->
    delete @session[key]

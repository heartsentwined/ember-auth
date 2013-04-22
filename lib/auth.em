class Em.Auth extends Em.Object with Em.Evented
  init: ->
    @registry = Em.Auth.Registry.create()

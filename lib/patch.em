class Em.Auth.Patch
  init: ->
    Em.Auth.Patch.RESTAdapter.create({ auth: this })

class Em.Auth.Module.EmberData
  init: -> @patch()

  patch: ->
    self = this
    if DS? && DS.RESTAdapter?
      DS.RESTAdapter.reopen
        ajax: (url, type, settings) ->
          super url, type, self.auth._strategy.serialize(settings || {})

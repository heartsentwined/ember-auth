class Em.Auth.Module.EmberData
  init: -> @patch()

  patch: ->
    self = this
    if DS? && DS.RESTAdapter?
      DS.RESTAdapter.reopen
        ajax: (url, type, settings) ->
          settings       ||= {}
          settings.url     = url
          settings.type    = type
          settings.context = this
          self.auth._request.send(settings)

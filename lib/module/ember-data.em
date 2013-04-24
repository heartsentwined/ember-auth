class Em.Auth.Module.EmberData
  init: -> @patch()

  patch: ->
    DS.RESTAdapter.reopen
      ajax: (url, type, settings) ->
        settings.url     = url
        settings.type    = type
        settings.context = this
        @auth.request.send(settings)

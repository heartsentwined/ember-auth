class Em.Auth.Patch.RESTAdapter
  init: ->
    DS.RESTAdapter.reopen
      ajax: (url, type, settings) ->
        settings.url     = url
        settings.type    = type
        settings.context = this
        @auth.request.send(settings)

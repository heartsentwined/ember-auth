class Em.Auth.Module.Epf
  init: -> @patch()

  patch: ->
    self = this
    if Ep? && Ep.RestAdapter?
      Ep.RestAdapter.reopen
        ajax: (url, type, settings) ->
          settings       ||= {}
          settings.url     = url
          settings.type    = type
          settings.context = this
          self.auth._request.send(settings)

class Em.Auth.Module.Epf
  init: -> @patch()

  patch: ->
    self = this
    if Ep? && Ep.RestAdapter?
      Ep.RestAdapter.reopen
        ajax: (url, type, settings) ->
          super url, type, self.auth._strategy.serialize(settings || {})

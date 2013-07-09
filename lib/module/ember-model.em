class Em.Auth.Module.EmberModel
  init: -> @patch()

  patch: ->
    self = this
    if Ember.RESTAdapter?
      Ember.RESTAdapter.reopen
        _ajax: (url, params, method) ->
          settings =
            url: url
            type: method
            dataType: 'json'
            data: params

          new Ember.RSVP.Promise (resolve, reject) ->
            settings.success = (json)  -> Ember.run null, resolve, json
            settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
            self.auth._request.send settings

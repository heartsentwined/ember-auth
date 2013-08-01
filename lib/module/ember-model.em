class Em.Auth.Module.EmberModel
  init: -> @patch()

  patch: ->
    self = this
    if Ember.RESTAdapter?
      Ember.RESTAdapter.reopen
        _ajax: (url, params, method) ->
          settings = this.ajaxSettings url, method
          new Ember.RSVP.Promise (resolve, reject) ->
            if params
              if method is "GET"
                settings.data = params
              else
                settings.contentType = "application/json; charset=utf-8"
                settings.data = JSON.stringify params
            settings.success = (json)  -> Ember.run null, resolve, json
            settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
            self.auth._request.send settings

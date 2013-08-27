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
              # settings.data needs to be an object rather than a string
              # regardless of the method. It's going to be stringified
              # in Em.Auth.Request.Jquery#send if needed.
              settings.data = params
              unless method is "GET"
                settings.contentType = "application/json; charset=utf-8"
            settings.success = (json)  -> Ember.run null, resolve, json
            settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
            self.auth._request.send settings

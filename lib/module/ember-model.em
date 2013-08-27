class Em.Auth.Module.EmberModel
  init: ->
      @config? || (@config = @auth.emberModel || {})
      @config.adapter? || (@config.adapter = 'Ember.RESTAdapter')
      @patch()

  patch: ->
    adapter = Ember.get @config.adapter
    self = this
    if adapter?
      adapter.reopen
        _ajax: (url, params, method) ->
          settings = this.ajaxSettings url, method
          new Ember.RSVP.Promise (resolve, reject) ->
            if params
              # settings.data needs to be an object rather than a string
              # regardless of the method. It's going to be stringified
              # and contentType will be set in Em.Auth.Request.Jquery#send 
              # if needed.
              settings.data = params
            settings.success = (json)  -> Ember.run null, resolve, json
            settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
            self.auth._request.send settings

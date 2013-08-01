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
              if method is "GET"
                settings.data = params
              else
                settings.contentType = "application/json; charset=utf-8"
                settings.data = JSON.stringify params
            settings.success = (json)  -> Ember.run null, resolve, json
            settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
            self.auth._request.send settings

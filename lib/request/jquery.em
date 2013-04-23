class Em.Auth.Request.Jquery
  signIn: (data = {}) ->
    async = if data.async? then data.async else true
    delete data['async'] if data.async?
    url = if data.url? then data.url else '/'
    delete data['url'] if data.url?
    @send(
      url:   url
      type:  'POST'
      data:  data
      async: async
    ).done( =>
      @auth.strategy.deserialize 'signIn', json
      @auth.trigger 'signInSuccess'
    ).fail( =>
      @auth.trigger 'signInError'
    ).always =>
      @auth.trigger 'signInComplete'

  signOut: (data = {}) ->
    async = if data.async? then data.async else true
    delete data['async'] if data.async?
    url = if data.url? then data.url else '/'
    delete data['url'] if data.url?
    @send(
      url:   url
      type:  'DELETE'
      data:  data
      async: async
    ).done( =>
      @auth.strategy.deserialize 'signOut', json
      @auth.trigger 'signOutSuccess'
    ).fail( =>
      @auth.trigger 'signOutError'
    ).always =>
      @auth.trigger 'signOutComplete'

  send: (settings = {}) ->
    def = {}
    def.dataType = 'json'

    if settings.data && !settings.contentType? && settings.type != 'GET'
      def.contentType = 'application/json; charset=utf-8'
      settings.data   = JSON.stringify(settings.data)
    settings = jQuery.extend def, settings

    jQuery.ajax(settings)
      .done( (json, status, jqxhr) =>
        @auth.json  = json
        @auth.jqxhr = jqxhr
      ).fail( (jqxhr) =>
        @auth.jqxhr = jqxhr
      ).always (jqxhr) =>
        @auth.jqxhr = jqxhr

class Em.Auth.Request.Jquery
  signIn: (opts = {}) ->
    @send(
      jQuery.extend true, { url: '/', type: 'POST' }, opts
    ).done( =>
      @auth.strategy.deserialize(json)
      @auth.trigger 'signInSuccess'
    ).fail( =>
      @auth.trigger 'signInError'
    ).always =>
      @auth.trigger 'signInComplete'

  signOut: (opts = {}) ->
    @send(
      jQuery.extend true, { url: '/', type: 'DELETE' }, opts
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

    jQuery.ajax(
      settings
    ).done( (json, status, jqxhr) =>
      @auth.json  = json
      @auth.jqxhr = jqxhr
    ).fail( (jqxhr) =>
      @auth.jqxhr = jqxhr
    ).always (jqxhr) =>
      @auth.jqxhr = jqxhr

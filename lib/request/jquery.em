class Em.Auth.Request.Jquery
  signIn: (url, opts = {}) ->
    @send(jQuery.extend true, { url: url, type: 'POST' }, opts)
    .done(   => @auth.trigger 'signInSuccess'  )
    .fail(   => @auth.trigger 'signInError'    )
    .always( => @auth.trigger 'signInComplete' )

  signOut: (url, opts = {}) ->
    @send(jQuery.extend true, { url: url, type: 'DELETE' }, opts)
    .done(   => @auth.trigger 'signOutSuccess'  )
    .fail(   => @auth.trigger 'signOutError'    )
    .always( => @auth.trigger 'signOutComplete' )

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
      @auth.strategy.deserialize(json)
      @auth.json  = json
      @auth.jqxhr = jqxhr
    ).fail( (jqxhr) =>
      @auth.jqxhr = jqxhr
    ).always (jqxhr) =>
      @auth.jqxhr = jqxhr

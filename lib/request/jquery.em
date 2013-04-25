class Em.Auth.Request.Jquery
  init: -> @inject()

  json:  null
  jqxhr: null

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

    if settings.data && !settings.contentType?
      if settings.type?.toUpperCase() != 'GET'
        def.contentType = 'application/json; charset=utf-8'
        settings.data   = JSON.stringify(settings.data)
    settings = jQuery.extend def, settings

    jQuery.ajax(
      settings
    ).done( (json, status, jqxhr) =>
      @auth.strategy.deserialize(json)
      @json  = json
      @jqxhr = jqxhr
    ).fail( (jqxhr) =>
      @jqxhr = jqxhr
    ).always (jqxhr) =>
      @jqxhr = jqxhr

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      json:  Em.computed(=> @json ).property('request.adapter.json')
      jqxhr: Em.computed(=> @jqxhr).property('request.adapter.jqxhr')

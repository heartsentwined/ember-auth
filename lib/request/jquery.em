$ = jQuery
class Em.Auth.Request.Jquery
  init: ->
    @jqxhr? || (@jqxhr = null)
    @inject()

  signIn: (url, opts = {}) ->
    @send($.extend true, { url: url, type: 'POST' }, opts)
    .done(   => @auth.trigger 'signInSuccess'  )
    .fail(   => @auth.trigger 'signInError'    )
    .always( => @auth.trigger 'signInComplete' )

  signOut: (url, opts = {}) ->
    @send($.extend true, { url: url, type: 'DELETE' }, opts)
    .done(   => @auth.trigger 'signOutSuccess'  )
    .fail(   => @auth.trigger 'signOutError'    )
    .always( => @auth.trigger 'signOutComplete' )

  send: (settings = {}) ->
    def = {}
    def.dataType = 'json'

    if settings.data && !settings.contentType?
      if settings.type? && settings.type.toUpperCase() != 'GET'
        settings.data   = JSON.stringify(settings.data)
      if settings.type?.toUpperCase() != 'GET'
        def.contentType = 'application/json; charset=utf-8'
    settings = $.extend def, settings

    $.ajax(
      settings
    ).done( (json, status, jqxhr) =>
      @auth._response.canonicalize json
      @jqxhr = jqxhr
    ).fail( (jqxhr) =>
      @auth._response.canonicalize jqxhr.responseText
      @jqxhr = jqxhr
    ).always (jqxhr) =>
      @jqxhr = jqxhr

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      jqxhr: Em.computed(=> @jqxhr).property('_request.adapter.jqxhr')

$ = jQuery
class Em.Auth.JqueryAuthRequest extends Em.Auth.AuthRequest
  init: ->
    @auth.reopen
      jqxhr: Em.computed.alias '_request.jqxhr'

  # @property [jqXHR] jqxhr of the last request
  jqxhr: null

  signIn: (url, opts) ->
    @send $.extend true, { url: url, type: 'POST' }, opts

  signOut: (url, opts) ->
    @send $.extend true, { url: url, type: 'DELETE' }, opts

  send: (opts) ->
    def = {}
    def.dataType = 'json'

    if opts.data && !opts.contentType?
      if opts.type? && opts.type.toUpperCase() != 'GET'
        opts.data = JSON.stringify opts.data
      if opts.type?.toUpperCase() != 'GET'
        def.contentType = 'application/json; charset=utf-8'
    settings = $.extend def, opts

    new Em.RSVP.Promise (resolve, reject) =>
      $.ajax(
        settings
      ).done( (json, status, jqxhr) =>
        @jqxhr = jqxhr
        resolve jqxhr.responseText
      ).fail (jqxhr) =>
        @jqxhr = jqxhr
        reject jqxhr.responseText

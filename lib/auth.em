$ = jQuery
class Em.Auth
  # @private
  _defaults: {}

  # @private
  _config: (namespace, defaults) ->
    if defaults? # setter
      for k, v of defaults
        @_defaults[namespace] ||= {}
        @_defaults[namespace][k] = v
    else # getter
      $.extend true, {}, @_defaults[namespace], @get(namespace)

  # @private
  _handlers:
    signInSuccess:  []
    signInError:    []
    signOutSuccess: []
    signOutError:   []
    sendSuccess:    []
    sendError:      []

  # @property [object] holds instances of enabled modules
  +computed modules.@each
  module: ->
    modules = {}
    for moduleName in @modules
      modules[moduleName] = @container.lookup "authModule:#{moduleName}"
    modules

  # @property [object] the request adapter instance
  +computed request
  _request:  -> @container.lookup "authRequest:#{@request}"

  # @property [object] the response adapter instance
  +computed response
  _response: -> @container.lookup "authResponse:#{@response}"

  # @property [object] the strategy adapter instance
  +computed strategy
  _strategy: -> @container.lookup "authStrategy:#{@strategy}"

  # @property [object] the session adapter instance
  +computed session
  _session:  -> @container.lookup "authSession:#{@session}"

  # send a sign in request
  #
  # @overload signIn(url, opts)
  #   @param url [string] (opt) relative url to the end point,
  #     default: auth.signInEndPoint
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #
  # @overload signIn(opts)
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #   url will default to auth.signInEndPoint
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   `canonicalize`d data object
  signIn: (url, opts) ->
    if typeof opts == 'undefined'
      opts = url
      url  = @_request.resolveUrl @signInEndPoint
    else
      url  = @_request.resolveUrl url
    opts ||= {}

    new Em.RSVP.Promise (resolve, reject) =>
      @_request.signIn(url, @_strategy.serialize(opts))
      .then( (response) =>
        data     = @_response.canonicalize response
        promises = []
        promises.push @_strategy.deserialize data
        promises.push @_session.start data
        promises.push handler(data) for handler in @_handlers.signInSuccess
        Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)
      ).fail (response) =>
        data     = @_response.canonicalize response
        promises = []
        promises.push @_strategy.deserialize data
        promises.push @_session.end data
        promises.push handler(data) for handler in @_handlers.signInError
        Em.RSVP.all(promises).then(-> reject data).fail(-> reject data)

  # send a sign out request
  #
  # @overload signOut(url, opts)
  #   @param url [string] (opt) relative url to the end point,
  #     default: auth.signOutEndPoint
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #
  # @overload signIn(opts)
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #   url will default to auth.signOutEndPoint
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   `canonicalize`d data object
  signOut: (url, opts) ->
    if typeof opts == 'undefined'
      opts = url
      url  = @_request.resolveUrl @signOutEndPoint
    else
      url  = @_request.resolveUrl url
    opts ||= {}

    new Em.RSVP.Promise (resolve, reject) =>
      @_request.signOut(url, @_strategy.serialize(opts))
      .then( (response) =>
        data     = @_response.canonicalize response
        promises = []
        promises.push @_strategy.deserialize data
        promises.push @_session.end data
        promises.push handler(data) for handler in @_handlers.signOutSuccess
        Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)
      ).fail (response) =>
        data     = @_response.canonicalize response
        promises = []
        promises.push handler(data) for handler in @_handlers.signOutError
        Em.RSVP.all(promises).then(-> reject data).fail(-> reject data)

  # send a custom request
  #
  # @overload send(url, opts)
  #   @param url [string] (opt) relative url to the end point,
  #     default: (root)
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #
  # @overload send(opts)
  #   @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #     default: {}
  #   url will default to (root)
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   raw response
  send: (url, opts) ->
    if typeof opts == 'undefined'
      opts = url
      url  = @_request.resolveUrl ''
    else
      url  = @_request.resolveUrl url
    opts ||= {}

    new Em.RSVP.Promise (resolve, reject) =>
      @_request.send(url, @_strategy.serialize(opts))
      .then( (response) =>
        promises = []
        promises.push handler(response) for handler in @_handlers.sendSuccess
        Em.RSVP.all(promises).then(-> resolve response).fail(-> reject response)
      ).fail (response) =>
        promises = []
        promises.push handler(response) for handler in @_handlers.sendError
        Em.RSVP.all(promises).then(-> reject response).fail(-> reject response)

  # create a signed in session without server request
  #
  # @param data [string|object] object representing session information,
  #   either raw string, or as `canonicalize`d by the response adapter
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   `canonicalize`d data object
  createSession: (data) ->
    new Em.RSVP.Promise (resolve, reject) =>
      data     = @_response.canonicalize data if typeof data == 'string'
      promises = []
      promises.push @_strategy.deserialize data
      promises.push @_session.start data
      promises.push handler(data) for handler in @_handlers.signInSuccess
      Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)

  # destroy any signed in session without server request
  #
  # @param data [string|object] (opt) object representing session information,
  #   either raw string, or as `canonicalize`d by the response adapter;
  #   default = {}
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   `canonicalize`d data object
  destroySession: (data = {}) ->
    new Em.RSVP.Promise (resolve, reject) =>
      data     = @_response.canonicalize data if typeof data == 'string'
      promises = []
      promises.push @_strategy.deserialize data
      promises.push @_session.end data
      promises.push handler(data) for handler in @_handlers.signOutSuccess
      Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)

  # add a handler to be fired on specified event
  #
  # @param type [string] the event type
  # @param handler [function] event handler, optionally returning a promise
  addHandler: (type, handler) ->
    # check for unrecognized handler types
    msg = "Handler type unrecognized; you passed in `#{type}`"
    Em.assert msg, @_handlers[type]?

    # check for handler being a function
    msg = 'Handler must be a function'
    Em.assert msg, typeof handler == 'function'

    @_handlers[type].pushObject handler

  # remove a handler, or all handlers, for the specified event
  #
  # @overload removeHandler(type, handler)
  #   removes the specified handler for the specified event
  #
  #   @param type [string] the event type
  #   @param handler [function] the event handler to remove
  #
  # @overload removeHandler(type)
  #   removes all handlers for the specified event
  #
  #   @param type [string] the event type
  removeHandler: (type, handler) ->
    # check for unrecognized handler types
    msg = "Handler type unrecognized; you passed in `#{type}`"
    Em.assert msg, @_handlers[type]?

    # check for handler being a function; or allow for undefined = remove all
    msg = 'Handler must be a function or omitted for removing all handlers'
    Em.assert msg, typeof handler == 'function' || typeof handler == 'undefined'

    if handler?
      @_handlers[type].removeObject handler
    else
      @_handlers[type] = []

  # @private
  _ensurePromise: (ret) ->
    if typeof ret.then == 'function'
      ret
    else
      new Em.RSVP.resolve ret

class Em.Auth
  init: ->
    for k, v of @_defaults
      if typeof v == 'object' && @get k
        for k2, v2 of v
          @set "#{k}.#{k2}", v2 unless @get "#{k}.#{k2}"
      else
        @set k, v unless @get k

  # @private
  _defaults: {}

  # @private
  _defaultConfig: (namespace, defaults) ->
    for k, v of defaults
      if namespace
        @_defaults[namespace][k] = v
      else
        @_defaults[k] = v

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

  # @private
  _initializeAdapters: ->
    for type in ['request', 'response', 'strategy', 'session']
      # allow only a string as config value
      msg    = "The `#{type}` config should be a string"
      config = @get type
      Em.assert msg, typeof config == 'string'

      # lookup the adapter
      containerType = "auth#{Em.String.classify type}"
      containerKey  = "#{containerType}:#{config}"
      adapter       = @container.lookupFactory containerKey

      baseKlass = Em.String.classify containerType
      klass     = "#{Em.String.classify config}#{baseKlass}"

      # helpful error msg if not found in container
      msg = "The requested `#{config}` #{type}Adapter cannot be found. Either name it (YourApp).#{klass}, or register it in the container under `#{containerKey}`."
      Em.assert msg, adapter

      # helpful error msg if not extending from base class
      msg = "The requested `#{config}` #{type}Adapter must extend from Ember.Auth.#{baseKlass}"
      Em.assert msg, Em.Auth[baseKlass].detect adapter

    null # suppress CS comprehension

  # @private
  _initializeModules: ->
    for moduleName in @modules
      containerKey = "authModule:#{moduleName}"
      klass        = "#{Em.String.classify moduleName}AuthModule"

      # lookup the module
      module = @container.lookupFactory containerKey

      # helpful error msg if not found in container
      msg = "The requested `#{moduleName}` module cannot be found. Either name it (YourApp).#{klass}, or register it in the container under `#{containerKey}`."
      Em.assert msg, module

    null # suppress CS comprehension

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
        Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)
      ).fail (response) =>
        promises = []
        promises.push handler(response) for handler in @_handlers.sendError
        Em.RSVP.all(promises).then(-> reject data).fail(-> reject data)

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
  #   either raw string, or as `canonicalize`d by the response adapter
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   `canonicalize`d data object
  destroySession: (data) ->
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

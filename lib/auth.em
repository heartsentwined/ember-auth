class Em.Auth
  init: ->
    @_initializeAdapters()
    @_initializeModules()

  # @private
  _handlers:
    signInSuccess:  []
    signInError:    []
    signOutSuccess: []
    signOutError:   []
    sendSuccess:    []
    sendError:      []

  # @property [object] holds instances of enabled modules
  module: {}

  # @private
  _initializeAdapters: ->
    for type in ['request', 'response', 'strategy', 'session']
      # allow only a string as config value
      msg    = "The `#{type}` config should be a string"
      config = @get type
      Em.assert msg, typeof config == 'string'

      # lookup the adapter
      containerType = "auth#{Em.string.classify type}"
      containerKey  = "#{containerType}:#{config}"
      adapter       = @container.lookup containerKey

      baseKlass = Em.string.classify containerType
      klass     = "#{Em.string.classify config}#{baseKlass}"

      # helpful error msg if not found in container
      msg = "The requested `#{config}` #{type}Adapter cannot be found. Either name it (YourApp).#{klass}, or register it in the container under `#{containerKey}`."
      Em.assert msg, adapter

      # helpful error msg if not extending from base class
      msg = "The requested `#{config}` #{type}Adapter must extend from Ember.Auth.#{baseKlass}"
      Em.assert msg, Em.Auth.get(baseKlass).detect adapter

      # initialize the adapter
      @set "_#{type}", adapter.create { auth: this }

    null # suppress CS comprehension

  # @private
  _initializeModules: ->
    for moduleName in @modules
      containerKey = "authModule:#{moduleName}"
      klass        = "#{Em.string.classify moduleName}AuthModule"

      # lookup the module
      module = @container.lookup containerKey

      # helpful error msg if not found in container
      msg = "The requested `#{config}` module cannot be found. Either name it (YourApp).#{klass}, or register it in the container under `#{containerKey}`."
      Em.assert msg, module

      # initialize the module
      @set "module.#{moduleName}", module.create { auth: this }

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
  #   `canonicalize`d data object
  send: (url, opts) ->
    if typeof opts == 'undefined'
      opts = url
      url  = @_request.resolveUrl ''
    opts ||= {}

    new Em.RSVP.Promise (resolve, reject) =>
      @_request.send(url, @_strategy.serialize(opts))
      .then( (response) =>
        promises = []
        promises.push handler(data) for handler in @_handlers.sendSuccess
        Em.RSVP.all(promises).then(-> resolve data).fail(-> reject data)
      ).fail (response) =>
        promises = []
        promises.push handler(data) for handler in @_handlers.sendError
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

  # =====================
  # Config
  # =====================

  request:  'jquery'
  response: 'json'
  strategy: 'token'
  session:  'cookie'

  # module
  modules: []

  # request
  signInEndPoint: null  # req
  signOutEndPoint: null # req
  baseUrl: null

  # session
  userModel: null

  # strategy.token
  tokenKey: null # req
  tokenIdKey: null
  tokenLocation: 'param'
  tokenHeaderKey: null

  # module.actionRedirectable
  actionRedirectable:
    signInRoute: false # or string for route name
    signOutRoute: false # ditto
    signInSmart: false
    signOutSmart: false
    signInBlacklist: [] # list of routes that should redir to fallback
    signOutBlacklist: [] # ditto

  # module.authRedirectable
  authRedirectable:
    route: null

  # module.rememberable
  rememberable:
    tokenKey: null # req
    period: 14
    autoRecall: true
    endPoint: null

  # module.timeoutable
  timeoutable:
    period: 20 # mins
    callback: null # defaults to (auth).signOut()

  # module.urlAuthenticatable
  urlAuthenticatable:
    params: [] # req, array of params to use for authentication
    endPoint: null

  # module.emberData
  emberData:
    userModel: null # string for model type, as in store.find(userModel, id)

  # module.epf
  epf:
    userModel: null # string for model type, as in session.find(userModel, id)

  # module.emberModel
  emberModel:
    userModel: null # e.g. 'App.User' (string), not App.User (the class)

$ = jQuery
class Em.Auth.UrlAuthenticatableAuthModule
  init: ->
    @config? || (@config = @auth.urlAuthenticatable)
    @patch()

  # try to authenticate user from query params
  #
  # @param queryParams [object] the query params
  # @param routeName [string] route name to redirect to after sign in
  #   most likely this should be same as the entry route, such that it just
  #   redirects back without the query params used in authentication
  # @param opts [object] (opt) jquery.ajax(settings) -style options object,
  #   default: {}
  #
  # @return [Em.RSVP.Promise]
  #   if there is no active signed in session,
  #     and if any of the params specified in config.params is found,
  #     returns the auth.signIn() promise;
  #   else returns a resolved empty promise
  authenticate: (queryParams, routeName, opts = {}) ->
    if @auth.signedIn
      return (new Em.RSVP.resolve).then => @redirect queryParams, routeName

    data  = {}
    empty = true
    for param in @config.params
      if queryParams[param]?
        data[param] = queryParams[param]
        empty = false

    if empty
      return (new Em.RSVP.resolve).then => @redirect queryParams, routeName

    opts.data = $.extend true, data, (opts.data || {})

    if @config.endPoint?
      url = @auth._request.resolveUrl @config.endPoint
      @auth.signIn(url, opts).then => @redirect queryParams, routeName
    else
      @auth.signIn(opts).then => @redirect queryParams, routeName

  # redirects to the specified route, with the query params used in
  # authentication stripped
  #
  # @param queryParams [object] the query params
  # @param routeName [string] route name to redirect to
  redirect: (queryParams, routeName) ->
    queryParams = {}
    queryParams[param] = false for param in @config.params
    @router.transitionTo transition.targetName, queryParams

  patch: ->
    self = this
    Em.Route.reopen
      beforeModel: (queryParams, transition) ->
        ret = super.apply this, arguments
        return ret unless transition?

        if typeof ret.then == 'function'
          ret.then -> self.authenticate queryParams, transition.targetName
        else
          self.authenticate queryParams, transition.targetName

Em.onLoad 'Ember.Application', (application) ->
  application.initializer
    name: 'ember-auth.url-authenticatable'
    after: 'ember-auth'

    initialize: (container, app) ->
      app.inject 'authModule:urlAuthenticatable', 'router', 'router:main'

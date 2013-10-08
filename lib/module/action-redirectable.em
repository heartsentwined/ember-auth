class Em.Auth.ActionRedirectableAuthModule
  init: ->
    @config? || (@config = @auth.actionRedirectable)

    @auth.addHandler 'signInSuccess',  @redirect
    @auth.addHandler 'signOutSuccess', @redirect

  # @property [Transition|null] a transition representing last app route state,
  #   given that the last route state is not blacklisted for sign in redirect;
  #   null otherwise
  signInRedir:  null

  # @property [Transition|null] a transition representing last app route state,
  #   given that the last route state is not blacklisted for sign out redirect;
  #   null otherwise
  signOutRedir: null

  # register a transition for redirect upon sign in / out
  #
  # @param transition [Transition] the transition to redirect to
  registerRedirect: (transition) ->
    routeName = @canonicalizeRoute transition.targetName
    unless routeName in @getBlacklist('signIn')
      @signInRedir  = transition
    unless routeName in @getBlacklist('signOut')
      @signOutRedir = transition

  # normalize 'foo.index' routes to 'foo' for comparison
  #
  # @param route [string] the route name
  #
  # @return [string] the route name, with any trailing '.index' stripped
  canonicalizeRoute: (route) ->
    return '' unless typeof route == 'string'

    endsWith = (haystack, needle) ->
      d = haystack.length - needle.length
      d >= 0 && haystack.lastIndexOf(needle) == d

    return route unless endsWith(route, '.index')
    route.substr(0, route.lastIndexOf('.index'))

  # get the sign in / out route blacklist, each route being canonicalized
  #
  # @param env [string] either 'signIn' or 'signOut'
  #
  # @return [array<string>] array of routes, each route being canonicalized
  getBlacklist: (env) ->
    return [] unless blacklist = @config["#{env}Blacklist"]
    @canonicalizeRoute route for route in blacklist

  # resolve the redirect destination for sign in / out
  #
  # @param env [string] either 'signIn' or 'signOut'
  #
  # @return [Transition|string|null]
  #   a Transition, or a string being the route name, or null (no redirect)
  resolveRedirect: (env) ->
    return null unless env in ['signIn', 'signOut'] # unknown arg

    isSmart  = @config["#{env}Smart"]
    fallback = @canonicalizeRoute @config["#{env}Route"]

    # redirect turned off
    return null     unless fallback
    # smart mode turned off, use static redirect
    return fallback unless isSmart
    # use fallback if there is no valid (non-blacklist) redir reg-ed
    return @get("#{env}Redir") || fallback

  # perform a post- sign in / out redirect
  #
  # works with the polymorphic redirect destinations from resolveRedirect(),
  # including 'no redirect'
  redirect: ->
    env = if @auth.signedIn then 'signIn' else 'signOut'
    return unless result = @resolveRedirect env
    switch typeof result
      when 'object' then result.retry()              # object = a Transition
      when 'string' then @router.transitionTo result # string = a route name

Em.onLoad 'Ember.Application', (application) ->
  application.initializer
    name: 'ember-auth.action-redirectable'
    after: 'ember-auth'

    initialize: (container, app) ->
      app.inject 'authModule:actionRedirectable', 'router', 'router:main'

      Em.Route.reopen
        beforeModel: (queryParams, transition) ->
          transition = queryParams unless transition?
          @auth.registerRedirect transition
          super.apply this, arguments

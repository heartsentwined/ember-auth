$ = jQuery
class Em.Auth.Module.ActionRedirectable
  init: ->
    @config? || (@config = @auth.actionRedirectable)

    @signInRedir?  || (@signInRedir  = null)
    @signOutRedir? || (@signOutRedir = null)
    @router?       || (@router       = null)

    @patch()

  canonicalizeRoute: (route) ->
    return '' unless typeof route == 'string'

    endsWith = (haystack, needle) ->
      d = haystack.length - needle.length
      d >= 0 && haystack.lastIndexOf(needle) == d

    return route unless endsWith(route, '.index')
    route.substr(0, route.lastIndexOf('.index'))

  getBlacklist: (env) ->
    return [] unless blacklist = @config["#{env}Blacklist"]
    @canonicalizeRoute r for r in blacklist

  # returns
  #   - object = a Transition
  #   - string as path
  #   - null otherwise (no redir plz)
  resolveRedirect: (env) ->
    return null unless env in ['signIn', 'signOut'] # unknown arg

    isSmart  = @config["#{env}Smart"]
    fallback = @canonicalizeRoute @config["#{env}Route"]

    # redirect turned off
    return null     unless fallback
    # smart mode turned off, use static redirect
    return fallback unless isSmart  # smart mode turned off, just fallback
    # use fallback if there is no valid (non-blacklist) redir reg-ed
    return @get("#{env}Redir") || fallback

  registerRedirect: (transition) ->
    routeName = @canonicalizeRoute transition.targetName
    if $.inArray(routeName, @getBlacklist('signIn')) == -1
      @signInRedir  = transition
    if $.inArray(routeName, @getBlacklist('signOut')) == -1
      @signOutRedir = transition

  +observer auth.signedIn
  redirect: ->
    env = if @auth.signedIn then 'signIn' else 'signOut'
    return unless result = @resolveRedirect env
    switch typeof result
      when 'object' then result.retry()
      when 'string' then @router.transitionTo result

  patch: ->
    self = this
    Em.Route.reopen
      init: ->
        self.router ||= @router
        super.apply this, arguments

      beforeModel: (transition) ->
        self.auth.followPromise super.apply(this, arguments), =>
          self.registerRedirect transition
          null # make sure it doesn't return any transition

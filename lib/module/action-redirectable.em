$ = jQuery
class Em.Auth.Module.ActionRedirectable
  init: ->
    @config? || (@config = @auth.actionRedirectable)

    @initPath?     || (@initPath     = null)
    @isInit?       || (@isInit       = true)
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
  #   - array of args for transitionTo & friends
  #   - string as path
  #   - null otherwise (no redir plz)
  resolveRedirect: (env) ->
    return null unless env in ['signIn', 'signOut'] # unknown arg

    isSmart   = @config["#{env}Smart"]
    fallback  = @canonicalizeRoute @config["#{env}Route"]

    # redirect turned off
    return null       unless fallback
    # smart mode turned off, use static redirect
    return [fallback] unless isSmart  # smart mode turned off, just fallback
    # the fallback would have been reg-ed when route is blacklist
    # otherwise, we won't reg it at all -> use init path
    return @get("#{env}Redir") || @initPath

  registerInitRedirect: (routeName) ->
    return unless @isInit
    routeName = @canonicalizeRoute routeName
    for env in ['signIn', 'signOut']
      # reset, we might have reg-ed rubbish in intermediate routes
      # (e.g. application)
      @set "#{env}Redir", null
      if $.inArray(routeName, @getBlacklist(env)) != -1
        @set "#{env}Redir", [@config["#{env}Route"]]

  registerRedirect: (args) ->
    routeName = @canonicalizeRoute args[0]
    @isInit   = false
    if $.inArray(routeName, @getBlacklist('signIn')) == -1
      @signInRedir  = args
    if $.inArray(routeName, @getBlacklist('signOut')) == -1
      @signOutRedir = args

  +observer auth.signedIn
  redirect: ->
    env = if @auth.signedIn then 'signIn' else 'signOut'
    return unless result = @resolveRedirect env
    switch typeof result
      when 'object' then @router.transitionTo.apply this, result
      when 'string'
        @router.location.setURL result
        @router.handleURL result

  patch: ->
    self = this
    Em.Route.reopen
      # init hook doesn't have @routeName yet
      activate: ->
        self.router ||= @router
        self.registerInitRedirect @routeName

    Em.Router.reopen # transitionTo & friends might not originate from route
      init: ->
        super.apply this, arguments
        self.initPath ||= @location.getURL() # test this? TODO
      transitionTo: ->
        args = Array::slice.call arguments
        self.registerRedirect args
        super.apply this, args
      replaceWith: ->
        args = Array::slice.call arguments
        self.registerRedirect args
        super.apply this, args

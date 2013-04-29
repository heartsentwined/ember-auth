describe 'Em.Auth.Module.ActionRedirectable', ->
  auth        = null
  spy         = null
  actionRedir = null

  beforeEach ->
    auth = authTest.create { modules: ['actionRedirectable'] }
    actionRedir = auth.module.actionRedirectable
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#canonicalizeRoute', ->
    it 'strips .index from routes', ->
      expect(actionRedir.canonicalizeRoute('foo.index')).toEqual 'foo'

    it 'works for routes without .index', ->
      expect(actionRedir.canonicalizeRoute('foo')).toEqual 'foo'

    it 'catches non-string arguments and return empty string', ->
      expect(actionRedir.canonicalizeRoute(null)).toEqual ''

  example 'get blacklist', (env) ->
    beforeEach ->
      Em.run -> auth.set "actionRedirectable#{env}Blacklist", ['foo', 'bar']

    it "returns #{env} blacklist config", ->
      expect(actionRedir.getBlacklist(env)).toEqual ['foo', 'bar']

    it 'runs each route through #canonicalizeRoute', ->
      spy = sinon.collection.spy actionRedir, 'canonicalizeRoute'
      actionRedir.getBlacklist(env)
      expect(spy).toHaveBeenCalledWithExactly('foo')
      expect(spy).toHaveBeenCalledWithExactly('bar')

  describe '#getBlacklist', ->
    describe 'signIn',  -> follow 'get blacklist', 'signIn'
    describe 'signOut', -> follow 'get blacklist', 'signOut'

  example 'resolve redirect', (env) ->
    klass = Em.String.classify env

    describe 'redirect turned off', ->
      beforeEach ->
        Em.run -> auth.set "actionRedirectable#{klass}Route", false

      it 'returns null', ->
        expect(actionRedir.resolveRedirect(env)).toBeNull()

    describe 'redirect turned on', ->
      beforeEach ->
        Em.run -> auth.set "actionRedirectable#{klass}Route", 'foo'

      describe 'smart turned off', ->
        beforeEach ->
          Em.run -> auth.set "actionRedirectable#{klass}Smart", false

        it 'returns fallback route', ->
          expect(actionRedir.resolveRedirect(env)).toEqual ['foo']

      describe 'smart turned on', ->
        beforeEach ->
          Em.run ->
            auth.set "actionRedirectable#{klass}Smart", true
            actionRedir.initPath = 'foo'

        describe 'redirect route registered', ->
          beforeEach -> Em.run -> actionRedir.set "#{env}Redir", ['foo']

          it 'returns registered redirect route', ->
            expect(actionRedir.resolveRedirect(env)).toEqual ['foo']

        describe 'no redirect route registered', ->
          beforeEach -> Em.run -> actionRedir.set "#{env}Redir", null

          it 'returns init path', ->
            expect(actionRedir.resolveRedirect(env)).toEqual 'foo'

  describe '#resolveRedirect', ->
    describe 'signIn',  -> follow 'resolve redirect', 'signIn'
    describe 'signOut', -> follow 'resolve redirect', 'signOut'

    it 'returns null for unrecognized env', ->
        expect(actionRedir.resolveRedirect('foo')).toBeNull()

  describe '#registerInitRedirect', ->

    describe 'isInit = false', ->
      beforeEach -> Em.run -> actionRedir.isInit = false

      it 'does nothing', ->
        spy = sinon.collection.spy actionRedir, 'set'
        actionRedir.registerInitRedirect 'foo'
        expect(spy).not.toHaveBeenCalled()

    describe 'isInit = true', ->
      beforeEach ->
        Em.run ->
          actionRedir.isInit = true
          # sham values. to test set-to-null where applicable
          actionRedir.signInRoute  = 'dummy'
          actionRedir.signOutRoute = 'dummy'

      it 'runs given route through #canonicalizeRoute', ->
        spy = sinon.collection.spy actionRedir, 'canonicalizeRoute'
        actionRedir.registerInitRedirect 'foo'
        expect(spy).toHaveBeenCalledWithExactly 'foo'

      example 'init redirect reg', (env) ->
        beforeEach ->
          klass = Em.String.classify env
          Em.run -> auth.set "actionRedirectable#{klass}Route", 'fallback'

        describe 'route in blacklist', ->
          it 'registers fallback route', ->
            sinon.collection.stub actionRedir, 'getBlacklist', \
            (arg) -> ["#{arg}-foo"]
            Em.run -> actionRedir.registerInitRedirect "#{env}-foo"
            expect(actionRedir.get "#{env}Redir").toEqual ['fallback']

        describe 'route not in blacklist', ->
          it 'registers nothing', ->
            sinon.collection.stub actionRedir, 'getBlacklist', -> []
            Em.run -> actionRedir.registerInitRedirect "#{env}-foo"
            expect(actionRedir.get "#{env}Redir").toEqual null

      follow 'init redirect reg', 'signIn'
      follow 'init redirect reg', 'signOut'

  describe '#registerRedirect', ->

    it 'flags as no longer init', ->
      Em.run -> actionRedir.isInit = true # give something for it to reset
      Em.run -> actionRedir.registerRedirect ['foo']
      expect(actionRedir.isInit).toEqual false

    it 'runs given route through #canonicalizeRoute', ->
      spy = sinon.collection.spy actionRedir, 'canonicalizeRoute'
      actionRedir.registerRedirect ['foo', 'bar']
      expect(spy).toHaveBeenCalledWithExactly 'foo'

    example 'redirect reg', (env) ->
      describe 'route in blacklist', ->
        it 'registers nothing', ->
          sinon.collection.stub actionRedir, 'getBlacklist', \
          (arg) -> ["#{arg}-foo"]
          Em.run -> actionRedir.registerRedirect ["#{env}-foo", 'bar']
          expect(actionRedir.get "#{env}Redir").toEqual null

      describe 'route not in blacklist', ->
        it 'registers route with args', ->
          sinon.collection.stub actionRedir, 'getBlacklist', -> []
          Em.run -> actionRedir.registerRedirect ["#{env}-foo", 'bar']
          expect(actionRedir.get "#{env}Redir").toEqual ["#{env}-foo", 'bar']

    follow 'redirect reg', 'signIn'
    follow 'redirect reg', 'signOut'

  describe '#redirect', ->

    describe 'sign in / sign out integration', ->
      beforeEach ->
        spy = sinon.collection.stub actionRedir, 'resolveRedirect', -> null

      describe 'on sign in', ->
        beforeEach -> Em.run -> auth._session.start()

        it 'delegates to #resolveRedirect', ->
          expect(spy).toHaveBeenCalledWithExactly 'signIn'

      describe 'on sign out', ->
        beforeEach ->
          Em.run ->
            auth._session.start() # need to sign in first to trigger change
            auth._session.clear()

        it 'delegates to #resolveRedirect', ->
          expect(spy).toHaveBeenCalledWithExactly 'signOut'

    describe 'redirect integration', ->
      beforeEach ->
        appTest.create (app) ->
          app.Auth = Em.Auth.create { modules: ['actionRedirectable'] }
          app.Router.map -> @route 'foo', { path: '/foo/:foo_id' }
          app.FooRoute = Em.Route.extend
            model: (params) -> app.Foo.find(params.foo_id)
          app.Foo = { find: (arg) -> Em.Object.create { _id: arg } }
          actionRedir = app.Auth.module.actionRedirectable
      afterEach ->
        appTest.destroy()

      it 'supports redirect by transition', ->
        appTest.run (app) ->
          sinon.collection.stub actionRedir, 'resolveRedirect', \
          -> ['foo', app.Foo.find(1)]
        appTest.ready()
        Em.run -> actionRedir.redirect()
        expect(appTest.currentPath()).toEqual 'foo'

      it 'supports redirect by path', ->
        sinon.collection.stub actionRedir, 'resolveRedirect', -> '/foo/1'
        appTest.ready()
        Em.run -> actionRedir.redirect()
        expect(appTest.currentPath()).toEqual 'foo'

  describe 'patch', ->
    beforeEach ->
      appTest.create (app) ->
        app.Auth = Em.Auth.create { modules: ['actionRedirectable'] }
        actionRedir = app.Auth.module.actionRedirectable
    afterEach ->
      appTest.destroy()

    describe 'on any route activation', ->
      beforeEach ->
        appTest.run (app) ->
          app.Router.map -> @route 'foo'
          app.FooRoute = Em.Route.extend()

      it 'registers router instance', ->
        expect(actionRedir.router).toBeNull()
        appTest.ready()
        appTest.toRoute 'foo'
        expect(actionRedir.router).not.toBeNull()

      it 'registers init redirect', ->
        spy = sinon.collection.spy actionRedir, 'registerInitRedirect'
        appTest.ready()
        appTest.toRoute 'foo'
        expect(spy).toHaveBeenCalledWithExactly 'foo'

    example 'redirect reg integration', (route, transitionArgs) ->
      it 'delegates to #registerInitRedirect on route activation', ->
        spy = sinon.collection.spy actionRedir, 'registerInitRedirect'
        appTest.ready()
        appTest.toRoute.apply appTest, transitionArgs
        expect(spy).toHaveBeenCalledWithExactly route

      it 'delegates to #registerRedirect on route transitionTo', ->
        spy = sinon.collection.spy actionRedir, 'registerRedirect'
        appTest.ready()
        appTest.router().transitionTo.apply appTest.router(), transitionArgs
        expect(spy).toHaveBeenCalledWithExactly transitionArgs

      it 'delegates to #registerRedirect on route replaceWith', ->
        spy = sinon.collection.spy actionRedir, 'registerRedirect'
        appTest.ready()
        appTest.router().replaceWith.apply appTest.router(), transitionArgs
        expect(spy).toHaveBeenCalledWithExactly transitionArgs

    describe 'redirect registration', ->
      describe 'static route', ->
        beforeEach ->
          appTest.run (app) ->
            app.Router.map -> @route 'static'
            app.StaticRoute = Em.Route.extend()

        follow 'redirect reg integration', 'static', ['static']

      describe 'dynamic route', ->
        beforeEach ->
          appTest.run (app) ->
            app.Router.map -> @route 'dynamic', { path: '/dynamic/:segment' }
            app.DynamicRoute = Em.Route.extend()

        follow 'redirect reg integration', 'dynamic', ['dynamic', 'foo']

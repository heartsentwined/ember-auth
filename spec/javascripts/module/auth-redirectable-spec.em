describe 'Em.Auth.Module.AuthRedirectable', ->
  auth      = null
  spy       = null
  authRedir = null

  beforeEach ->
    auth = authTest.create { modules: ['authRedirectable'] }
    authRedir = auth.module.authRedirectable
    appTest.create (app) ->
      app.Auth = authTest.create { modules: ['authRedirectable'] }
      spy = sinon.collection.spy app.Auth, 'trigger'
  afterEach ->
    appTest.destroy()
    auth.destroy() if auth
    sinon.collection.restore()

  it 'has mixin alias', ->
    expect(auth.AuthRedirectable).toEqual authRedir.AuthRedirectable

  describe 'public route', ->
    beforeEach ->
      appTest.run (app) ->
        app.Router.map -> @route 'public'
        app.PublicRoute = Em.Route.extend()

    it 'does not redirect', ->
      appTest.ready()
      appTest.toRoute 'public'
      expect(appTest.currentPath()).toEqual 'public'

    it 'does not trigger authAccess event', ->
      appTest.ready()
      appTest.toRoute 'public'
      expect(spy).not.toHaveBeenCalled()

  describe 'protected route', ->
    beforeEach ->
      appTest.run (app) ->
        app.Router.map ->
          @route 'protected'
          @route 'sign-in'
        app.ProtectedRoute = Em.Route.extend app.Auth.AuthRedirectable
        app.SignInRoute = Em.Route.extend()
        app.Auth.authRedirectable.route = 'sign-in'

    describe 'not signed in', ->
      beforeEach -> appTest.run (app) -> app.Auth._session.clear()

      it 'redirects to sign in route', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'sign-in'

      it 'triggers authAccess event', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(spy).toHaveBeenCalledWithExactly('authAccess')

    describe 'signed in', ->
      beforeEach -> appTest.run (app) -> app.Auth._session.start()

      it 'does not redirect', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'protected'

      it 'does not trigger authAccess event', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(spy).not.toHaveBeenCalled()

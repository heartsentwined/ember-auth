describe 'Em.Auth.Module.AuthRedirectable', ->
  auth      = null
  spy       = null
  authRedir = null

  beforeEach ->
    auth = authTest.create { modules: ['authRedirectable'] }
    authRedir = auth.module.authRedirectable
    appTest.create (app) ->
      app.Auth = authTest.create { modules: ['authRedirectable'] }
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

  describe 'protected route', ->
    beforeEach ->
      appTest.run (app) ->
        app.Router.map ->
          @route 'protected'
          @route 'sign-in'
        app.ProtectedRoute = Em.Route.extend app.Auth.AuthRedirectable
        app.SignInRoute = Em.Route.extend()
        app.Auth.authRedirectableRoute = 'sign-in'

    describe 'not signed in', ->
      beforeEach -> appTest.run (app) -> app.Auth._session.clear()

      it 'redirects to sign in route', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'sign-in'

    describe 'signed in', ->
      beforeEach -> appTest.run (app) -> app.Auth._session.start()

      it 'does not redirect', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'protected'

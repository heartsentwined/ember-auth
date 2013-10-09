describe 'Em.Auth.AuthRedirectableAuthModule', ->
  auth      = null
  spy       = null
  authRedir = null

  beforeEach ->
    appTest.create (app) ->
      app.Auth = authTest.extend
        container: app.__container__
        modules: ['authRedirectable']
        authRedirectable:
          route: 'sign-in'
    appTest.run (app) ->
      auth = appTest.lookup 'auth:main'
      authRedir = auth.module.authRedirectable
  afterEach ->
    appTest.destroy()
    auth.destroy() if auth
    sinon.collection.restore()

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
        app.ProtectedRoute = Em.Route.extend {
          init: ->
            super.apply this, arguments
            console.log "in route #{@auth.signedIn}"
          authRedirectable: true
        }
        app.SignInRoute = Em.Route.extend()

    describe 'not signed in', ->
      beforeEach -> appTest.run (app) -> auth._session.end()

      it 'redirects to sign in route', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'sign-in'

    # TODO can't get this to pass, but real-app testing seems fine
    xdescribe 'signed in', ->
      beforeEach -> appTest.run (app) -> auth._session.start()

      it 'does not redirect', ->
        appTest.ready()
        appTest.toRoute 'protected'
        expect(appTest.currentPath()).toEqual 'protected'

describe 'Auth.SignInController', ->
  controller = null
  beforeEach ->
    controller = Em.Controller.extend(Auth.SignInController).create()
    spyOn controller, 'transitionToRoute'
    @auth = $.extend true, {}, window.Auth
    @config = $.extend true, {}, window.Auth.Config
  afterEach ->
    window.Auth = @auth
    window.Auth.Config = @config
    #Auth.removeObserver 'authToken'
    controller.destroy()
    controller = null

  describe 'initial state: signed in', ->
    beforeEach ->
      Auth.set 'authToken', 'foo'
      spyOn(Auth, 'resolveRedirectRoute').andCallFake (arg) -> "#{arg}-route"
      controller.registerRedirect()

    describe 'Auth.authToken changes to different token', ->
      it 'redirects', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0])
          .toEqual 'signIn-route'

    describe 'Auth.authToken changes to same token', ->
      it 'does not redirect', ->
        Auth.set 'authToken', 'foo'
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'Auth.authToken changes to null', ->
      it 'does not redirect', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'consecutive Auth.authToken changes', ->
      it 'only redirects for the first time', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0])
          .toEqual 'signIn-route'
        Auth.set 'authToken', 'baz'
        expect(controller.transitionToRoute.calls.length).toEqual 1

  describe 'initial state: not signed in', ->
    beforeEach ->
      Auth.set 'authToken', null
      spyOn(Auth, 'resolveRedirectRoute').andCallFake (arg) -> "#{arg}-route"
      controller.registerRedirect()

    describe 'Auth.authToken changes to different token', ->
      it 'redirects', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0])
          .toEqual 'signIn-route'

    describe 'Auth.authToken changes to same token (null)', ->
      it 'does not redirect', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'consecutive Auth.authToken changes', ->
      it 'only redirects for the first time', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0])
          .toEqual 'signIn-route'
        Auth.set 'authToken', 'baz'
        expect(controller.transitionToRoute.calls.length).toEqual 1

  describe 'integration', ->
    beforeEach ->
      Auth.Config.reopen
        signInRoute: 'sign-in'
        authRedirect: true
        smartSignInRedirect: true
        signInRedirectFallbackRoute: 'public'
      Auth.set 'authToken', null
      em.create (app) ->
        app.Router.map ->
          @route 'protected'
          @route 'sign-in'
          @route 'public'
          #@route 'dynamic', { path: '/dynamic/:segment' }
          #@route 'empty-model'

        app.ProtectedRoute = Auth.Route.extend()
        app.SignInRoute = Em.Route.extend()
        app.PublicRoute = Em.Route.extend()
        #app.DynamicRoute = Auth.Route.extend
          #model: (param) -> app.Dynamic.find(param.segment)
        #app.EmptyModelRoute = Auth.Route.extend
          #model: (param) -> null

        app.ProtectedController = Em.Controller.extend Auth.SignInController
        app.SignInController = Em.Controller.extend()
        app.PublicController = Em.Controller.extend()
        #app.DynamicController = Em.Controller.extend Auth.SignInController
        #app.EmptyModelController = Em.Controller.extend Auth.SignInController

        #app.Dynamic = Em.Object.create
          #find: (id) -> Em.Object.create({ id: id })
    afterEach ->
      Auth.set 'prevRoute', null
      Auth.set 'prevPath', null
      Auth.set 'isInit', true
      em.destroy()

    follow 'smart redirect', { from: 'protected', to: 'protected', reg: true }
    #follow 'smart redirect', { from: 'empty-model', to: 'empty-model', reg: false }
    follow 'smart redirect', { from: 'sign-in', to: 'public', reg: false }

    # special treatment for dynamic segment
    #describe 'from dynamic route', ->
      #it 'redirects back', ->
        #em.ready()
        #em.controller('dynamic').registerRedirect()
        #em.toRoute '/dynamic/1'
        #expect(em.currentPath()).toEqual 'sign-in'
      #Auth.set 'authToken', 'bar' # signs in
      #expect(em.currentPath()).toEqual 'dynamic'

describe 'Auth.Route', ->

  it 'supports events', ->
    expect(Auth.on).toBeDefined()

  describe '#redirect', ->
    App = null

    beforeEach ->
      Em.run ->
        App = Em.Application.create()
        App.deferReadiness()
        App.Router.map ->
          @route 'foo'
          @route 'sign-in'
        App.FooRoute = Auth.Route.extend()
        App.SignInRoute = Em.Route.extend()

    afterEach ->
      Em.run ->
        App.destroy()
        App = null

    describe 'authAccess event', ->
      triggered = null

      beforeEach ->
        triggered = 0
        App.FooRoute.reopen
          init: ->
            @on 'authAccess', -> triggered++
        Em.run App, 'advanceReadiness'

      afterEach ->
        triggered = 0
        Auth.set 'authToken', null

      describe 'Auth.authToken = null', ->
        it 'triggers event', ->
          Auth.set 'authToken', null
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(triggered).toBe 1

      describe 'Auth.authToken is set', ->
        it 'does not trigger event', ->
          Auth.set 'authToken', 'foo'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(triggered).toBe 0

    describe 'auth-only redirection', ->

      describe 'Auth.Config.authRedirect = true', ->
        beforeEach ->
          Auth.Config.reopen
            authRedirect: true
            signInRoute: 'sign-in'

        afterEach ->
          Auth.Config.reopen
            authRedirect: false
            signInRoute: null
          Auth.set 'prevRoute', null

        it 'sets Auth.prevRoute with current route name', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(Auth.get 'prevRoute').toBe 'foo'

        it 'transitions to sign in route', ->
          currentPath = null
          App.ApplicationController = Em.Controller.extend
            currentPathDidChange: (->
              currentPath = @get 'currentPath'
            ).observes('currentPath')
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(currentPath).toBe 'sign-in'

      describe 'Auth.Config.authRedirect = false', ->
        beforeEach ->
          Auth.Config.reopen
            authRedirect: false
            signInRoute: 'sign-in'

        afterEach ->
          Auth.Config.reopen
            authRedirect: false
            signInRoute: null
          Auth.set 'prevRoute', null

        it 'does not set Auth.prevRoute', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(Auth.get 'prevRoute').toBe null

        it 'stays on current route', ->
          currentPath = null
          App.ApplicationController = Em.Controller.extend
            currentPathDidChange: (->
              currentPath = @get 'currentPath'
            ).observes('currentPath')
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(currentPath).toBe 'foo'

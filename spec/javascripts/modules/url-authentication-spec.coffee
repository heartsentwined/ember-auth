describe 'Auth.Module.UrlAuthentication', ->
  beforeEach ->
    Auth.Config.reopen { urlAuthentication: true }
  afterEach ->
    Auth.Config.reopen { urlAuthentication: false }
    Auth.set 'authToken', null

  describe '#retrieveToken', ->

    it 'removes trailing slash', ->
      spyOn(jQuery, 'url').andReturn { param: -> 'foo/' }
      expect(Auth.Module.UrlAuthentication.retrieveToken()).toEqual 'foo'

    it 'works with params without trailing slash', ->
      spyOn(jQuery, 'url').andReturn { param: -> 'foo' }
      expect(Auth.Module.UrlAuthentication.retrieveToken()).toEqual 'foo'

  describe '#authenticate', ->
    beforeEach -> spyOn Auth, 'signIn'

    describe 'supports async option', ->
      beforeEach ->
        Auth.set 'authToken', null
        spyOn(Auth.Module.UrlAuthentication, 'retrieveToken').andReturn 'foo'

      describe '= true', ->
        it 'sets async option', ->
          Auth.Module.UrlAuthentication.authenticate async: true
          expect(Auth.signIn.calls[0].args[0].async).toEqual true

      describe '= false', ->
        it 'sets async option', ->
          Auth.Module.UrlAuthentication.authenticate async: false
          expect(Auth.signIn.calls[0].args[0].async).toEqual false

      describe 'undefined', ->
        it 'does not set async option', ->
          Auth.Module.UrlAuthentication.authenticate()
          expect(Auth.signIn.calls[0].args[0].async).toBeUndefined()

    describe 'Auth.Config.urlAuthenticate = false', ->
      beforeEach -> Auth.Config.reopen { urlAuthenticate: false }
      follow 'url authentication - authenticate - no sign in'

    describe 'Auth.authToken present', ->
      beforeEach -> Auth.set 'authToken', 'foo'
      follow 'url authentication - authenticate - no sign in'

    describe 'retrieveToken fails', ->
      beforeEach ->
        spyOn(Auth.Module.UrlAuthentication, 'retrieveToken').andReturn null
      follow 'url authentication - authenticate - no sign in'

    describe 'Auth.Config.urlAuthentication = true', ->
      beforeEach -> Auth.Config.reopen { urlAuthentication: true }

      describe 'Auth.authToken absent', ->
        beforeEach -> Auth.set 'authToken', null

        describe 'retrieveToken succeeds', ->
          beforeEach ->
            spyOn(Auth.Module.UrlAuthentication, 'retrieveToken').andReturn 'foo'

          it 'attempts a sign in', ->
            Auth.Config.reopen { tokenKey: 'auth_key' }
            Auth.Module.UrlAuthentication.authenticate()
            expect(Auth.signIn.calls[0].args[0]).toEqual { auth_key: 'foo' }

  describe 'auto recall session', ->
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
      spyOn(Auth.Module.UrlAuthentication, 'authenticate').andCallThrough()
    afterEach ->
      Em.run ->
        App.destroy()
        App = null

    describe 'Auth.Config.urlAuthentication = false', ->
      beforeEach ->
        Auth.Config.reopen { urlAuthentication: false }
        Auth.set 'authToken', null

      it 'does not attempt to auto recall session', ->
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(Auth.Module.UrlAuthentication.authenticate).not.toHaveBeenCalled()

      it 'preserves Auth.Route functionalities', ->
        triggered = 0
        App.FooRoute.reopen
          init: ->
            @on 'authAccess', -> triggered++
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(triggered).toEqual 1

    describe 'Auth.Config.urlAuthentication = true', ->
      beforeEach ->
        Auth.Config.reopen
          tokenCreateUrl: '/api/sign-in'
          tokenDestroyUrl: '/api/sign-out'
          tokenKey: 'auth_key'
          idKey: 'user_id'
          urlAuthentication: true
        Auth.set 'authToken', null
        spyOn(Auth.Module.UrlAuthentication, 'retrieveToken').andReturn 'bar'

      afterEach ->
        Auth.Config.reopen
          tokenCreateUrl: null
          tokenDestroyUrl: null
          tokenKey: null
          idKey: null
          urlAuthentication: false
        $.mockjaxClear()

      describe 'JSON response', ->

        describe 'success', ->
          beforeEach ->
            $.mockjax
              url: '/api/sign-in'
              type: 'post'
              data: JSON.stringify { auth_key: 'bar' }
              status: 201
              responseText: { auth_key: 'foo', user_id: 1 }

          it 'recalls session', ->
            Em.run App, 'advanceReadiness'
            Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
            expect(Auth.Module.UrlAuthentication.authenticate.calls[0].args[0])
              .toEqual { async: false }
            expect(Auth.get 'authToken').toEqual 'foo'

          it 'prevents redirect', ->
            currentPath = null
            App.ApplicationController = Em.Controller.extend
              currentPathDidChange: (->
                currentPath = @get 'currentPath'
              ).observes('currentPath')
            Em.run App, 'advanceReadiness'
            Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
            expect(currentPath).toEqual 'foo'

          # nothing would have been done, cannot test
          #it 'preserves Auth.Route functionalities', ->

        describe 'failure', ->
          beforeEach ->
            $.mockjax
              url: '/api/sign-in'
              type: 'post'
              data: { auth_key: 'bar' }
              status: 401
              responseText: ''

          it 'fails to recall session', ->
            Em.run App, 'advanceReadiness'
            Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
            expect(Auth.Module.UrlAuthentication.authenticate.calls[0].args[0])
              .toEqual { async: false }
            expect(Auth.get 'authToken').toEqual null

          it 'preserves Auth.Route functionalities', ->
            triggered = 0
            App.FooRoute.reopen
              init: ->
                @on 'authAccess', -> triggered++
            Em.run App, 'advanceReadiness'
            Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
            expect(triggered).toEqual 1

          describe 'Auth.Route redirection', ->
            beforeEach ->
              Auth.Config.reopen
                authRedirect: true
                signInRoute: 'sign-in'

            afterEach ->
              Auth.Config.reopen
                authRedirect: false
                signInRoute: null

            it 'is preserved', ->
              currentPath = null
              App.ApplicationController = Em.Controller.extend
                currentPathDidChange: (->
                  currentPath = @get 'currentPath'
                ).observes('currentPath')
              Em.run App, 'advanceReadiness'
              Em.run -> App.__container__.lookup('router:main')
                .handleURL 'foo'
              expect(currentPath).toEqual 'sign-in'

      # TODO
      #describe 'JSONP response', ->

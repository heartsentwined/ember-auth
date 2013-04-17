describe 'Auth.Module.UrlAuthentication', ->
  beforeEach ->
    Auth.Config.reopen { urlAuthentication: true }
  afterEach ->
    Auth.Config.reopen
      urlAuthentication: false
      urlAuthenticationParamsKey: null
    Auth.set 'authToken', null
    Auth.Module.UrlAuthentication.params = null

  describe '#retrieveParams', ->
    # how to test for different Router location settings? 'history', 'hash'

    describe 'Auth.Config.urlAuthentication = false', ->
      beforeEach -> Auth.Config.reopen { urlAuthentication: false }
      it 'does nothing', ->
        Auth.Module.UrlAuthentication.retrieveParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual null

    describe 'Auth.Config.urlAuthentication = true', ->
      beforeEach -> Auth.Config.reopen
        urlAuthentication: true
        urlAuthenticationParamsKey: 'foo'

      it 'retrieves param at Auth.Config.urlAuthenticationParamsKey', ->
        spyOn(jQuery, 'url').andReturn { param: -> { bar: 'baz' } }
        Auth.Module.UrlAuthentication.retrieveParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { bar: 'baz' }

      it 'works for empty values', ->
        spyOn(jQuery, 'url').andReturn { param: -> {} }
        Auth.Module.UrlAuthentication.retrieveParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual {}

  describe '#canonicalizeParams', ->

    describe 'null', ->
      it 'wraps to empty object', ->
        Auth.Module.UrlAuthentication.params = null
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual {}

    describe 'undefined', ->
      it 'wraps to empty object', ->
        Auth.Module.UrlAuthentication.params = undefined
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual {}

    describe 'primitive', ->
      it 'wraps to one-member object', ->
        Auth.Module.UrlAuthentication.params = 'foo'
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { foo: 'foo' }

      it 'removes trialing slash, if any', ->
        Auth.Module.UrlAuthentication.params = 'foo/'
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { foo: 'foo' }

    describe 'array', ->
      it 'wraps to object with array indices as keys', ->
        Auth.Module.UrlAuthentication.params = [1,2]
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { 0: '1', 1: '2' }

      it 'removes trialing slash, if any', ->
        Auth.Module.UrlAuthentication.params = ['a/','b']
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { 0: 'a', 1: 'b' }

    describe 'empty object', ->
      it 'does nothing', ->
        Auth.Module.UrlAuthentication.params = {}
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual {}

    describe 'simple object', ->
      it 'removes trailing slash, if any', ->
        Auth.Module.UrlAuthentication.params = { foo: 'foo' }
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { foo: 'foo' }
        Auth.Module.UrlAuthentication.params = { foo: 'foo/' }
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual { foo: 'foo' }

    describe 'deep object', ->
      it 'removes trailing slash, if any', ->
        Auth.Module.UrlAuthentication.params =
          a: { b: 'b/', c: 'c' }
          d: 'd/'
        Auth.Module.UrlAuthentication.canonicalizeParams()
        expect(Auth.Module.UrlAuthentication.params).toEqual
          a: { b: 'b', c: 'c' }
          d: 'd'

  describe '#authenticate', ->
    beforeEach -> spyOn Auth, 'signIn'

    describe 'supports async option', ->
      beforeEach ->
        Auth.set 'authToken', null
        Auth.Module.UrlAuthentication.params = { foo: 'bar' }

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

    describe 'params is empty', ->
      beforeEach -> Auth.Module.UrlAuthentication.params = {}
      follow 'url authentication - authenticate - no sign in'

    describe 'Auth.Config.urlAuthentication = true', ->
      beforeEach -> Auth.Config.reopen { urlAuthentication: true }

      describe 'Auth.authToken absent', ->
        beforeEach -> Auth.set 'authToken', null

        describe 'params is not empty', ->
          beforeEach -> Auth.Module.UrlAuthentication.params = { foo: 'bar' }

          it 'attempts a sign in', ->
            Auth.Config.reopen { urlAuthenticationParamsKey: 'auth_key' }
            Auth.Module.UrlAuthentication.authenticate()
            expect(Auth.signIn.calls[0].args[0]).toEqual
              auth_key: { foo: 'bar' }

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

    describe 'route scope', ->
      beforeEach ->
        Auth.Config.reopen { urlAuthentication: true }

      describe 'Auth.Config.urlAuthenticationRouteScope = auth', ->
        beforeEach -> Auth.Config.reopen
          urlAuthenticationRouteScope: 'auth'

        it 'attempts to auto recall session for Auth.Route', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(Auth.Module.UrlAuthentication.authenticate).toHaveBeenCalled()

        it 'does not attempt to auto recall session for Em.Route', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'sign-in'
          expect(Auth.Module.UrlAuthentication.authenticate).not.toHaveBeenCalled()

      describe 'Auth.Config.urlAuthenticationRouteScope = both', ->
        beforeEach -> Auth.Config.reopen
          urlAuthenticationRouteScope: 'both'

        it 'attempts to auto recall session for Auth.Route', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
          expect(Auth.Module.UrlAuthentication.authenticate).toHaveBeenCalled()

        it 'does not attempt to auto recall session for Em.Route', ->
          Em.run App, 'advanceReadiness'
          Em.run -> App.__container__.lookup('router:main').handleURL 'sign-in'
          expect(Auth.Module.UrlAuthentication.authenticate).toHaveBeenCalled()

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
          urlAuthenticationParamsKey: 'auth_key'
        Auth.set 'authToken', null

      afterEach ->
        Auth.Config.reopen
          tokenCreateUrl: null
          tokenDestroyUrl: null
          tokenKey: null
          idKey: null
          urlAuthentication: false
          urlAuthenticationParamsKey: null
        $.mockjaxClear()
        Auth.Module.UrlAuthentication.params = null

      describe 'JSON response', ->

        describe 'success', ->
          beforeEach ->
            $.mockjax
              url: '/api/sign-in'
              type: 'post'
              data: JSON.stringify { auth_key: { foo: 'bar' } }
              status: 201
              responseText: { auth_key: 'foo', user_id: 1 }

          it 'recalls session', ->
            Em.run App, 'advanceReadiness'
            Auth.Module.UrlAuthentication.params = { foo: 'bar' }
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
            Auth.Module.UrlAuthentication.params = { foo: 'bar' }
            Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
            expect(currentPath).toEqual 'foo'

          # nothing would have been done, cannot test
          #it 'preserves Auth.Route functionalities', ->

        describe 'failure', ->
          beforeEach ->
            $.mockjax
              url: '/api/sign-in'
              type: 'post'
              data: JSON.stringify { auth_key: { foo: 'bar' } }
              status: 401
              responseText: ''

          it 'fails to recall session', ->
            Em.run App, 'advanceReadiness'
            Auth.Module.UrlAuthentication.params = { foo: 'bar' }
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
            Auth.Module.UrlAuthentication.params = { foo: 'bar' }
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
              Auth.Module.UrlAuthentication.params = { foo: 'bar' }
              Em.run -> App.__container__.lookup('router:main')
                .handleURL 'foo'
              expect(currentPath).toEqual 'sign-in'

      # TODO
      #describe 'JSONP response', ->

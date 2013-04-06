describe 'Auth.Module.RememberMe', ->
  beforeEach ->
    Auth.Config.reopen
      rememberMe: true
      rememberTokenKey: 'r_key'

  afterEach ->
    Auth.Config.reopen
      rememberMe: false
      rememberTokenKey: null
    Auth.set 'authToken', null

  describe 'default actions', ->
    it 'remember() on signInSuccess', ->
      spyOn Auth.Module.RememberMe, 'remember'
      Auth.trigger 'signInSuccess'
      expect(Auth.Module.RememberMe.remember).toHaveBeenCalled()

    it 'forget() on signInError', ->
      spyOn Auth.Module.RememberMe, 'forget'
      Auth.trigger 'signInError'
      expect(Auth.Module.RememberMe.forget).toHaveBeenCalled()

    it 'forget() on signOutSuccess', ->
      spyOn Auth.Module.RememberMe, 'forget'
      Auth.trigger 'signOutSuccess'
      expect(Auth.Module.RememberMe.forget).toHaveBeenCalled()

  describe 'token proxy methods', ->
    beforeEach ->
      Auth.Config.reopen { rememberPeriod: 7 }

    afterEach ->
      Auth.Config.reopen
        rememberPeriod: 14
        rememberStorage: 'cookie'

    describe '#retrieveToken', ->
      beforeEach ->
        spyOn localStorage, 'getItem'
        spyOn jQuery, 'cookie'

      it 'supports local storage', ->
        Auth.Config.reopen { rememberStorage: 'localStorage' }
        Auth.Module.RememberMe.retrieveToken()
        expect(localStorage.getItem)
          .toHaveBeenCalledWith 'ember-auth-remember-me'
        expect(jQuery.cookie).not.toHaveBeenCalled()

      it 'supports cookie', ->
        Auth.Config.reopen { rememberStorage: 'cookie' }
        Auth.Module.RememberMe.retrieveToken()
        expect(jQuery.cookie).toHaveBeenCalledWith 'ember-auth-remember-me'
        expect(localStorage.getItem).not.toHaveBeenCalled()

    describe '#storeToken', ->
      beforeEach ->
        spyOn localStorage, 'setItem'
        spyOn jQuery, 'cookie'

      it 'supports local storage', ->
        Auth.Config.reopen { rememberStorage: 'localStorage' }
        Auth.Module.RememberMe.storeToken('foo')
        expect(localStorage.setItem)
          .toHaveBeenCalledWith 'ember-auth-remember-me', 'foo'
        expect(jQuery.cookie).not.toHaveBeenCalled()

      it 'supports cookie', ->
        Auth.Config.reopen { rememberStorage: 'cookie' }
        Auth.Module.RememberMe.storeToken('foo')
        expect(jQuery.cookie)
          .toHaveBeenCalledWith 'ember-auth-remember-me', 'foo',
            expires: 7
        expect(localStorage.setItem).not.toHaveBeenCalled()

    describe '#removeToken', ->
      beforeEach ->
        spyOn localStorage, 'removeItem'
        spyOn jQuery, 'removeCookie'

      it 'supports local storage', ->
        Auth.Config.reopen { rememberStorage: 'localStorage' }
        Auth.Module.RememberMe.removeToken()
        expect(localStorage.removeItem)
          .toHaveBeenCalledWith 'ember-auth-remember-me'
        expect(jQuery.removeCookie).not.toHaveBeenCalled()

      it 'supports cookie', ->
        Auth.Config.reopen { rememberStorage: 'cookie' }
        Auth.Module.RememberMe.removeToken()
        expect(jQuery.removeCookie)
          .toHaveBeenCalledWith 'ember-auth-remember-me'
        expect(localStorage.removeItem).not.toHaveBeenCalled()

  describe '#recall', ->
    beforeEach ->
      spyOn Auth, 'signIn'

    describe 'supports async option', ->
      beforeEach ->
        Auth.set 'authToken', null
        spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn 'foo'

      describe '= true', ->
        it 'sets async option', ->
          Auth.Module.RememberMe.recall async: true
          expect(Auth.signIn.calls[0].args[0].async).toBe true

      describe '= false', ->
        it 'sets async option', ->
          Auth.Module.RememberMe.recall async: false
          expect(Auth.signIn.calls[0].args[0].async).toBe false

      describe 'undefined', ->
        it 'does not set async option', ->
          Auth.Module.RememberMe.recall()
          expect(Auth.signIn.calls[0].args[0].async).toBeUndefined()

    describe 'Auth.Config.rememberMe = false', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: false }

      it 'does not attempt a sign in', ->
        Auth.Module.RememberMe.recall()
        expect(Auth.signIn).not.toHaveBeenCalled()

    describe 'Auth.authToken present', ->
      beforeEach ->
        Auth.set 'authToken', 'foo'

      it 'does not attempt a sign in', ->
        Auth.Module.RememberMe.recall()
        expect(Auth.signIn).not.toHaveBeenCalled()

    describe 'retrieveToken fails', ->
      beforeEach ->
        spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn null

      it 'does not attempt a sign in', ->
        Auth.Module.RememberMe.recall()
        expect(Auth.signIn).not.toHaveBeenCalled()

    describe 'Auth.Config.rememberMe = true', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: true }

      describe 'Auth.authToken absent', ->
        beforeEach ->
          Auth.set 'authToken', null

        describe 'retrieveToken succeeds', ->
          beforeEach ->
            spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn 'foo'

          it 'attempts a sign in', ->
            Auth.Module.RememberMe.recall()
            expect(Auth.signIn.calls[0].args[0]).toEqual { r_key: 'foo' }

  describe '#remember', ->
    beforeEach ->
      spyOn Auth.Module.RememberMe, 'storeToken'

    describe 'Auth.Config.rememberMe = false', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: false }

      it 'does not attempt to remember session', ->
        Auth.Module.RememberMe.remember()
        expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

    describe 'no remember token in Auth.json', ->
      beforeEach ->
        Auth.set 'json', { foo: 'bar' }

      afterEach ->
        Auth.set 'json', null

      it 'does not attempt to remember session', ->
        Auth.Module.RememberMe.remember()
        expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

    describe 'remember token in Auth.json is empty', ->
      beforeEach ->
        Auth.set 'json', { r_key: '' }

      afterEach ->
        Auth.set 'json', null

      it 'does not attempt to remember session', ->
        Auth.Module.RememberMe.remember()
        expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

    describe 'remember token same as local one', ->
      beforeEach ->
        Auth.set 'json', { r_key: 'foo' }
        spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn 'foo'

      afterEach ->
        Auth.set 'json', null

      it 'does not attempt to remember session', ->
        Auth.Module.RememberMe.remember()
        expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

    describe 'Auth.Config.rememberMe = true', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: true }

      describe 'remember token present in Auth.json', ->
        beforeEach ->
          Auth.set 'json', { r_key: 'foo' }

        afterEach ->
          Auth.set 'json', null

        describe 'local session is empty', ->
          beforeEach ->
            spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn null

          it 'stores local session', ->
            Auth.Module.RememberMe.remember()
            expect(Auth.Module.RememberMe.storeToken.calls[0].args[0])
              .toBe 'foo'

        describe 'remember token different from local one', ->
          beforeEach ->
            spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn 'bar'

          it 'stores local session', ->
            Auth.Module.RememberMe.remember()
            expect(Auth.Module.RememberMe.storeToken.calls[0].args[0])
              .toBe 'foo'

  describe '#forget', ->
    beforeEach ->
      spyOn Auth.Module.RememberMe, 'removeToken'

    describe 'Auth.Config.rememberMe = false', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: false }

      it 'does not attempt to clear session', ->
        Auth.Module.RememberMe.forget()
        expect(Auth.Module.RememberMe.removeToken).not.toHaveBeenCalled()

    describe 'Auth.Config.rememberMe = true', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: true }

      it 'clears session', ->
        Auth.Module.RememberMe.forget()
        expect(Auth.Module.RememberMe.removeToken).toHaveBeenCalled()

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
      spyOn(Auth.Module.RememberMe, 'recall').andCallThrough()

    afterEach ->
      Em.run ->
        App.destroy()
        App = null

    describe 'Auth.Config.rememberMe = false', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: false }
        Auth.set 'authToken', null

      it 'does not attempt to auto recall session', ->
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(Auth.Module.RememberMe.recall).not.toHaveBeenCalled()

      it 'preserves Auth.Route functionalities', ->
        triggered = 0
        App.FooRoute.reopen
          init: ->
            @on 'authAccess', -> triggered++
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(triggered).toBe 1

    describe 'Auth.Config.rememberAutoRecall = false', ->
      beforeEach ->
        Auth.Config.reopen { rememberAutoRecall: false }
        Auth.set 'authToken', null

      it 'does not attempt to auto recall session', ->
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(Auth.Module.RememberMe.recall).not.toHaveBeenCalled()

      it 'preserves Auth.Route functionalities', ->
        triggered = 0
        App.FooRoute.reopen
          init: ->
            @on 'authAccess', -> triggered++
        Em.run App, 'advanceReadiness'
        Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
        expect(triggered).toBe 1

    describe 'Auth.Config.rememberMe = true', ->
      beforeEach ->
        Auth.Config.reopen { rememberMe: true }
        Auth.set 'authToken', null

      describe 'Auth.Config.rememberAutoRecall = true', ->
        beforeEach ->
          Auth.Config.reopen
            tokenCreateUrl: '/api/sign-in'
            tokenDestroyUrl: '/api/sign-out'
            tokenKey: 'auth_token'
            idKey: 'user_id'
            rememberAutoRecall: true
          spyOn(Auth.Module.RememberMe, 'retrieveToken').andReturn 'bar'

        afterEach ->
          Auth.Config.reopen
            tokenCreateUrl: null
            tokenDestroyUrl: null
            tokenKey: null
            idKey: null
            rememberAutoRecall: false
          $.mockjaxClear()

        describe 'JSON response', ->
          describe 'success', ->
            beforeEach ->
              $.mockjax
                url: '/api/sign-in'
                type: 'post'
                data: JSON.stringify { r_key: 'bar' }
                status: 201
                responseText: { auth_token: 'foo', user_id: 1 }

            it 'recalls session', ->
              Em.run App, 'advanceReadiness'
              Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
              expect(Auth.Module.RememberMe.recall.calls[0].args[0])
                .toEqual { async: false }
              expect(Auth.get 'authToken').toBe 'foo'

            it 'prevents redirect', ->
              currentPath = null
              App.ApplicationController = Em.Controller.extend
                currentPathDidChange: (->
                  currentPath = @get 'currentPath'
                ).observes('currentPath')
              Em.run App, 'advanceReadiness'
              Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
              expect(currentPath).toBe 'foo'

            # nothing would have been done, cannot test
            #it 'preserves Auth.Route functionalities', ->

          describe 'failure', ->
            beforeEach ->
              $.mockjax
                url: '/api/sign-in'
                type: 'post'
                data: { r_key: 'bar' }
                status: 401
                responseText: ''

            it 'fails to recall session', ->
              Em.run App, 'advanceReadiness'
              Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
              expect(Auth.Module.RememberMe.recall.calls[0].args[0])
                .toEqual { async: false }
              expect(Auth.get 'authToken').toBe null

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
                expect(currentPath).toBe 'sign-in'

            it 'preserves Auth.Route functionalities', ->
              triggered = 0
              App.FooRoute.reopen
                init: ->
                  @on 'authAccess', -> triggered++
              Em.run App, 'advanceReadiness'
              Em.run -> App.__container__.lookup('router:main').handleURL 'foo'
              expect(triggered).toBe 1

        # TODO
        #describe 'JSONP response', ->

describe 'Auth', ->
  it 'supports events', -> expect(Auth.on).toBeDefined()

  describe '#resolveUrl', ->
    afterEach -> Auth.Config.reopen { baseUrl: null }

    describe 'Auth.Config.baseUrl defined with trialing slash', ->
      beforeEach -> Auth.Config.reopen { baseUrl: 'foo/' }

      it 'appends path to Auth.Config.baseUrl', ->
        expect(Auth.resolveUrl('bar')).toEqual 'foo/bar'
        expect(Auth.resolveUrl('/bar')).toEqual 'foo/bar'

    describe 'Auth.Config.baseUrl defined without trialing slash', ->
      beforeEach -> Auth.Config.reopen { baseUrl: 'foo' }

      it 'appends path to Auth.Config.baseUrl', ->
        expect(Auth.resolveUrl('bar')).toEqual 'foo/bar'
        expect(Auth.resolveUrl('/bar')).toEqual 'foo/bar'

    describe 'Auth.Config.baseUrl defined as empty string', ->
      beforeEach -> Auth.Config.reopen { baseUrl: '' }

      it 'returns path', ->
        expect(Auth.resolveUrl('bar')).toEqual '/bar'
        expect(Auth.resolveUrl('/bar')).toEqual '/bar'

    describe 'Auth.Config.baseUrl undefined', ->
      it 'returns path', ->
        expect(Auth.resolveUrl('bar')).toEqual '/bar'
        expect(Auth.resolveUrl('/bar')).toEqual '/bar'

  describe '#resolveRedirectRoute', ->
    it 'returns null for non-signIn/Out route', ->
      expect(Auth.resolveRedirectRoute('foo')).toEqual null

    beforeEach ->
      Auth.Config.reopen
        signInRoute: 'sign-in'
        signInRedirectFallbackRoute: 'sign-in-fallback'
        signOutRoute: 'sign-out'
        signOutRedirectFallbackRoute: 'sign-out-fallback'
    afterEach ->
      Auth.Config.reopen
        signInRoute: null
        signInRedirectFallbackRoute: 'index'
        signOutRoute: null
        signOutRedirectFallbackRoute: 'index'

    describe 'smart redirect off', ->
      beforeEach ->
        Auth.Config.reopen
          smartSignInRedirect: false
          smartSignOutRedirect: false

      it 'returns fallback routes', ->
        expect(Auth.resolveRedirectRoute('signIn'))
          .toEqual 'sign-in-fallback'
        expect(Auth.resolveRedirectRoute('signOut'))
          .toEqual 'sign-out-fallback'

    describe 'smart redirect on', ->
      beforeEach ->
        Auth.Config.reopen
          smartSignInRedirect: true
          smartSignOutRedirect: true
      afterEach ->
        Auth.Config.reopen
          smartSignInRedirect: false
          smartSignOutRedirect: false
        Auth.set 'prevRoute', null

      describe 'Auth.prevRoute set', ->
        beforeEach -> Auth.set 'prevRoute', 'foo'

        it 'returns Auth.prevRoute', ->
          expect(Auth.resolveRedirectRoute('signIn')).toEqual 'foo'
          expect(Auth.resolveRedirectRoute('signOut')).toEqual 'foo'

      describe 'Auth.prevRoute same as signIn route', ->
        beforeEach -> Auth.set 'prevRoute', 'sign-in'

        describe 'sign in', ->
          it 'returns sign in fallback route', ->
            expect(Auth.resolveRedirectRoute('signIn'))
              .toEqual 'sign-in-fallback'

        describe 'sign out', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signOut')).toEqual 'sign-in'

      describe 'Auth.prevRoute same as signOut route', ->
        beforeEach -> Auth.set 'prevRoute', 'sign-out'

        describe 'sign in', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signIn')).toEqual 'sign-out'

        describe 'sign out', ->
          it 'returns sign out fallback route', ->
            expect(Auth.resolveRedirectRoute('signOut'))
              .toEqual 'sign-out-fallback'

  describe '#ajax', ->
    beforeEach ->
      Auth.Config.reopen
        tokenKey: 'tokenKey'
        requestHeaderKey: 'headerKey'
    afterEach ->
      Auth.Config.reopen
        tokenKey: null
        requestHeaderKey: null
        requestTokenLocation: 'param'
      Auth.set 'authToken', null

    describe 'Auth.authToken set', ->
      beforeEach -> Auth.set 'authToken', 'token-value'

      describe "Auth.Config.requestTokenLocation = 'param'", ->
        beforeEach ->
          Auth.Config.reopen { requestTokenLocation: 'param' }
          spyOn jQuery, 'ajax'

        describe 'type = GET', ->

          describe 'customized', ->

            describe 'does not override auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'GET', data: { baz: 'quux' } }

              it 'sends auth token as param with auth token value', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .toEqual 'token-value'

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

            describe 'overriding auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'GET', data: { tokenKey: 'quux' } }

              it 'sends auth token as param with overriden value', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .toEqual 'quux'

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }

            it 'sends auth token as param with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .toEqual 'token-value'

            it 'does not send Authorization header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .not.toBeDefined()

            it 'does not send custom header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .not.toBeDefined()

        describe 'type != GET', ->

          describe 'customized', ->

            describe 'does not override auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'FOO', data: { baz: 'quux' } }

              it 'sends auth token as param with auth token value', ->
                expect(JSON.parse(jQuery.ajax.calls[0].args[0].data).tokenKey)
                  .toEqual 'token-value'

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

            describe 'overriding auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'FOO', data: { tokenKey: 'quux' } }

              it 'sends auth token as param with overriden value', ->
                expect(JSON.parse(jQuery.ajax.calls[0].args[0].data).tokenKey)
                  .toEqual 'quux'

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }

            it 'sends auth token as param with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .toEqual 'token-value'

            it 'does not send Authorization header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .not.toBeDefined()

            it 'does not send custom header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .not.toBeDefined()

      describe "Auth.Config.requestTokenLocation = 'authHeader'", ->
        beforeEach ->
          Auth.Config.reopen { requestTokenLocation: 'authHeader' }
          spyOn jQuery, 'ajax'

        describe 'type != GET', ->

          describe 'customized', ->

            describe 'does not override Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { baz: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'sends Authorization header with auth token value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .toEqual 'headerKey token-value'

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

            describe 'overriding Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { Authorization: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'sends Authorization header with overriden value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .toEqual 'quux'

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }

            it 'does not tamper with params', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .not.toBeDefined()

            it 'sends Authorization header with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .toEqual 'headerKey token-value'

            it 'does not send custom header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .not.toBeDefined()

        describe 'type = GET', ->

          describe 'customized', ->

            describe 'does not override Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { baz: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'sends Authorization header with auth token value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .toEqual 'headerKey token-value'

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

            describe 'overriding Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { Authorization: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'sends Authorization header with overriden value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .toEqual 'quux'

              it 'does not send custom header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .not.toBeDefined()

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }

            it 'does not tamper with params', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .not.toBeDefined()

            it 'sends Authorization header with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .toEqual 'headerKey token-value'

            it 'does not send custom header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .not.toBeDefined()

      describe "Auth.Config.requestTokenLocation = 'customHeader'", ->
        beforeEach ->
          Auth.Config.reopen { requestTokenLocation: 'customHeader' }
          spyOn jQuery, 'ajax'

        describe 'type = GET', ->

          describe 'customized', ->

            describe 'does not override custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { baz: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'sends custom header with auth token value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .toEqual 'token-value'

            describe 'overriding custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { headerKey: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'sends custom header with overriden value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .toEqual 'quux'

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }

            it 'does not tamper with params', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .not.toBeDefined()

            it 'does not send Authorization header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .not.toBeDefined()

            it 'sends custom header with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .toEqual 'token-value'

        describe 'type != GET', ->

          describe 'customized', ->

            describe 'does not override custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { baz: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'sends custom header with auth token value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .toEqual 'token-value'

            describe 'overriding custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { headerKey: 'quux' } }

              it 'does not tamper with params', ->
                expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                  .not.toBeDefined()

              it 'does not send Authorization header', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                  .not.toBeDefined()

              it 'sends custom header with overriden value', ->
                expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                  .toEqual 'quux'

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }

            it 'does not tamper with params', ->
              expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
                .not.toBeDefined()

            it 'does not send Authorization header', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
                .not.toBeDefined()

            it 'sends custom header with auth token value', ->
              expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
                .toEqual 'token-value'

    describe 'Auth.authToken = null', ->
      beforeEach ->
        Auth.set 'authToken', null
        spyOn jQuery, 'ajax'
        Auth.ajax { url: 'bar', type: 'GET' }

      it 'does not tamper with params', ->
        expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
          .not.toBeDefined()

      it 'does not tamper with headers', ->
        expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
          .not.toBeDefined()

    describe 'default content type', ->
      beforeEach -> spyOn jQuery, 'ajax'

      describe 'data not given', ->
        beforeEach -> Auth.ajax()

        it 'does not set contentType', ->
          expect(jQuery.ajax.calls[0].args[0].contentType).not.toBeDefined()

        it 'does not set data', ->
          expect(jQuery.ajax.calls[0].args[0].data).not.toBeDefined()

      describe 'data given', ->

        describe 'contentType given', ->
          beforeEach -> Auth.ajax { data: { foo: 'bar' }, contentType: 'foo' }

          it 'uses given contentType', ->
            expect(jQuery.ajax.calls[0].args[0].contentType).toEqual 'foo'

          it 'uses given data', ->
            expect(jQuery.ajax.calls[0].args[0].data).toEqual { foo: 'bar' }

        describe 'contentType not given', ->

          describe 'type given', ->

            describe "= 'GET'", ->
              beforeEach -> Auth.ajax { data: { foo: 'bar' }, type: 'GET' }

              it 'does not set contentType', ->
                expect(jQuery.ajax.calls[0].args[0].contentType)
                  .not.toBeDefined()

              it 'uses given data', ->
                expect(jQuery.ajax.calls[0].args[0].data)
                  .toEqual { foo: 'bar' }

            describe "!= 'GET'", ->
              beforeEach -> Auth.ajax { data: { foo: 'bar' }, type: 'FOO' }

              it 'sets contentType to json', ->
                expect(jQuery.ajax.calls[0].args[0].contentType)
                  .toEqual 'application/json; charset=utf-8'

              it 'serializes data to json string', ->
                expect(jQuery.ajax.calls[0].args[0].data)
                  .toEqual '{"foo":"bar"}'

          describe 'type not given', ->
            beforeEach -> Auth.ajax { data: { foo: 'bar' } }

            it 'sets contentType to json', ->
              expect(jQuery.ajax.calls[0].args[0].contentType)
                .toEqual 'application/json; charset=utf-8'

            it 'serializes data to json string', ->
              expect(jQuery.ajax.calls[0].args[0].data).toEqual '{"foo":"bar"}'

    describe 'customizable', ->
      beforeEach ->
        spyOn jQuery, 'ajax'
        Auth.ajax { url: 'bar', type: 'GET', contentType: 'foo' }

      it 'overrides preset values', ->
        expect(jQuery.ajax.calls[0].args[0].type).toEqual 'GET'
        expect(jQuery.ajax.calls[0].args[0].contentType).toEqual 'foo'

  describe 'API calls', ->
    beforeEach ->
      Auth.Config.reopen
        tokenCreateUrl: '/api/sign-in'
        tokenDestroyUrl: '/api/sign-out'
        tokenKey: 'auth_token'
        idKey: 'user_id'
    afterEach ->
      Auth.Config.reopen
        tokenCreateUrl: null
        tokenDestroyUrl: null
        tokenKey: null
        idKey: null
      $.mockjaxClear()
      Auth.set 'authToken', null
      Auth.set 'currentUserId', null
      Auth.set 'currentUser', null
      Auth.set 'json', null
      Auth.set 'jqxhr', null
      Auth.set 'prevRoute', null

    describe '#signIn', ->

      describe 'supports async option', ->
        beforeEach -> spyOn(Auth, 'ajax').andCallThrough()

        describe '= true', ->
          beforeEach -> Auth.signIn { foo: 'bar', async: true }

          it 'sets async option', ->
            expect(Auth.ajax.calls[0].args[0].async).toEqual true

          it 'does not pollute data', ->
            expect(Auth.ajax.calls[0].args[0].data)
              .toEqual JSON.stringify { foo: 'bar' }

        describe '= false', ->
          beforeEach -> Auth.signIn { foo: 'bar', async: false }

          it 'sets async option', ->
            expect(Auth.ajax.calls[0].args[0].async).toEqual false

          it 'does not pollute data', ->
            expect(Auth.ajax.calls[0].args[0].data)
              .toEqual JSON.stringify { foo: 'bar' }

      describe 'success', ->
        beforeEach ->
          $.mockjax
            url: '/api/sign-in'
            type: 'post'
            data: JSON.stringify { username: 'user', password: 'pass' }
            status: 201
            responseText: { auth_token: 'foo', user_id: 1 }

        it 'sets various Auth variables', ->
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(Auth.get 'authToken').toEqual 'foo'
          expect(Auth.get 'currentUserId').toEqual 1
          expect(Auth.get 'json').toEqual { auth_token: 'foo', user_id: 1 }
          expect(Auth.get 'jqxhr').toEqual { auth_token: 'foo', user_id: 1 }

        it 'clears Auth.prevRoute', ->
          Auth.set 'prevRoute', 'foo'
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(Auth.get 'prevRoute').toEqual null

        it 'triggers events', ->
          success = error = complete = 0
          Auth.on 'signInSuccess', -> success++
          Auth.on 'signInError', -> error++
          Auth.on 'signInComplete', -> complete++
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(success).toEqual 1
          expect(error).toEqual 0
          expect(complete).toEqual 1

        describe 'Auth.currentUser', ->
          FooModel = { find: (id) -> "#{id}-model" }
          afterEach -> Auth.Config.reopen { userModel: null }

          it 'is set if userModel is defined', ->
            Auth.Config.reopen { userModel: FooModel }
            Auth.signIn { username: 'user', password: 'pass', async: false }
            expect(Auth.get 'currentUser').toEqual '1-model'

          it 'is not set if userModel = null', ->
            Auth.Config.reopen { userModel: null }
            Auth.signIn { username: 'user', password: 'pass', async: false }
            expect(Auth.get 'currentUser').toEqual null

      describe 'failure', ->
        beforeEach ->
          $.mockjax
            url: '/api/sign-in'
            type: 'post'
            data: { username: 'user', password: 'pass' }
            status: 401
            responseText: ''

        it 'sets various Auth variables', ->
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(Auth.get 'authToken').toEqual null
          expect(Auth.get 'currentUserId').toEqual null
          expect(Auth.get 'json').toEqual null
          expect(Auth.get 'jqxhr').toEqual jasmine.any(Object)

        it 'clears Auth.prevRoute', ->
          Auth.set 'prevRoute', 'foo'
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(Auth.get 'prevRoute').toEqual null

        it 'triggers events', ->
          success = error = complete = 0
          Auth.on 'signInSuccess', -> success++
          Auth.on 'signInError', -> error++
          Auth.on 'signInComplete', -> complete++
          Auth.signIn { username: 'user', password: 'pass', async: false }
          expect(success).toEqual 0
          expect(error).toEqual 1
          expect(complete).toEqual 1

        describe 'Auth.currentUser', ->
          FooModel = { find: (id) -> "#{id}-model" }
          afterEach -> Auth.Config.reopen { userModel: null }

          it 'is not set (regardless) if userModel is defined', ->
            Auth.Config.reopen { userModel: FooModel }
            Auth.signIn { username: 'user', password: 'pass', async: false }
            expect(Auth.get 'currentUser').toEqual null

          it 'is not set (regardless) if userModel = null', ->
            Auth.Config.reopen { userModel: null }
            Auth.signIn { username: 'user', password: 'pass', async: false }
            expect(Auth.get 'currentUser').toEqual null

    describe '#signOut', ->
      beforeEach ->
        Auth.set 'authToken', 'foo'
        Auth.set 'currentUserId', 1
        Auth.set 'currentUser', '1-model'

      describe 'supports async option', ->
        beforeEach -> spyOn(Auth, 'ajax').andCallThrough()

        describe '= true', ->
          beforeEach -> Auth.signOut { foo: 'bar', async: true }

          it 'sets async option', ->
            expect(Auth.ajax.calls[0].args[0].async).toEqual true

          it 'does not pollute data', ->
            expect(Auth.ajax.calls[0].args[0].data)
              .toEqual JSON.stringify { foo: 'bar', auth_token: 'foo' }

        describe '= false', ->
          beforeEach -> Auth.signOut { foo: 'bar', async: false }

          it 'sets async option', ->
            expect(Auth.ajax.calls[0].args[0].async).toEqual false

          it 'does not pollute data', ->
            expect(Auth.ajax.calls[0].args[0].data)
              .toEqual JSON.stringify { foo: 'bar', auth_token: 'foo' }

      describe 'success', ->
        beforeEach ->
          $.mockjax
            url: '/api/sign-out'
            type: 'delete'
            data: JSON.stringify { foo: 'bar', auth_token: 'foo' }
            status: 201
            responseText: { bar: 'baz' }

        it 'clears current Auth session variables', ->
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'authToken').toEqual null
          expect(Auth.get 'currentUserId').toEqual null
          expect(Auth.get 'currentUser').toEqual null

        it 'sets various Auth variables', ->
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'json').toEqual { bar: 'baz' }
          expect(Auth.get 'jqxhr').toEqual { bar: 'baz' }

        it 'clears Auth.prevRoute', ->
          Auth.set 'prevRoute', 'foo'
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'prevRoute').toEqual null

        it 'triggers events', ->
          success = error = complete = 0
          Auth.on 'signOutSuccess', -> success++
          Auth.on 'signOutError', -> error++
          Auth.on 'signOutComplete', -> complete++
          Auth.signOut { foo: 'bar', async: false }
          expect(success).toEqual 1
          expect(error).toEqual 0
          expect(complete).toEqual 1

      describe 'failure', ->
        beforeEach ->
          $.mockjax
            url: '/api/sign-out'
            type: 'delete'
            data: { auth_token: 'foo', foo: 'bar' }
            status: 401
            responseText: { bar: 'baz' }

        it 'keeps current Auth session variables', ->
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'authToken').toEqual 'foo'
          expect(Auth.get 'currentUserId').toEqual 1
          expect(Auth.get 'currentUser').toEqual '1-model'

        it 'sets various Auth variables', ->
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'json').toEqual null
          expect(Auth.get 'jqxhr').toEqual jasmine.any(Object)

        it 'clears Auth.prevRoute', ->
          Auth.set 'prevRoute', 'foo'
          Auth.signOut { foo: 'bar', async: false }
          expect(Auth.get 'prevRoute').toEqual null

        it 'triggers events', ->
          success = error = complete = 0
          Auth.on 'signOutSuccess', -> success++
          Auth.on 'signOutError', -> error++
          Auth.on 'signOutComplete', -> complete++
          Auth.signOut { foo: 'bar', async: false }
          expect(success).toEqual 0
          expect(error).toEqual 1
          expect(complete).toEqual 1
          expect(complete).toEqual 1

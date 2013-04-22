describe 'Auth', ->
  it 'supports events', -> expect(Auth.on).toBeDefined()

  describe '#resolveUrl', ->
    afterEach -> Auth.Config.reopen { baseUrl: null }

    describe 'Auth.Config.baseUrl defined with trialing slash', ->
      beforeEach -> Auth.Config.reopen { baseUrl: 'foo/' }
      follow 'auth resolve url',
        { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'Auth.Config.baseUrl defined without trialing slash', ->
      beforeEach -> Auth.Config.reopen { baseUrl: 'foo' }
      follow 'auth resolve url',
        { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'Auth.Config.baseUrl defined as empty string', ->
      beforeEach -> Auth.Config.reopen { baseUrl: '' }
      follow 'auth resolve url',
        { input: 'bar', output: '/bar', isAppend: false }

    describe 'Auth.Config.baseUrl undefined', ->
      follow 'auth resolve url',
        { input: 'bar', output: '/bar', isAppend: false }

  describe '#resolveRedirectRoute', ->
    it 'returns null for non-signIn/Out route', ->
      expect(Auth.resolveRedirectRoute('foo')).toEqual null

    beforeEach ->
      Auth.Config.reopen
        signInRoute: 'sign-in'
        signInRedirectFallbackRoute: 'sign-in-fb'
        signOutRoute: 'sign-out'
        signOutRedirectFallbackRoute: 'sign-out-fb'
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
        expect(Auth.resolveRedirectRoute('signIn')).toEqual 'sign-in-fb'
        expect(Auth.resolveRedirectRoute('signOut')).toEqual 'sign-out-fb'

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
            expect(Auth.resolveRedirectRoute('signIn')).toEqual 'sign-in-fb'

        describe 'sign out', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signOut')).toEqual 'sign-in'

      describe 'Auth.prevRoute same as signOut route', ->
        beforeEach -> Auth.set 'prevRoute', 'sign-out'

        describe 'sign in', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signIn')).toEqual 'sign-out'

        describe 'sign out', ->
          it 'returns sign out fb route', ->
            expect(Auth.resolveRedirectRoute('signOut')).toEqual 'sign-out-fb'

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

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }
            follow 'auth token location', 'param'

          describe 'customized', ->

            describe 'overriding auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'GET', data: { tokenKey: 'quux' } }
              follow 'auth token location', 'param', 'quux'

            describe 'does not override auth token key', ->

              describe 'data = object', ->
                beforeEach ->
                  Auth.ajax { url: 'bar', type: 'GET', data: { baz: 'quux' } }
                follow 'auth token location', 'param'

              describe 'data = null', ->
                beforeEach ->
                  Auth.ajax { url: 'bar', type: 'GET', data: null }
                follow 'auth token location', 'param'

        describe 'type != GET', ->

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }
            follow 'auth token location', 'param'

          describe 'customized', ->

            describe 'overriding auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'FOO', data: { tokenKey: 'quux' } }
              follow 'auth token location', 'quux'

            describe 'does not override auth token key', ->
              beforeEach ->
                Auth.ajax { url: 'bar', type: 'FOO', data: { baz: 'quux' } }
              follow 'auth token location'

      describe "Auth.Config.requestTokenLocation = 'authHeader'", ->
        beforeEach ->
          Auth.Config.reopen { requestTokenLocation: 'authHeader' }
          spyOn jQuery, 'ajax'

        describe 'type != GET', ->

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }
            follow 'auth token location', 'authorization header'

          describe 'customized', ->

            describe 'overriding Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { Authorization: 'quux' } }
              follow 'auth token location', 'authorization header', 'quux'

            describe 'does not override Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { baz: 'quux' } }
              follow 'auth token location', 'authorization header'

        describe 'type = GET', ->

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }
            follow 'auth token location', 'authorization header'

          describe 'customized', ->

            describe 'overriding Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { Authorization: 'quux' } }
              follow 'auth token location', 'authorization header', 'quux'

            describe 'does not override Authorization header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { baz: 'quux' } }
              follow 'auth token location', 'authorization header'

      describe "Auth.Config.requestTokenLocation = 'customHeader'", ->
        beforeEach ->
          Auth.Config.reopen { requestTokenLocation: 'customHeader' }
          spyOn jQuery, 'ajax'

        describe 'type = GET', ->

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'GET' }
            follow 'auth token location', 'custom header'

          describe 'customized', ->

            describe 'overriding custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { headerKey: 'quux' } }
              follow 'auth token location', 'custom header', 'quux'

            describe 'does not override custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'GET', headers: { baz: 'quux' } }
              follow 'auth token location', 'custom header'

        describe 'type != GET', ->

          describe 'default', ->
            beforeEach ->
              Auth.ajax { url: 'bar', type: 'FOO' }
            follow 'auth token location', 'custom header'

          describe 'customized', ->

            describe 'overriding custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { headerKey: 'quux' } }
              follow 'auth token location', 'custom header', 'quux'

            describe 'does not override custom auth header', ->
              beforeEach ->
                Auth.ajax {
                  url: 'bar', type: 'FOO', headers: { baz: 'quux' } }
              follow 'auth token location', 'custom header'

    describe 'Auth.authToken = null', ->
      beforeEach ->
        Auth.set 'authToken', null
        spyOn jQuery, 'ajax'
        Auth.ajax { url: 'bar', type: 'GET' }

      follow 'auth token in param'
      follow 'auth token in authorization header'
      follow 'auth token in custom header'

    describe 'default content type', ->
      beforeEach -> spyOn jQuery, 'ajax'

      describe 'data not given', ->
        beforeEach -> Auth.ajax()
        follow 'auth ajax content type'
        follow 'auth ajax data'

      describe 'data given', ->

        describe 'contentType given', ->
          beforeEach -> Auth.ajax { data: { foo: 'bar' }, contentType: 'foo' }
          follow 'auth ajax content type', 'foo'
          follow 'auth ajax data', { foo: 'bar' }

        describe 'contentType not given', ->

          describe 'type not given', ->
            beforeEach -> Auth.ajax { data: { foo: 'bar' } }
            follow 'auth ajax content type', 'application/json; charset=utf-8'
            follow 'auth ajax data', '{"foo":"bar"}', true

          describe 'type given', ->

            describe '= GET', ->
              beforeEach -> Auth.ajax { data: { foo: 'bar' }, type: 'GET' }
              follow 'auth ajax content type'
              follow 'auth ajax data', { foo: 'bar' }

            describe '!= GET', ->
              beforeEach -> Auth.ajax { data: { foo: 'bar' }, type: 'FOO' }
              follow 'auth ajax content type', 'application/json; charset=utf-8'
              follow 'auth ajax data', '{"foo":"bar"}', true

    describe 'customizable', ->
      beforeEach ->
        spyOn jQuery, 'ajax'
        Auth.ajax { url: 'bar', type: 'GET', contentType: 'foo' }

      it 'uses given values', ->
        expect(jQuery.ajax.calls[0].args[0].url).toEqual 'bar'
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
      follow 'auth async support'

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

      follow 'auth async support'

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

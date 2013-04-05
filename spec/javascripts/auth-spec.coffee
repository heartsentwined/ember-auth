describe 'Auth', ->

  it 'supports events', ->
    expect(Auth.on).toBeDefined()

  describe '#resolveUrl', ->
    afterEach ->
      Auth.Config.reopen { baseUrl: null }

    describe 'Auth.Config.baseUrl defined with trialing slash', ->
      beforeEach ->
        Auth.Config.reopen { baseUrl: 'foo/' }
      it 'appends path to Auth.Config.baseUrl', ->
        expect(Auth.resolveUrl('bar')).toBe 'foo/bar'
        expect(Auth.resolveUrl('/bar')).toBe 'foo/bar'

    describe 'Auth.Config.baseUrl defined without trialing slash', ->
      beforeEach ->
        Auth.Config.reopen { baseUrl: 'foo' }
      it 'appends path to Auth.Config.baseUrl', ->
        expect(Auth.resolveUrl('bar')).toBe 'foo/bar'
        expect(Auth.resolveUrl('/bar')).toBe 'foo/bar'

    describe 'Auth.Config.baseUrl defined as empty string', ->
      beforeEach ->
        Auth.Config.reopen { baseUrl: '' }
      it 'returns path', ->
        expect(Auth.resolveUrl('bar')).toBe '/bar'
        expect(Auth.resolveUrl('/bar')).toBe '/bar'

    describe 'Auth.Config.baseUrl undefined', ->
      it 'returns path', ->
        expect(Auth.resolveUrl('bar')).toBe '/bar'
        expect(Auth.resolveUrl('/bar')).toBe '/bar'

  describe '#resolveRedirectRoute', ->
    it 'returns null for non-signIn/Out route', ->
      expect(Auth.resolveRedirectRoute('foo')).toBe null

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
        expect(Auth.resolveRedirectRoute('signIn')).toBe 'sign-in-fallback'
        expect(Auth.resolveRedirectRoute('signOut')).toBe 'sign-out-fallback'

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
        beforeEach ->
          Auth.set 'prevRoute', 'foo'
        it 'returns Auth.prevRoute', ->
          expect(Auth.resolveRedirectRoute('signIn')).toBe 'foo'
          expect(Auth.resolveRedirectRoute('signOut')).toBe 'foo'

      describe 'Auth.prevRoute same as signIn route', ->
        beforeEach ->
          Auth.set 'prevRoute', 'sign-in'
        describe 'sign in', ->
          it 'returns sign in fallback route', ->
            expect(Auth.resolveRedirectRoute('signIn')).toBe 'sign-in-fallback'
        describe 'sign out', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signOut')).toBe 'sign-in'

      describe 'Auth.prevRoute same as signOut route', ->
        beforeEach ->
          Auth.set 'prevRoute', 'sign-out'
        describe 'sign in', ->
          it 'returns Auth.prevRoute', ->
            expect(Auth.resolveRedirectRoute('signIn')).toBe 'sign-out'
        describe 'sign out', ->
          it 'returns sign out fallback route', ->
            expect(Auth.resolveRedirectRoute('signOut'))
              .toBe 'sign-out-fallback'

  describe '#ajax', ->
    beforeEach ->
      Auth.Config.reopen
        tokenKey: 'tokenKey'
        requestHeaderKey: 'headerKey'

    afterEach ->
      Auth.Config.reopen
        tokenKey: null
        requestHeaderKey: null
        requestHeaderAuthorization: false
      Auth.set 'authToken', null

    describe 'Auth.authToken set', ->
      beforeEach ->
        Auth.set 'authToken', 'token-value'

      describe 'Auth.Config.requestHeaderAuthorization set to false', ->
        beforeEach ->
          Auth.Config.reopen { requestHeaderAuthorization: false }
          spyOn jQuery, 'ajax'
          Auth.ajax 'bar', 'GET', {}
        it 'sends auth token as param', ->
          expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
            .toBe 'token-value'
        it 'does not tamper with headers', ->
          expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
            .not.toBeDefined()

      describe 'Auth.Config.requestHeaderAuthorization set to true', ->
        beforeEach ->
          Auth.Config.reopen { requestHeaderAuthorization: true }
          spyOn jQuery, 'ajax'
          Auth.ajax 'bar', 'GET', {}
        it 'sends auth token as header', ->
          expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
            .toBe 'token-value'
        it 'does not tamper with params', ->
          expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
            .not.toBeDefined()

    describe 'Auth.authToken = null', ->
      beforeEach ->
        Auth.set 'authToken', null
        spyOn jQuery, 'ajax'
        Auth.ajax 'bar', 'GET', {}
      it 'does not tamper with params', ->
        expect(jQuery.ajax.calls[0].args[0].data?.tokenKey)
          .not.toBeDefined()
      it 'does not tamper with headers', ->
        expect(jQuery.ajax.calls[0].args[0].headers?.headerKey)
          .not.toBeDefined()

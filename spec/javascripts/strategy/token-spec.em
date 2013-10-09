describe 'Em.Auth.TokenAuthStrategy', ->
  auth   = null
  token  = null
  output = null

  beforeEach ->
    auth  = authTest.create { strategy: 'token' }
    token = auth._strategy
  afterEach ->
    auth.destroy() if auth
    auth   = null
    output = null

  follow 'property injection', 'authToken', ->
    beforeEach -> @from = token; @to = auth

  describe '#serialize', ->

    describe 'not signed in', ->
      beforeEach ->
        Em.run ->
          auth._session.end()
          output = token.serialize { data: { foo: 'bar' } }
      it '', -> follow 'token in param', output
      it '', -> follow 'token in auth header', output
      it '', -> follow 'token in custom header', output

    describe 'signed in', ->
      beforeEach ->
        Em.run ->
          auth._session.start()
          token.authToken = 'token'

      describe 'tokenLocation = param', ->
        beforeEach ->
          Em.run ->
            auth.tokenLocation = 'param'
            auth.tokenKey = 'key'

        describe 'overriding auth token key', ->
          beforeEach ->
            output = token.serialize { data: { foo: 'bar', key: 'baz' } }
          it '', -> follow 'token location', output, 'param', 'baz'

        describe 'does not override auth token key', ->

          describe 'data = object', ->
            beforeEach ->
              output = token.serialize { data: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'param'

          describe 'data = null', ->
            beforeEach ->
              output = token.serialize { data: null }
            it '', -> follow 'token location', output, 'param'

      describe 'tokenLocation = authHeader', ->
        beforeEach ->
          Em.run ->
            auth.tokenLocation = 'authHeader'
            auth.tokenHeaderKey = 'key'

        describe 'overriding Authorization header', ->
          beforeEach ->
            output = token.serialize \
            { headers: { foo: 'bar', Authorization: 'baz' } }
          it '', -> follow 'token location', output, 'auth header', 'baz'

        describe 'does not override Authorization header', ->

          describe 'headers = object', ->
            beforeEach ->
              output = token.serialize { headers: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'auth header'

          describe 'headers = null', ->
            beforeEach ->
              output = token.serialize { headers: null }
            it '', -> follow 'token location', output, 'auth header'

      describe 'tokenLocation = customHeader', ->
        beforeEach ->
          Em.run ->
            auth.tokenLocation = 'customHeader'
            auth.tokenHeaderKey = 'key'

        describe 'overriding custom auth header', ->
          beforeEach ->
            output = token.serialize { headers: { foo: 'bar', key: 'baz' } }
          it '', -> follow 'token location', output, 'custom header', 'baz'

        describe 'does not override custom auth header', ->

          describe 'headers = object', ->
            beforeEach ->
              output = token.serialize { headers: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'custom header'

          describe 'headers = null', ->
            beforeEach ->
              output = token.serialize { headers: null }
            it '', -> follow 'token location', output, 'custom header'

  describe '#deserialize', ->
    it 'sets authToken at tokenKey', ->
      Em.run ->
        auth = authTest.create
          strategy: 'token'
          response: 'dummy'
          tokenKey: 'foo'
        token = auth._strategy
        token.deserialize { foo: 'bar' }
      expect(token.authToken).toEqual 'bar'

    it 'sets userId at tokenIdKey', ->
      Em.run ->
        auth = authTest.create
          strategy: 'token'
          response: 'dummy'
          tokenIdKey: 'foo'
        auth._strategy.deserialize { foo: '1' }
      expect(auth.userId).toEqual '1'

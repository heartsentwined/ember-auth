describe 'Em.Auth.Strategy.Token', ->
  auth    = null
  adapter = null
  output  = null

  beforeEach ->
    auth    = Em.Auth.create { responseAdapter: 'dummy' }
    adapter = auth._strategy.adapter
  afterEach ->
    auth.destroy() if auth
    auth   = null
    output = null

  it '', ->
    follow 'property injection', adapter, auth, 'authToken'

  describe '#serialize', ->

    describe 'not signed in', ->
      beforeEach ->
        auth._session.clear()
        output = adapter.serialize { data: { foo: 'bar' } }
      it '', -> follow 'token in param', output
      it '', -> follow 'token in auth header', output
      it '', -> follow 'token in custom header', output

    describe 'signed in', ->
      beforeEach ->
        auth._session.start()
        adapter.authToken = 'token'

      describe 'tokenLocation = param', ->
        beforeEach ->
          auth.tokenLocation = 'param'
          auth.tokenKey = 'key'

        describe 'overriding auth token key', ->
          beforeEach ->
            output = adapter.serialize { data: { foo: 'bar', key: 'baz' } }
          it '', -> follow 'token location', output, 'param', 'baz'

        describe 'does not override auth token key', ->

          describe 'data = object', ->
            beforeEach ->
              output = adapter.serialize { data: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'param'

          describe 'data = null', ->
            beforeEach ->
              output = adapter.serialize { data: null }
            it '', -> follow 'token location', output, 'param'

      describe 'tokenLocation = authHeader', ->
        beforeEach ->
          auth.tokenLocation = 'authHeader'
          auth.tokenHeaderKey = 'key'

        describe 'overriding Authorization header', ->
          beforeEach ->
            output = adapter.serialize \
            { headers: { foo: 'bar', Authorization: 'baz' } }
          it '', -> follow 'token location', output, 'auth header', 'baz'

        describe 'does not override Authorization header', ->

          describe 'headers = object', ->
            beforeEach ->
              output = adapter.serialize { headers: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'auth header'

          describe 'headers = null', ->
            beforeEach ->
              output = adapter.serialize { headers: null }
            it '', -> follow 'token location', output, 'auth header'

      describe 'tokenLocation = customHeader', ->
        beforeEach ->
          auth.tokenLocation = 'customHeader'
          auth.tokenHeaderKey = 'key'

        describe 'overriding custom auth header', ->
          beforeEach ->
            output = adapter.serialize { headers: { foo: 'bar', key: 'baz' } }
          it '', -> follow 'token location', output, 'custom header', 'baz'

        describe 'does not override custom auth header', ->

          describe 'headers = object', ->
            beforeEach ->
              output = adapter.serialize { headers: { foo: 'bar' } }
            it '', -> follow 'token location', output, 'custom header'

          describe 'headers = null', ->
            beforeEach ->
              output = adapter.serialize { headers: null }
            it '', -> follow 'token location', output, 'custom header'

  describe '#deserialize', ->
    it 'sets authToken at tokenKey', ->
      auth = Em.Auth.create
        strategyAdapter: 'token'
        responseAdapter: 'dummy'
        tokenKey: 'foo'
      adapter = auth._strategy.adapter
      adapter.deserialize { foo: 'bar' }
      expect(adapter.authToken).toEqual 'bar'

    it 'sets userId at tokenIdKey', ->
      auth = Em.Auth.create
        strategyAdapter: 'token'
        responseAdapter: 'dummy'
        tokenIdKey: 'foo'
      auth._strategy.adapter.deserialize { foo: '1' }
      expect(auth.userId).toEqual '1'

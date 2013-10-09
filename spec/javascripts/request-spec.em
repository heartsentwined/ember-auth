describe 'Em.Auth.Request', ->
  auth    = null
  spy     = null
  request = null

  beforeEach ->
    auth = authTest.create()
    request = auth._request
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#resolveUrl', ->

    example 'request resolve url', ({ input, output, isAppend }) ->
      desc = if isAppend then 'appends path to baseUrl' else 'returns path'
      it desc, ->
        expect(auth._request.resolveUrl(input)).toEqual output
        expect(auth._request.resolveUrl("/#{input}")).toEqual output

    describe 'baseUrl defined with trialing slash', ->
      beforeEach -> auth = authTest.create { baseUrl: 'foo/' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl defined without trialing slash', ->
      beforeEach -> auth = authTest.create { baseUrl: 'foo' }
      follow 'request resolve url',
      { input: 'bar', output: 'foo/bar', isAppend: true }

    describe 'baseUrl = null', ->
      beforeEach -> auth = authTest.create { baseUrl: null }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }

    describe 'baseUrl = empty string', ->
      beforeEach -> auth = authTest.create { baseUrl: '' }
      follow 'request resolve url',
      { input: 'bar', output: '/bar', isAppend: false }

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

  follow 'adapter init', 'request'

  example 'request method', (method) ->
    it "injects #{method} method to Auth", ->
      expect(auth[method]).toBeDefined()

    it 'preserves args', ->
      spy = sinon.collection.spy request, method
      Em.run -> auth[method]('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

    follow 'return promise', ->
      beforeEach -> @return = auth[method]()

  follow 'request method', 'signIn'
  follow 'request method', 'signOut'
  follow 'request method', 'send'

  example 'request server api', (type) ->
    describe "##{type}", ->
      beforeEach ->
        opts = { responseAdapter: 'dummy', strategyAdapter: 'dummy' }
        opts["#{type}EndPoint"] = '/foo'
        auth = authTest.create opts
        request = auth._request

      it 'resolves url', ->
        spy = sinon.collection.spy request, 'resolveUrl'
        request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo')

      it 'delegates to adapter', ->
        spy = sinon.collection.spy request.adapter, type
        request[type]('bar')
        expect(spy).toHaveBeenCalledWithExactly('/foo', 'bar')

      it 'serializes opts', ->
        spy = sinon.collection.spy auth._strategy, 'serialize'
        request[type]('foo')
        expect(spy).toHaveBeenCalledWithExactly('foo')

  follow 'request server api', 'signIn'
  follow 'request server api', 'signOut'

  describe '#send', ->
    follow 'adapter delegation', 'send', ['foo'], ->
      beforeEach -> @type = request

    it 'serializes opts', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      request.send('foo')
      expect(spy).toHaveBeenCalledWithExactly('foo')

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

  follow 'adapter sync event', ->
    beforeEach -> @type = request

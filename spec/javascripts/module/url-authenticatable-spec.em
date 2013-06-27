describe 'Em.Auth.Module.UrlAuthenticatable', ->
  auth    = null
  spy     = null
  urlAuth = null

  beforeEach ->
    auth = authTest.create { modules: ['urlAuthenticatable'] }
    urlAuth = auth.module.urlAuthenticatable
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#authenticate', ->
    cParamsSpy = null
    signInSpy  = null

    follow 'return promise', ->
      beforeEach -> @return = urlAuth.authenticate()

    beforeEach ->
      cParamsSpy = sinon.collection.spy urlAuth, 'canonicalizeParams'
      signInSpy  = sinon.collection.spy auth, 'signIn'

    describe 'signed in', ->
      beforeEach -> Em.run -> auth._session.start()

      it 'does nothing', ->
        Em.run -> urlAuth.authenticate()
        expect(cParamsSpy).not.toHaveBeenCalled()
        expect(signInSpy).not.toHaveBeenCalled()

    describe 'not signed in', ->
      beforeEach -> Em.run -> auth._session.clear()

      it 'delegates to #canonicalizeParams', ->
        urlAuth.authenticate()
        expect(cParamsSpy).toHaveBeenCalled()

      describe 'params empty', ->
        beforeEach -> Em.run -> urlAuth.params = {}

        it 'does nothing', ->
          Em.run -> urlAuth.authenticate()
          expect(signInSpy).not.toHaveBeenCalled()

      describe 'params not empty', ->
        beforeEach -> Em.run -> urlAuth.params = { foo: 'bar' }

        it 'delegates to auth.signIn with params as data', ->
          Em.run -> urlAuth.authenticate()
          expect(signInSpy).toHaveBeenCalledWithExactly
            data: { foo: 'bar' }

        it 'lets opts.data override params', ->
          Em.run -> urlAuth.authenticate { data: { foo: 'baz', bar: 'quux' } }
          expect(signInSpy).toHaveBeenCalledWithExactly
            data: { foo: 'baz', bar: 'quux' }

  describe '#retrieveParams', ->
    beforeEach ->
      spy = sinon.collection.stub jQuery, 'url', \
      -> { param: (arg) -> { key: arg } }
      Em.run -> auth.urlAuthenticatable.paramsKey = 'foo'
      urlAuth.retrieveParams()

    it 'delegates to $.url()', ->
      expect(spy).toHaveBeenCalled()

    it 'sets params', ->
      expect(urlAuth.params).toEqual { key: 'foo' }

  describe '#canonicalizeParams', ->
    example 'canonicalize', (input, output) ->
      it '', ->
        Em.run =>
          @urlAuth.params = input
          @urlAuth.canonicalizeParams()
        expect(@urlAuth.params).toEqual output

    describe 'null', ->
      it 'wraps to empty object', ->
        follow 'canonicalize', null, {}, ->
          beforeEach -> @urlAuth = urlAuth

    describe 'primitive', ->
      it 'wraps to one-member object', ->
        follow 'canonicalize', 'foo', { foo: 'foo' }, ->
          beforeEach -> @urlAuth = urlAuth

      it 'removes trialing slash, if any', ->
        follow 'canonicalize', 'foo/', { foo: 'foo' }, ->
          beforeEach -> @urlAuth = urlAuth

    describe 'array', ->
      it 'wraps to object with array indices as keys', ->
        follow 'canonicalize', [1, 2], { 0: '1', 1: '2' }, ->
          beforeEach -> @urlAuth = urlAuth

      it 'removes trialing slash, if any', ->
        follow 'canonicalize', ['a/', 'b'], { 0: 'a', 1: 'b' }, ->
          beforeEach -> @urlAuth = urlAuth

    describe 'empty object', ->
      it 'does nothing', ->
        follow 'canonicalize', {}, {}, ->
          beforeEach -> @urlAuth = urlAuth

    describe 'simple object', ->
      it 'removes trailing slash, if any', ->
        follow 'canonicalize', { foo: 'foo'  }, { foo: 'foo' }, ->
          beforeEach -> @urlAuth = urlAuth
        follow 'canonicalize', { foo: 'foo/' }, { foo: 'foo' }, ->
          beforeEach -> @urlAuth = urlAuth

    describe 'deep object', ->
      it 'removes trailing slash, if any', ->
        input =
          a: { b: 'b/', c: 'c' }
          d: 'd/'
        output =
          a: { b: 'b', c: 'c' }
          d: 'd'
        follow 'canonicalize', input, output, ->
          beforeEach -> @urlAuth = urlAuth

  describe 'auto authenticate', ->
    beforeEach ->
      appTest.create (app) ->
        app.Router.map -> @route 'foo'
        app.FooRoute = Em.Route.extend()
        app.Auth = authTest.create { modules: ['urlAuthenticatable'] }
        urlAuth = app.Auth.module.urlAuthenticatable
    afterEach ->
      appTest.destroy()

    it 'retrieves param', ->
      spy = sinon.collection.spy urlAuth, 'retrieveParams'
      appTest.ready()
      expect(spy).toHaveBeenCalled()

    it 'auto authenticate on any route entry', ->
      spy = sinon.collection.spy urlAuth, 'authenticate'
      appTest.ready()
      appTest.toRoute 'foo'
      expect(spy).toHaveBeenCalled()

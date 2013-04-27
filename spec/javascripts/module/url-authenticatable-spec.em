describe 'Em.Auth.Module.UrlAuthenticatable', ->
  auth    = null
  spy     = null
  urlAuth = null

  beforeEach ->
    Em.run ->
      auth = Em.Auth.create
        requestAdapter:  'dummy'
        responseAdapter: 'dummy'
        strategyAdapter: 'dummy'
        sessionAdapter:  'dummy'
        modules: ['urlAuthenticatable']
      urlAuth = auth.module.urlAuthenticatable
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#authenticate', ->
    cParamsSpy = null
    signInSpy  = null

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
      Em.run -> auth.urlAuthenticatableParamsKey = 'foo'
      urlAuth.retrieveParams()

    it 'delegates to $.url()', ->
      expect(spy).toHaveBeenCalled()

    it 'sets params', ->
      expect(urlAuth.params).toEqual { key: 'foo' }

  describe '#canonicalizeParams', ->
    example 'canonicalize', (env, input, output) ->
      Em.run ->
        env.params = input
        env.canonicalizeParams()
      expect(env.params).toEqual output

    describe 'null', ->
      it 'wraps to empty object', ->
        follow 'canonicalize', urlAuth, null, {}

    describe 'primitive', ->
      it 'wraps to one-member object', ->
        follow 'canonicalize', urlAuth, 'foo', { foo: 'foo' }

      it 'removes trialing slash, if any', ->
        follow 'canonicalize', urlAuth, 'foo/', { foo: 'foo' }

    describe 'array', ->
      it 'wraps to object with array indices as keys', ->
        follow 'canonicalize', urlAuth, [1, 2], { 0: '1', 1: '2' }

      it 'removes trialing slash, if any', ->
        follow 'canonicalize', urlAuth, ['a/', 'b'], { 0: 'a', 1: 'b' }

    describe 'empty object', ->
      it 'does nothing', ->
        follow 'canonicalize', urlAuth, {}, {}

    describe 'simple object', ->
      it 'removes trailing slash, if any', ->
        follow 'canonicalize', urlAuth, { foo: 'foo'  }, { foo: 'foo' }
        follow 'canonicalize', urlAuth, { foo: 'foo/' }, { foo: 'foo' }

    describe 'deep object', ->
      it 'removes trailing slash, if any', ->
        input =
          a: { b: 'b/', c: 'c' }
          d: 'd/'
        output =
          a: { b: 'b', c: 'c' }
          d: 'd'
        follow 'canonicalize', urlAuth, input, output

  describe 'auto authenticate', ->
    beforeEach ->
      em.create (app) ->
        app.Router.map -> @route 'foo'
        app.FooRoute = Em.Route.extend()
        app.Auth = Em.Auth.create
          requestAdapter:  'dummy'
          responseAdapter: 'dummy'
          strategyAdapter: 'dummy'
          sessionAdapter:  'dummy'
          modules: ['urlAuthenticatable']
        urlAuth = app.Auth.module.urlAuthenticatable
    afterEach ->
      em.destroy()

    it 'retrieves param', ->
      spy = sinon.collection.spy urlAuth, 'retrieveParams'
      em.ready()
      expect(spy).toHaveBeenCalled()

    it 'auto authenticate on any route entry', ->
      spy = sinon.collection.spy urlAuth, 'authenticate'
      em.ready()
      em.toRoute 'foo'
      expect(spy).toHaveBeenCalledWithExactly { async: false }

describe 'Em.Auth', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create()
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#_config', ->
    afterEach -> auth._defaults = {}

    describe 'setter', ->
      it 'registers default configs in given namespace', ->
        Em.run -> auth._config 'foo', { bar: 'baz' }
        expect(auth._defaults).toEqual { foo: { bar: 'baz' } }

      it 'merges default configs into given namespace', ->
        Em.run -> auth._defaults = { foo: { bar: 'baz' } }
        Em.run -> auth._config 'foo', { foo: 'bar' }
        expect(auth._defaults).toEqual { foo: { foo: 'bar', bar: 'baz' } }

    describe 'getter', ->
      it 'merges default configs', ->
        auth = Em.Auth.extend(
          foo: 'baz'
          bar:
            bar2: 'bar3'
        ).create()
        Em.run -> auth._config 'bar', { bar1: 'bar1', bar2: 'bar2' }
        expect(auth._config 'bar').toEqual { bar1: 'bar1', bar2: 'bar3' }

  describe '#signIn', ->
    follow 'return promise', ->
      beforeEach -> @return = auth.signIn()

    it 'delegates to request#signIn', ->
      spy = sinon.collection.spy auth._request, 'signIn'
      Em.run -> auth.signIn 'foo', {}
      expect(spy).toHaveBeenCalledWith '/foo', {}

    describe '(url, opts) ->', ->
      it 'delegates url to request#resolveUrl', ->
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.signIn 'foo', {}
        expect(spy).toHaveBeenCalledWith 'foo'

    describe '(opts) ->', ->
      it 'delegates signInEndPoint to request#resolveUrl', ->
        Em.run -> auth.signInEndPoint = 'foo'
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.signIn {}
        expect(spy).toHaveBeenCalledWith 'foo'

    it 'delegates opts to strategy#serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      Em.run -> auth.signIn {}
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates response payload to response#canonicalize', ->
      sinon.collection.stub auth._request, 'signIn', -> new Em.RSVP.resolve {}
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> auth.signIn()
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates canonicalized data to strategy#deserialize', ->
      sinon.collection.stub auth._response, 'canonicalize', -> {}
      spy = sinon.collection.spy auth._strategy, 'deserialize'
      Em.run -> auth.signIn()
      expect(spy).toHaveBeenCalledWith {}

    describe 'success', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'signIn', -> new Em.RSVP.resolve
        sinon.collection.stub auth._response, 'canonicalize', -> {}

      it 'delegates canonicalized data to session#start', ->
        spy = sinon.collection.spy auth._session, 'start'
        Em.run -> auth.signIn()
        expect(spy).toHaveBeenCalledWith {}

      it 'delegates data to registered `signInSuccess` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'signInSuccess', spy
        Em.run -> auth.signIn()
        expect(spy).toHaveBeenCalledWith {}

    describe 'error', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'signIn', -> new Em.RSVP.reject
        sinon.collection.stub auth._response, 'canonicalize', -> {}

      it 'delegates canonicalized data to session#end', ->
        spy = sinon.collection.spy auth._session, 'end'
        Em.run -> auth.signIn()
        expect(spy).toHaveBeenCalledWith {}

      it 'delegates data to registered `signInError` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'signInError', spy
        Em.run -> auth.signIn()
        expect(spy).toHaveBeenCalledWith {}

  describe '#signOut', ->
    follow 'return promise', ->
      beforeEach -> @return = auth.signOut()

    it 'delegates to request#signOut', ->
      spy = sinon.collection.spy auth._request, 'signOut'
      Em.run -> auth.signOut 'foo', {}
      expect(spy).toHaveBeenCalledWith '/foo', {}

    describe '(url, opts) ->', ->
      it 'delegates url to request#resolveUrl', ->
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.signOut 'foo', {}
        expect(spy).toHaveBeenCalledWith 'foo'

    describe '(opts) ->', ->
      it 'delegates signOutEndPoint to request#resolveUrl', ->
        Em.run -> auth.signOutEndPoint = 'foo'
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.signOut {}
        expect(spy).toHaveBeenCalledWith 'foo'

    it 'delegates opts to strategy#serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      Em.run -> auth.signOut {}
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates response payload to response#canonicalize', ->
      sinon.collection.stub auth._request, 'signOut', -> new Em.RSVP.resolve {}
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> auth.signOut()
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates canonicalized data to strategy#deserialize', ->
      sinon.collection.stub auth._response, 'canonicalize', -> {}
      spy = sinon.collection.spy auth._strategy, 'deserialize'
      Em.run -> auth.signOut()
      expect(spy).toHaveBeenCalledWith {}

    describe 'success', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'signOut', -> new Em.RSVP.resolve
        sinon.collection.stub auth._response, 'canonicalize', -> {}

      it 'delegates canonicalized data to session#end', ->
        spy = sinon.collection.spy auth._session, 'end'
        Em.run -> auth.signOut()
        expect(spy).toHaveBeenCalledWith {}

      it 'delegates data to registered `signOutSuccess` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'signOutSuccess', spy
        Em.run -> auth.signOut()
        expect(spy).toHaveBeenCalledWith {}

    describe 'error', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'signOut', -> new Em.RSVP.reject
        sinon.collection.stub auth._response, 'canonicalize', -> {}

      it 'delegates data to registered `signOutError` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'signOutError', spy
        Em.run -> auth.signOut()
        expect(spy).toHaveBeenCalledWith {}

  describe '#send', ->
    follow 'return promise', ->
      beforeEach -> @return = auth.send()

    it 'delegates to request#send', ->
      spy = sinon.collection.spy auth._request, 'send'
      Em.run -> auth.send 'foo', {}
      expect(spy).toHaveBeenCalledWith '/foo', {}

    describe '(url, opts) ->', ->
      it 'delegates url to request#resolveUrl', ->
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.send 'foo', {}
        expect(spy).toHaveBeenCalledWith 'foo'

    describe '(opts) ->', ->
      it 'delegates root url to request#resolveUrl', ->
        spy = sinon.collection.spy auth._request, 'resolveUrl'
        Em.run -> auth.send {}
        expect(spy).toHaveBeenCalledWith ''

    it 'delegates opts to strategy#serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      Em.run -> auth.send {}
      expect(spy).toHaveBeenCalledWith {}

    describe 'success', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'send', -> new Em.RSVP.resolve {}

      it 'delegates data to registered `sendSuccess` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'sendSuccess', spy
        Em.run -> auth.send()
        expect(spy).toHaveBeenCalledWith {}

    describe 'error', ->
      beforeEach ->
        sinon.collection.stub auth._request, 'send', -> new Em.RSVP.reject {}

      it 'delegates data to registered `sendError` handlers', ->
        spy = sinon.collection.spy { foo: -> }, 'foo'
        auth.addHandler 'sendError', spy
        Em.run -> auth.send()
        expect(spy).toHaveBeenCalledWith {}

  describe '#createSession', ->
    follow 'return promise', ->
      beforeEach -> @return = auth.createSession()

    it 'delegates data to response#canonicalize', ->
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> auth.createSession 'foo'
      expect(spy).toHaveBeenCalledWith 'foo'

    it 'delegates data to strategy#deserialize', ->
      sinon.collection.stub auth._response, 'canonicalize', -> {}
      spy = sinon.collection.spy auth._strategy, 'deserialize'
      Em.run -> auth.createSession 'foo'
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates data to session#start', ->
      spy = sinon.collection.spy auth._session, 'start'
      Em.run -> auth.createSession {}
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates data to registered `signInSuccess` handlers', ->
      spy = sinon.collection.spy { foo: -> }, 'foo'
      auth.addHandler 'signInSuccess', spy
      Em.run -> auth.createSession {}
      expect(spy).toHaveBeenCalledWith {}

  describe '#destroySession', ->
    follow 'return promise', ->
      beforeEach -> @return = auth.destroySession()

    it 'delegates data to response#canonicalize', ->
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> auth.destroySession 'foo'
      expect(spy).toHaveBeenCalledWith 'foo'

    it 'works with no arg', ->
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> auth.destroySession()
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates data to strategy#deserialize', ->
      sinon.collection.stub auth._response, 'canonicalize', -> {}
      spy = sinon.collection.spy auth._strategy, 'deserialize'
      Em.run -> auth.destroySession 'foo'
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates data to session#end', ->
      spy = sinon.collection.spy auth._session, 'end'
      Em.run -> auth.destroySession {}
      expect(spy).toHaveBeenCalledWith {}

    it 'delegates data to registered `signOutSuccess` handlers', ->
      spy = sinon.collection.spy { foo: -> }, 'foo'
      auth.addHandler 'signOutSuccess', spy
      Em.run -> auth.destroySession {}
      expect(spy).toHaveBeenCalledWith {}

  describe '#addHandler', ->
    it 'adds a handler to specified event type', ->
      handler = ->
      auth._handlers.foo = []
      auth.addHandler 'foo', handler
      expect(auth._handlers.foo).toEqual [handler]

  describe '#removeHandler', ->
    describe '(type, handler) ->', ->
      it 'removes the specified handler from specified event type', ->
        handler = ->
        otherHandler = ->
        auth._handlers.foo = [handler, otherHandler]
        auth.removeHandler 'foo', handler
        expect(auth._handlers.foo).toEqual [otherHandler]

    describe '(type) ->', ->
      it 'removes all handlers from specified event type', ->
        handler = ->
        otherHandler = ->
        auth._handlers.foo = [handler, otherHandler]
        auth.removeHandler 'foo'
        expect(auth._handlers.foo).toEqual []

  describe '#_ensurePromise', ->
    it 'wraps promise around arg if it is not a promise', ->
      expect(auth._ensurePromise('foo').then).toBeDefined()

    it 'passes through arg if it is a promise', ->
      promise = new Em.RSVP.resolve
      expect(auth._ensurePromise(promise)).toBe promise

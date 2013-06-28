describe 'Em.Auth', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create()
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  it 'supports events', -> expect(auth.on).toBeDefined()

  example 'auth initializer', (obj) ->
    klass = Em.String.classify obj

    it "initializes a #{obj}", ->
      spy = sinon.collection.spy Em.Auth[klass], 'create'
      auth = authTest.create()
      expect(spy).toHaveBeenCalledWithExactly { auth: auth }
      expect(auth.get("_#{obj}")).not.toBeNull()

    it "allows override with given #{obj}", ->
      sinon.collection.stub Em.Auth[klass], 'create', ->
      override = null
      Em.run ->
        override = Em.Auth[klass].create
        data = {}
        data["_#{obj}"] = override
        auth = authTest.create data
      expect(auth.get("_#{obj}")).toEqual override

  follow 'auth initializer', 'request'
  follow 'auth initializer', 'response'
  follow 'auth initializer', 'strategy'
  follow 'auth initializer', 'session'
  follow 'auth initializer', 'module'

  describe '#trigger', ->
    it 'triggers event', ->
      listener = { foo: -> }
      spy      = sinon.collection.spy listener, 'foo'
      auth.on 'foo', -> listener.foo()
      auth.trigger 'foo'
      expect(spy).toHaveBeenCalled()

    follow 'delegation', 'trigger', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth

  describe '#syncEvent', ->
    follow 'delegation', 'syncEvent', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth._request

    follow 'delegation', 'syncEvent', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth._response

    follow 'delegation', 'syncEvent', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth._strategy

    follow 'delegation', 'syncEvent', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth._session

    follow 'delegation', 'syncEvent', ['foo'], 'syncEvent', ['foo'], ->
      beforeEach -> @from = auth; @to = auth._module

  describe '#ensurePromise', ->

    describe 'callback returns promise', ->
      it "returns callback's promise", ->
        promise = Em.Deferred.create()
        ret = auth.ensurePromise -> promise
        expect(ret).toEqual promise

    describe 'callback does not return promise', ->
      it 'returns new promise', ->
        ret = auth.ensurePromise -> null
        expect(ret.then).toBeDefined()

  describe '#followPromise', ->

    it 'returns a promise', ->
      expect(auth.followPromise(null, ->)?.then).toBeDefined()

    describe 'other return is a promise', ->
      it 'executes callback only when promise resolves', ->
        promise = Em.Deferred.create()
        count = 0
        auth.followPromise promise, -> count++
        expect(count).toEqual 0
        Em.run -> promise.resolve promise
        expect(count).toEqual 1

    describe 'other return is not a promise', ->
      it 'executes callback immediately', ->
        count = 0
        auth.followPromise null, -> count++
        expect(count).toEqual 1

  describe '#wrapDeferred', ->
    it 'returns a promise', ->
      expect(auth.wrapDeferred(->).then).toBeDefined()

    it 'can resolve', ->
      promise = Em.Deferred.create()
      count = 0
      callback = (resolve) -> promise.then -> resolve()
      auth.wrapDeferred(callback).then -> count++
      expect(count).toEqual 0
      Em.run -> promise.resolve promise
      expect(count).toEqual 1

    it 'can reject', ->
      promise = Em.Deferred.create()
      count = 0
      callback = (resolve, reject) -> promise.then -> reject()
      auth.wrapDeferred(callback).then null, -> count++
      expect(count).toEqual 0
      Em.run -> promise.resolve promise
      expect(count).toEqual 1

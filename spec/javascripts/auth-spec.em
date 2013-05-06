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

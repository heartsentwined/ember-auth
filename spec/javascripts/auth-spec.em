describe 'Em.Auth', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = Em.Auth.create()
  afterEach ->
    auth.destroy() if auth
    auth = null
    sinon.collection.restore()

  it 'supports events', -> expect(auth.on).toBeDefined()

  example 'auth initializer', (obj) ->
    klass = Em.String.classify obj

    it "initializes a #{obj}", ->
      spy = sinon.collection.spy Em.Auth[klass], 'create'
      auth = Em.Auth.create()
      expect(spy).toHaveBeenCalledWithExactly { auth: auth }
      expect(auth.get("_#{obj}")).not.toBeNull()

    it "allows override with given #{obj}", ->
      sinon.collection.stub Em.Auth[klass], 'create', ->
      override = Em.Auth[klass].create
      data = {}
      data["_#{obj}"] = override
      auth = Em.Auth.create(data)
      expect(auth.get("_#{obj}")).toEqual override

  follow 'auth initializer', 'request'
  follow 'auth initializer', 'strategy'
  follow 'auth initializer', 'session'
  follow 'auth initializer', 'module'

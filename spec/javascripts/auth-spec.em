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
    it "initializes a #{obj}", ->
      spy = sinon.collection.spy Em.Auth[obj], 'create'
      auth = Em.Auth.create()
      expect(spy).toHaveBeenCalledWithExactly { auth: auth }

  follow 'auth initializer', 'Request'
  follow 'auth initializer', 'Strategy'
  follow 'auth initializer', 'Session'
  follow 'auth initializer', 'Module'

beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()
  sinon.collection.restore()

describe 'Em.Auth', =>
  it 'supports events', => expect(@auth.on).toBeDefined()

  example 'auth initializer', (obj) =>
    it "initializes a #{obj}", =>
      stub = sinon.collection.stub Em.Auth[obj], 'create'
      @auth = Em.Auth.create()
      expect(stub).toHaveBeenCalledWithExactly({ auth: @auth })

  follow 'auth initializer', 'Request'
  follow 'auth initializer', 'Strategy'
  follow 'auth initializer', 'Session'
  follow 'auth initializer', 'Module'

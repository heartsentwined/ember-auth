beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()
  sinon.collection.restore()

describe 'Ember.Auth', =>
  it 'supports events', => expect(@auth.on).toBeDefined()

  example 'request proxy method', (method) =>
    it "has proxy method for request##{method}", =>
      sinon.collection.stub @auth.request, method
      @auth[method]('foo')
      expect(@auth.request[method]).toHaveBeenCalledWithExactly('foo')

  follow 'request proxy method', 'signIn'
  follow 'request proxy method', 'signOut'
  follow 'request proxy method', 'ajax'

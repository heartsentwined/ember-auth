describe 'Em.Auth.Strategy', ->
  auth     = null
  spy      = null
  strategy = null

  beforeEach ->
    Em.run ->
      auth     = Em.Auth.create()
      strategy = auth._strategy
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'strategy'

  describe 'deserialize on signInSuccess', ->
    it '', ->
      follow 'events', auth, 'signInSuccess', strategy, 'deserialize'

  it '', ->
    follow 'adapter delegation', strategy, 'serialize', ['foo']

  # special treatment for deserialize
  describe '#deserialize', ->
    it 'delegates to adapter with auth.response property', ->
      spy = sinon.collection.spy strategy.adapter, 'deserialize'
      Em.run ->
        auth._response.response = 'foo'
        strategy.deserialize()
      expect(spy).toHaveBeenCalledWithExactly('foo')

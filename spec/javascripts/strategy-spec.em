describe 'Em.Auth.Strategy', ->
  auth     = null
  spy      = null
  strategy = null

  beforeEach ->
    auth = Em.Auth.create()
    strategy = auth._strategy
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'strategy'

  follow 'events', 'signInSuccess', 'deserialize', ->
    beforeEach -> @emitter = auth; @listener = strategy

  follow 'adapter delegation', 'serialize', ['foo'], ->
    beforeEach -> @type = strategy

  # special treatment for deserialize
  describe '#deserialize', ->
    it 'delegates to adapter with auth.response property', ->
      spy = sinon.collection.spy strategy.adapter, 'deserialize'
      Em.run ->
        auth._response.response = 'foo'
        strategy.deserialize()
      expect(spy).toHaveBeenCalledWithExactly('foo')

  follow 'adapter sync event', ->
    beforeEach -> @type = strategy

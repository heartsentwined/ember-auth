describe 'Em.Auth.Strategy', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = Em.Auth.create()
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'strategy'

  example 'delegation', (method) ->
    describe "##{method}", ->
      it 'delegates to adapter', ->
        spy = sinon.collection.spy auth.strategy.adapter, method
        auth.strategy[method]('foo')
        expect(spy).toHaveBeenCalledWithExactly('foo')

  follow 'delegation', 'serialize'
  follow 'delegation', 'deserialize'

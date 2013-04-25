describe 'Em.Auth.Strategy', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = Em.Auth.create()
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'strategy'

  it '', ->
    follow 'adapter delegation', auth.strategy, 'serialize', ['foo']
    follow 'adapter delegation', auth.strategy, 'deserialize', ['foo']

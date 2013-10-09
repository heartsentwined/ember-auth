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

  # nothing to test

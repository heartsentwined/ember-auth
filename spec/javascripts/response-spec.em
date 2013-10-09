describe 'Em.Auth.Response', ->
  auth     = null
  spy      = null
  response = null

  beforeEach ->
    auth = authTest.create()
    response = auth._response
  afterEach ->
    Em.run -> auth.destroy()
    sinon.collection.restore()

  # nothing to test

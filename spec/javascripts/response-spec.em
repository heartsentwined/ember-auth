describe 'Em.Auth.Response', ->
  auth     = null
  spy      = null
  response = null

  beforeEach ->
    Em.run ->
      auth     = Em.Auth.create { responseAdapter: 'dummy' }
      response = auth._response
  afterEach ->
    Em.run -> auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'response'

  describe '#canonicalize', ->
    it '', ->
      follow 'adapter delegation', response, 'canonicalize', ['foo']

    it 'sets responseData with canonicalize result', ->
      sinon.collection.stub response.adapter, 'canonicalize', (a) -> "_#{a}"
      Em.run -> response.canonicalize('foo')
      expect(response.response).toEqual '_foo'

  it '', ->
    follow 'property injection', response, auth, 'response'

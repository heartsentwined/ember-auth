describe 'Em.Auth.Response', ->
  auth     = null
  spy      = null
  response = null

  beforeEach ->
    auth     = Em.Auth.create { responseAdapter: 'dummy' }
    response = auth._response
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'response'

  describe '#canonicalize', ->
    it '', ->
      follow 'adapter delegation', response, 'canonicalize', ['foo']

    it 'sets responseData with canonicalize result', ->
      sinon.collection.stub response.adapter, 'canonicalize', (a) -> "_#{a}"
      response.canonicalize('foo')
      expect(response.response).toEqual '_foo'

  it '', ->
    follow 'property injection', response, auth, 'response'

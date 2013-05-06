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

  follow 'adapter init', 'response'

  describe '#canonicalize', ->
    follow 'adapter delegation', 'canonicalize', ['foo'], ->
      beforeEach -> @type = response

    it 'sets response with canonicalize result', ->
      sinon.collection.stub response.adapter, 'canonicalize', (a) -> "_#{a}"
      Em.run -> response.canonicalize('foo')
      expect(response.response).toEqual '_foo'

  follow 'property injection', 'response', ->
    beforeEach -> @from = response; @to = auth

  follow 'adapter sync event', ->
    beforeEach -> @type = response

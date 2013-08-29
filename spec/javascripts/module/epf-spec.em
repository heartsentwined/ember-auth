describe 'Em.Auth.Module.Epf', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create { modules: ['epf'] }
  afterEach ->
    auth.destroy() if auth

  describe 'Ep.RestAdapter patch', ->
    it 'replaces ajax with auth.request implementation', ->
      spy = sinon.collection.spy auth._request, 'send'
      adapter = null
      Em.run ->
        adapter = Ep.RestAdapter.create()
        adapter.ajax '/foo', 'POST', { foo: 'bar' }
      expect(spy).toHaveBeenCalledWithExactly
        url:     '/foo'
        type:    'POST'
        context: adapter
        foo:     'bar'

describe 'Em.Auth.Module.EmberData', ->
  auth = null
  spy  = null

  beforeEach ->
    Em.run ->
      auth = Em.Auth.create { responseAdapter: 'dummy', modules: ['emberData'] }
  afterEach ->
    auth.destroy() if auth

  describe 'DS.RESTAdapter patch', ->
    it 'replaces ajax with auth.request implementation', ->
      spy = sinon.collection.spy auth._request, 'send'
      adapter = null
      Em.run ->
        adapter = DS.RESTAdapter.create()
        adapter.ajax '/foo', 'POST', { foo: 'bar' }
      expect(spy).toHaveBeenCalledWithExactly
        url:     '/foo'
        type:    'POST'
        context: adapter
        foo:     'bar'

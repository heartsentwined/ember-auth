describe 'Em.Auth.Module.EmberModel', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create { modules: ['emberModel'] }
  afterEach ->
    auth.destroy() if auth

  describe 'Ember.RESTAdapter patch', ->
    it 'replaces ajax with auth.request implementation', ->
      spy = sinon.collection.spy auth._request, 'send'
      adapter = null
      Em.run ->
        adapter = Ember.RESTAdapter.create()
        adapter.ajax '/foo'
      expect(spy).toHaveBeenCalled()

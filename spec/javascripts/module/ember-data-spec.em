describe 'Em.Auth.Module.EmberData', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create { modules: ['emberData'] }
  afterEach ->
    auth.destroy() if auth

  describe 'DS.RESTAdapter patch', ->
    it 'delegates to strategy.serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      adapter = null
      Em.run ->
        adapter = DS.RESTAdapter.create()
        adapter.ajax '/foo', 'POST', 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

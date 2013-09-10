describe 'Em.Auth.Module.Epf', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create { modules: ['epf'] }
  afterEach ->
    auth.destroy() if auth

  describe 'Ep.RestAdapter patch', ->
    it 'delegates to strategy.serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      adapter = null
      Em.run ->
        adapter = Ep.RestAdapter.create()
        adapter.ajax '/foo', 'POST', 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

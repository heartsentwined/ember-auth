describe 'Em.Auth.EmberModelAuthModule', ->
  auth = null
  spy  = null
  emberModel = null
  foo = null

  beforeEach ->
    auth = authTest.create { modules: ['emberModel'] }
    emberModel = auth.module.emberModel
    foo = { fetch: -> new Em.RSVP.resolve }
  afterEach ->
    auth.destroy() if auth

  follow 'property injection', 'user', ->
    beforeEach -> @from = emberModel; @to = auth

  describe '#findUser', ->
    beforeEach -> spy = sinon.collection.spy foo, 'fetch'

    afterEach ->
      Em.run ->
        auth.userId = null
        auth.emberModel.userModel = null

    describe 'userId not set', ->
      beforeEach -> Em.run -> auth.userId = null

      it 'does nothing', ->
        Em.run -> emberModel.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userModel not set', ->
      beforeEach -> Em.run -> auth.emberModel.userModel = null

      it 'does nothing', ->
        Em.run -> emberModel.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userId set', ->
      beforeEach -> Em.run -> auth.userId = 1

      describe 'userModel set', ->
        beforeEach ->
          Em.run ->
            auth.emberModel.userModel = 'foo'
            sinon.collection.stub Em, 'get', -> foo

        it 'delegates to (user model)#fetch', ->
          Em.run -> emberModel.findUser()
          expect(spy).toHaveBeenCalledWith 'foo', 1

  describe 'Ember.RESTAdapter patch', ->
    it 'delegates to strategy.serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      adapter = null
      Em.run ->
        adapter = Ember.RESTAdapter.create()
        adapter.ajax '/foo', {}, 'POST', 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

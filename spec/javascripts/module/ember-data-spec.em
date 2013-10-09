describe 'Em.Auth.EmberDataAuthModule', ->
  auth = null
  spy  = null
  emberData = null

  beforeEach ->
    auth = authTest.create { modules: ['emberData'] }
    emberData = auth.module.emberData
    emberData.store = { find: -> new Em.RSVP.resolve }
  afterEach ->
    auth.destroy() if auth

  follow 'property injection', 'user', ->
    beforeEach -> @from = emberData; @to = auth

  describe '#findUser', ->
    beforeEach -> spy = sinon.collection.spy emberData.store, 'find'

    afterEach ->
      Em.run ->
        auth.userId = null
        auth.emberData.userModel = null

    describe 'userId not set', ->
      beforeEach -> Em.run -> auth.userId = null

      it 'does nothing', ->
        Em.run -> emberData.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userModel not set', ->
      beforeEach -> Em.run -> auth.emberData.userModel = null

      it 'does nothing', ->
        Em.run -> emberData.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userId set', ->
      beforeEach -> Em.run -> auth.userId = 1

      describe 'userModel set', ->
        beforeEach -> Em.run -> auth.emberData.userModel = 'foo'

        it 'delegates to store#find', ->
          Em.run -> emberData.findUser()
          expect(spy).toHaveBeenCalledWith 'foo', 1

  describe 'DS.RESTAdapter patch', ->
    it 'delegates to strategy.serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      adapter = null
      Em.run ->
        adapter = DS.RESTAdapter.create()
        adapter.ajax '/foo', 'POST', 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

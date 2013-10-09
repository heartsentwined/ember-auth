describe 'Em.Auth.EpfAuthModule', ->
  auth = null
  spy  = null
  epf = null

  beforeEach ->
    auth = authTest.create { modules: ['epf'] }
    epf = auth.module.epf
    epf.session = { load: -> new Em.RSVP.resolve }
  afterEach ->
    auth.destroy() if auth

  follow 'property injection', 'user', ->
    beforeEach -> @from = epf; @to = auth

  describe '#findUser', ->
    beforeEach -> spy = sinon.collection.spy epf.session, 'load'

    afterEach ->
      Em.run ->
        auth.userId = null
        auth.epf.userModel = null

    describe 'userId not set', ->
      beforeEach -> Em.run -> auth.userId = null

      it 'does nothing', ->
        Em.run -> epf.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userModel not set', ->
      beforeEach -> Em.run -> auth.epf.userModel = null

      it 'does nothing', ->
        Em.run -> epf.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'userId set', ->
      beforeEach -> Em.run -> auth.userId = 1

      describe 'userModel set', ->
        beforeEach -> Em.run -> auth.epf.userModel = 'foo'

        it 'delegates to session#load', ->
          Em.run -> epf.findUser()
          expect(spy).toHaveBeenCalledWith 'foo', 1

  describe 'Ep.RestAdapter patch', ->
    it 'delegates to strategy.serialize', ->
      spy = sinon.collection.spy auth._strategy, 'serialize'
      adapter = null
      Em.run ->
        adapter = Ep.RestAdapter.create()
        adapter.ajax '/foo', 'POST', 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

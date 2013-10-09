describe 'Em.Auth.RememberableAuthModule', ->
  auth         = null
  spy          = null
  rememberable = null

  beforeEach ->
    auth = authTest.create { modules: ['rememberable'] }
    rememberable = auth.module.rememberable
  afterEach ->
    # for some reason, if we destroy() it, it will break other suites
    #auth.destroy() if auth
    sinon.collection.restore()

  describe '#recall', ->
    beforeEach ->
      spy = sinon.collection.spy auth, 'signIn'

    follow 'return promise', ->
      beforeEach -> @return = rememberable.recall()

    describe 'signed in', ->
      beforeEach -> Em.run -> auth._session.start()

      it 'does nothing', ->
        Em.run -> rememberable.recall()
        expect(spy).not.toHaveBeenCalled()

    describe 'retrieveToken fails', ->
      beforeEach ->
        sinon.collection.stub rememberable, 'retrieveToken', -> null

      it 'does nothing', ->
        Em.run -> rememberable.recall()
        expect(spy).not.toHaveBeenCalled()

    describe 'not signed in', ->
      beforeEach -> Em.run -> auth._session.end()

      describe 'retrieveToken succeeds', ->
        beforeEach ->
          Em.run -> auth.rememberable.tokenKey = 'key'
          sinon.collection.stub rememberable, 'retrieveToken', -> 'foo'

        afterEach -> Em.run -> auth.rememberable.endPoint = null

        describe 'endPoint set', ->
          beforeEach -> Em.run -> auth.rememberable.endPoint = 'bar'

          it 'calls signIn', ->
            Em.run -> rememberable.recall()
            expect(spy) \
            .toHaveBeenCalledWithExactly '/bar', { data: { key: 'foo' } }

        describe 'endPoint not set', ->
          it 'calls signIn', ->
            Em.run -> rememberable.recall()
            expect(spy).toHaveBeenCalledWithExactly { data: { key: 'foo' } }

        it 'is customizable', ->
          Em.run -> rememberable.recall { foo: 'bar' }
          expect(spy).toHaveBeenCalledWithExactly
            foo: 'bar'
            data: { key: 'foo' }

  describe '#remember', ->
    storeTokenSpy = null
    forgetSpy     = null

    beforeEach ->
      storeTokenSpy = sinon.collection.spy rememberable, 'storeToken'
      forgetSpy     = sinon.collection.spy rememberable, 'forget'
      Em.run -> auth.rememberable.tokenKey = 'key'

    it 'delegates to #forget', ->
      Em.run -> rememberable.remember {}
      expect(forgetSpy).toHaveBeenCalled()

    describe 'remember token found from response', ->

      describe 'same as existing token', ->
        beforeEach ->
          sinon.collection.stub rememberable, 'retrieveToken', -> 'foo'

        it 'does nothing', ->
          Em.run -> rememberable.remember { key: 'foo' }
          expect(storeTokenSpy).not.toHaveBeenCalled()

      describe 'different from existing token', ->
        beforeEach ->
          sinon.collection.stub rememberable, 'retrieveToken', -> 'bar'

        it 'delegates to #storeToken', ->
          Em.run -> rememberable.remember { key: 'foo' }
          expect(storeTokenSpy).toHaveBeenCalledWithExactly('foo')

    describe 'remember token unavailable', ->

      it 'does nothing', ->
        Em.run -> rememberable.remember {}
        expect(storeTokenSpy).not.toHaveBeenCalled()

  follow 'delegation', 'forget', [], 'removeToken', [], ->
    beforeEach -> @from = rememberable; @to = rememberable

  follow 'delegation', 'retrieveToken', [], \
  'retrieve', ['ember-auth-rememberable'], ->
    beforeEach -> @from = rememberable; @to = auth._session

  follow 'delegation', 'storeToken', ['foo'], \
  'store', ['ember-auth-rememberable', 'foo', { expires: 1 }], ->
    beforeEach ->
      @from = rememberable; @to = auth._session
      Em.run -> auth.rememberable.period = 1

  follow 'delegation', 'removeToken', [], \
  'remove', ['ember-auth-rememberable'], ->
    beforeEach -> @from = rememberable; @to = auth._session

  xdescribe 'auto recall', ->
    beforeEach ->
      appTest.create (app) ->
        app.Auth = authTest.create { modules: ['rememberable'] }
        app.Router.map -> @route 'foo'
        app.FooRoute = Em.Route.extend()
        spy = sinon.collection.spy app.Auth.module.rememberable, 'recall'
    afterEach ->
      appTest.destroy()

    describe 'autoRecall = false', ->
      beforeEach ->
        appTest.run (app) -> app.Auth.rememberable.autoRecall = false

      it 'does not recall session', ->
        appTest.ready()
        appTest.toRoute 'foo'
        expect(spy).not.toHaveBeenCalled()

    describe 'signed in', ->
      beforeEach -> appTest.run (app) -> app.Auth._session.start()

      it 'does not recall session', ->
        appTest.ready()
        appTest.toRoute 'foo'
        expect(spy).not.toHaveBeenCalled()

    describe 'autoRecall = true', ->
      beforeEach ->
        appTest.run (app) -> app.Auth.rememberable.autoRecall = true

      describe 'not signed in', ->
        beforeEach -> appTest.run (app) -> app.Auth._session.clear()

        it 'recalls session', ->
          appTest.ready()
          appTest.toRoute 'foo'
          expect(spy).toHaveBeenCalled()

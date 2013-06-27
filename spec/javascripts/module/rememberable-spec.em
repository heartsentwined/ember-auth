describe 'Em.Auth.Module.Rememberable', ->
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

  follow 'events', 'signInSuccess', 'remember', ->
    beforeEach -> @emitter = auth; @listener = rememberable
  follow 'events', 'signInError', 'forget', ->
    beforeEach -> @emitter = auth; @listener = rememberable
  follow 'events', 'signOutSuccess', 'forget', ->
    beforeEach -> @emitter = auth; @listener = rememberable

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
      beforeEach -> Em.run -> auth._session.clear()

      describe 'retrieveToken succeeds', ->
        beforeEach ->
          Em.run -> auth.rememberable.tokenKey = 'key'
          sinon.collection.stub rememberable, 'retrieveToken', -> 'foo'

        it 'calls signIn', ->
          Em.run -> rememberable.recall()
          expect(spy).toHaveBeenCalledWithExactly { data: { key: 'foo' } }

        it 'is customizable', ->
          Em.run -> rememberable.recall { foo: 'bar' }
          expect(spy).toHaveBeenCalledWithExactly
            foo: 'bar'
            data: { key: 'foo' }

        it 'marks sign in as originating from recall', ->
          Em.run -> rememberable.recall()
          expect(rememberable.fromRecall).toBeTruthy()

  describe '#remember', ->
    storeTokenSpy = null
    forgetSpy     = null

    beforeEach ->
      storeTokenSpy = sinon.collection.spy rememberable, 'storeToken'
      forgetSpy     = sinon.collection.spy rememberable, 'forget'
      Em.run -> auth.rememberable.tokenKey = 'key'

    it 'resets fromRecall marker', ->
      Em.run -> rememberable.remember()
      expect(rememberable.fromRecall).toBeFalsy()

    describe 'remember token found from response', ->
      beforeEach -> Em.run -> auth._response.response = { key: 'foo' }

      describe 'same as existing token', ->
        beforeEach ->
          sinon.collection.stub rememberable, 'retrieveToken', -> 'foo'

        it 'does nothing', ->
          Em.run -> rememberable.remember()
          expect(storeTokenSpy).not.toHaveBeenCalled()
          expect(forgetSpy).not.toHaveBeenCalled()

      describe 'different from existing token', ->
        beforeEach ->
          sinon.collection.stub rememberable, 'retrieveToken', -> 'bar'

        it 'delegates to #storeToken', ->
          Em.run -> rememberable.remember()
          expect(storeTokenSpy).toHaveBeenCalledWithExactly('foo')

        it 'does not forget', ->
          Em.run -> rememberable.remember()
          expect(forgetSpy).not.toHaveBeenCalled()

    describe 'remember token unavailable', ->
      beforeEach -> Em.run -> auth._response.response = {}

      describe 'sign in originating from recall', ->
        beforeEach -> Em.run -> rememberable.fromRecall = true

        it 'does nothing', ->
          Em.run -> rememberable.remember()
          expect(storeTokenSpy).not.toHaveBeenCalled()
          expect(forgetSpy).not.toHaveBeenCalled()

      describe 'sign in not originating from recall', ->
        beforeEach -> Em.run -> rememberable.fromRecall = false

        it 'delegates to #forget', ->
          Em.run -> rememberable.remember()
          expect(forgetSpy).toHaveBeenCalled()

        it 'does not store token', ->
          Em.run -> rememberable.remember()
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

  describe 'auto recall', ->
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

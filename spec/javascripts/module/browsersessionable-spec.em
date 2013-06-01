describe 'Em.Auth.Module.Browsersessionable', ->
  auth         = null
  spy          = null
  browsersessionable = null

  beforeEach ->
    auth = authTest.create { modules: ['browsersessionable'] }
    browsersessionable = auth.module.browsersessionable
  afterEach ->
    # for some reason, if we destroy() it, it will break other suites
    #auth.destroy() if auth
    sinon.collection.restore()

  follow 'events', 'signInSuccess', 'remember', ->
    beforeEach -> @emitter = auth; @listener = browsersessionable
  follow 'events', 'signInError', 'forget', ->
    beforeEach -> @emitter = auth; @listener = browsersessionable
  follow 'events', 'signOutSuccess', 'forget', ->
    beforeEach -> @emitter = auth; @listener = browsersessionable

  describe '#recall', ->
    beforeEach ->
      spy = sinon.collection.spy auth, 'signIn'

    describe 'signed in', ->
      beforeEach -> Em.run -> auth._session.start()

      it 'does nothing', ->
        Em.run -> browsersessionable.recall()
        expect(spy).not.toHaveBeenCalled()

    describe 'retrieveToken fails', ->
      beforeEach ->
        sinon.collection.stub browsersessionable, 'retrieveToken', -> null

      it 'does nothing', ->
        Em.run -> browsersessionable.recall()
        expect(spy).not.toHaveBeenCalled()

    describe 'not signed in', ->
      beforeEach -> Em.run -> auth._session.clear()

      describe 'retrieveToken succeeds', ->
        beforeEach ->
          Em.run -> auth.browsersessionable.tokenKey = 'key'
          sinon.collection.stub browsersessionable, 'retrieveToken', -> 'foo'

        it 'calls signIn', ->
          Em.run -> browsersessionable.recall()
          expect(spy).toHaveBeenCalledWithExactly { data: { key: 'foo' } }

        it 'is customizable', ->
          Em.run -> browsersessionable.recall { foo: 'bar' }
          expect(spy).toHaveBeenCalledWithExactly
            foo: 'bar'
            data: { key: 'foo' }

        it 'marks sign in as originating from recall', ->
          Em.run -> browsersessionable.recall()
          expect(browsersessionable.fromRecall).toBeTruthy()

  describe '#browsersession', ->
    storeTokenSpy = null
    forgetSpy     = null

    beforeEach ->
      storeTokenSpy = sinon.collection.spy browsersessionable, 'storeSessionToken'
      forgetSpy     = sinon.collection.spy browsersessionable, 'deleteSessionToken'
      Em.run -> auth.rememberable.tokenKey = 'key'

    it 'resets fromRecall marker', ->
      Em.run -> browsersessionable.storeSessionToken()
      expect(browsersessionable.fromRecall).toBeFalsy()

    describe 'browsersession token found from response', ->
      beforeEach -> Em.run -> auth._response.response = { key: 'foo' }

      describe 'same as existing token', ->
        beforeEach ->
          sinon.collection.stub browsersessionable, 'retrieveToken', -> 'foo'

        it 'does nothing', ->
          Em.run -> browsersessionable.storeSessionToken()
          expect(storeTokenSpy).not.toHaveBeenCalled()
          expect(forgetSpy).not.toHaveBeenCalled()

      describe 'different from existing token', ->
        beforeEach ->
          sinon.collection.stub browsersessionable, 'retrieveToken', -> 'bar'

        it 'delegates to #storeToken', ->
          Em.run -> browsersessionable.storeSessionToken()
          expect(storeTokenSpy).toHaveBeenCalledWithExactly('foo')

        it 'does not forget', ->
          Em.run -> browsersessionable.storeSessionToken()
          expect(forgetSpy).not.toHaveBeenCalled()

    describe 'session token unavailable', ->
      beforeEach -> Em.run -> auth._response.response = {}

      describe 'sign in originating from recall', ->
        beforeEach -> Em.run -> browsersessionable.fromRecall = true

        it 'does nothing', ->
          Em.run -> browsersessionable.remember()
          expect(storeTokenSpy).not.toHaveBeenCalled()
          expect(forgetSpy).not.toHaveBeenCalled()

      describe 'sign in not originating from recall', ->
        beforeEach -> Em.run -> browsersessionable.fromRecall = false

        it 'delegates to #forget', ->
          Em.run -> browsersessionable.storeSessionToken()
          expect(forgetSpy).toHaveBeenCalled()

        it 'does not store token', ->
          Em.run -> browsersessionable.storeSessionToken()
          expect(storeTokenSpy).not.toHaveBeenCalled()

  follow 'delegation', 'forget', [], 'removeToken', [], ->
    beforeEach -> @from = browsersessionable; @to = browsersessionable

  follow 'delegation', 'retrieveToken', [], \
  'retrieve', ['ember-auth-session'], ->
    beforeEach -> @from = browsersessionable; @to = auth._session

  follow 'delegation', 'storeToken', ['foo'], \
  'store', ['ember-auth-session', 'foo'], ->
    beforeEach ->
      @from = browsersessionable; @to = auth._session

  follow 'delegation', 'removeToken', [], \
  'remove', ['ember-auth-session'], ->
    beforeEach -> @from = browsersessionable; @to = auth._session

  describe 'auto recall', ->
    beforeEach ->
      appTest.create (app) ->
        app.Auth = authTest.create { modules: ['browsersessionable'] }
        app.Router.map -> @route 'foo'
        app.FooRoute = Em.Route.extend()
        spy = sinon.collection.spy app.Auth.module.browsersessionable, 'recall'
    afterEach ->
      appTest.destroy()

    describe 'autoRecall = false', ->
      beforeEach ->
        appTest.run (app) -> app.Auth.browsersessionable.autoRecall = false

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
        appTest.run (app) -> app.Auth.browsersessionable.autoRecall = true

      describe 'not signed in', ->
        beforeEach -> appTest.run (app) -> app.Auth._session.clear()

        it 'recalls session', ->
          appTest.ready()
          appTest.toRoute 'foo'
          expect(spy).toHaveBeenCalledWithExactly { async: false }

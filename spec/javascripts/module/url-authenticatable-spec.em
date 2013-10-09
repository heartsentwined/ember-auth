describe 'Em.Auth.UrlAuthenticatableAuthModule', ->
  auth    = null
  spy     = null
  urlAuth = null

  beforeEach ->
    auth = authTest.create { modules: ['urlAuthenticatable'] }
    urlAuth = auth.module.urlAuthenticatable
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe '#authenticate', ->
    beforeEach -> spy = sinon.collection.spy auth, 'signIn'

    follow 'return promise', ->
      beforeEach -> @return = urlAuth.authenticate {}

    describe 'signed in', ->
      beforeEach -> Em.run -> auth._session.start()

      it 'does nothing', ->
        Em.run -> urlAuth.authenticate {}
        expect(spy).not.toHaveBeenCalled()

    describe 'not signed in', ->
      beforeEach -> Em.run -> auth._session.end()

      describe 'params empty', ->

        it 'does nothing', ->
          Em.run -> urlAuth.authenticate {}
          expect(spy).not.toHaveBeenCalled()

      describe 'params not empty', ->
        beforeEach -> Em.run -> auth.urlAuthenticatable.params = ['foo']

        afterEach ->
          Em.run ->
            auth.urlAuthenticatable.params   = []
            auth.urlAuthenticatable.endPoint = null

        describe 'opts not given', ->

          describe 'endPoint set', ->
            beforeEach -> Em.run -> auth.urlAuthenticatable.endPoint = 'bar'

            it 'delegates to auth.signIn with params as data', ->
              Em.run -> urlAuth.authenticate { foo: 'bar' }
              expect(spy) \
              .toHaveBeenCalledWithExactly 'bar', { data: { foo: 'bar' } }

          describe 'endPoint not set', ->

            it 'delegates to auth.signIn with params as data', ->
              Em.run -> urlAuth.authenticate { foo: 'bar' }
              expect(spy).toHaveBeenCalledWithExactly { data: { foo: 'bar' } }

        describe 'opts given', ->

          it 'lets opts.data override params', ->
            Em.run -> urlAuth.authenticate \
            { foo: 'bar' }, { data: { foo: 'baz' } }
            expect(spy).toHaveBeenCalledWithExactly { data: { foo: 'baz' } }

  describe 'auto authenticate', ->
    beforeEach ->
      appTest.create (app) ->
        app.Router.map -> @route 'foo', { queryParams: ['foo'] }
        app.FooRoute = Em.Route.extend()
        app.Auth = authTest.extend
          container: app.__container__
          modules: ['urlAuthenticatable']
          urlAuthenticatable:
            params:  ['foo']
    afterEach ->
      appTest.destroy()

    it 'auto authenticate on any route entry', ->
      spy = sinon.collection.spy urlAuth, 'authenticate'
      appTest.ready()
      appTest.toRoute 'foo', { queryParams: { foo: 'bar' } }
      expect(spy).toHaveBeenCalled()

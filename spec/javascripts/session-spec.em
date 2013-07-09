describe 'Em.Auth.Session', ->
  auth    = null
  spy     = null
  session = null

  beforeEach ->
    auth    = authTest.create()
    session = auth._session
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  follow 'adapter init', 'session'

  follow 'adapter delegation', 'retrieve', ['foo', 'bar'], ->
    beforeEach -> @type = session
  follow 'adapter delegation', 'store', ['foo', 'bar', 'baz'], ->
    beforeEach -> @type = session
  follow 'adapter delegation', 'remove', ['foo', 'bar'], ->
    beforeEach -> @type = session

  follow 'property injection', 'signedIn', ->
    beforeEach -> @from = session; @to = auth
  follow 'property injection', 'userId', ->
    beforeEach -> @from = session; @to = auth
  follow 'property injection', 'user', ->
    beforeEach -> @from = session; @to = auth
  follow 'property injection', 'startTime', ->
    beforeEach -> @from = session; @to = auth
  follow 'property injection', 'endTime', ->
    beforeEach -> @from = session; @to = auth

  follow 'events', 'signInSuccess', 'start', ->
    beforeEach -> @emitter = auth; @listener = session
  follow 'events', 'signInSuccess', 'findUser', ->
    beforeEach -> @emitter = auth; @listener = session
  follow 'events', 'signOutSuccess', 'clear', ->
    beforeEach -> @emitter = auth; @listener = session

  describe '#findUser', ->
    model = { find: -> }
    beforeEach ->
      spy = sinon.collection.spy model, 'find'

    describe 'not signed in', ->
      beforeEach -> Em.run -> session.clear()

      it 'does nothing', ->
        Em.run -> session.findUser()
        expect(spy).not.toHaveBeenCalled()

    describe 'signed in', ->
      beforeEach -> Em.run -> session.start()

      describe 'userId not set', ->
        beforeEach -> Em.run -> session.userId = null

        it 'does nothing', ->
          Em.run -> session.findUser()
          expect(spy).not.toHaveBeenCalled()

      describe 'userId set', ->
        beforeEach -> Em.run -> session.userId = 1

        describe 'userModel not set', ->
          it 'does nothing', ->
            Em.run -> session.findUser()
            expect(spy).not.toHaveBeenCalled()

        describe 'userModel set', ->
          it 'delegates to .find()', ->
            sinon.collection.stub Ember, 'get', -> model
            Em.run ->
              auth.userModel = 'Foo'
              session.findUser()
            expect(spy).toHaveBeenCalledWithExactly(1)

  describe '#start', ->
    it 'sets signedIn', ->
      expect(session.signedIn).toBeFalsy()
      Em.run -> session.start()
      expect(session.signedIn).toBeTruthy()

    it 'sets startTime', ->
      expect(session.startTime).toEqual null
      Em.run -> session.start()
      expect(session.startTime instanceof Date).toBeTruthy()

    it 'clears endTime', ->
      Em.run -> session.endTime = new Date()
      expect(session.endTime).toBeTruthy()
      Em.run -> session.start()
      expect(session.endTime).toBeFalsy()

  describe '#clear', ->
    it 'sets endTime', ->
      Em.run -> session.endTime = null
      expect(session.endTime).toBeFalsy()
      Em.run -> session.clear()
      expect(session.endTime instanceof Date).toBeTruthy()

    example 'session data clearance', (property) ->
      it "clears #{property}", ->
        Em.run -> session.set property, 'foo'
        expect(session.get(property)).toEqual 'foo'
        Em.run -> session.clear()
        expect(session.get(property)).toBeFalsy()

    follow 'session data clearance', 'signedIn'
    follow 'session data clearance', 'userId'
    follow 'session data clearance', 'user'
    follow 'session data clearance', 'startTime'

  example 'manual session methods', (method, event) ->
    it "injects to Auth as #{method}Session", ->
      expect(auth["#{method}Session"]).toBeDefined()

    it 'delegates to session method', ->
      spy = sinon.collection.spy session, method
      Em.run -> auth["#{method}Session"]()
      expect(session[method]).toHaveBeenCalled()

    it "triggers #{event}", ->
      spy = sinon.collection.spy auth, 'trigger'
      Em.run -> session[method]()
      expect(spy).toHaveBeenCalledWithExactly event

  describe '#create', ->
    follow 'manual session methods', 'create', 'signInSuccess'

    it 'delegates to response#canonicalize', ->
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> session.create 'foo'
      expect(spy).toHaveBeenCalledWithExactly 'foo'

  describe '#destroy', ->
    follow 'manual session methods', 'destroy', 'signOutSuccess'

    it 'calls response#canonicalize with empty string', ->
      spy = sinon.collection.spy auth._response, 'canonicalize'
      Em.run -> session.destroy()
      expect(spy).toHaveBeenCalledWithExactly ''

  follow 'adapter sync event', ->
    beforeEach -> @type = session

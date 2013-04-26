describe 'Em.Auth.Session', ->
  auth    = null
  spy     = null
  session = null

  beforeEach ->
    Em.run ->
      auth    = Em.Auth.create()
      session = auth._session
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  follow 'adapter init', 'session'

  it '', ->
    follow 'adapter delegation', session, 'retrieve', ['foo', 'bar']
    follow 'adapter delegation', session, 'store', ['foo', 'bar', 'baz']
    follow 'adapter delegation', session, 'remove', ['foo', 'bar']

  it 'injects signedIn', ->
    follow 'property injection', session, auth, 'signedIn'
  it 'injects userId', ->
    follow 'property injection', session, auth, 'userId'
  it 'injects user', ->
    follow 'property injection', session, auth, 'user'

  describe 'start on signInSuccess', ->
    it '', ->
      follow 'events', auth, 'signInSuccess', session, 'start'

  describe 'findUser on signInSuccess', ->
    it '', ->
      follow 'events', auth, 'signInSuccess', session, 'findUser'

  describe 'clear on signOutSuccess', ->
    it '', ->
      follow 'events', auth, 'signOutSuccess', session, 'clear'

  describe '#findUser', ->
    model = { find: -> }

    beforeEach ->
      Em.run -> session.userId = 1
      spy = sinon.collection.spy model, 'find'

    describe 'userModel set', ->
      it 'delegates to .find()', ->
        Em.run ->
          auth.userModel = model
          session.findUser()
        expect(spy).toHaveBeenCalledWithExactly(1)

    describe 'userModel not set', ->
      it 'does nothing', ->
        Em.run -> session.findUser()
        expect(spy).not.toHaveBeenCalled()

  describe '#start', ->
    it 'sets signedIn', ->
      expect(session.signedIn).toBeFalsy()
      Em.run -> session.start()
      expect(session.signedIn).toBeTruthy()

  describe '#clear', ->
    example 'session data clearance', (property) ->
      it "clears #{property}", ->
        Em.run -> session.set property, 'foo'
        expect(session.get(property)).toEqual 'foo'
        Em.run -> session.clear()
        expect(session.get(property)).toBeFalsy()

    follow 'session data clearance', 'signedIn'
    follow 'session data clearance', 'userId'
    follow 'session data clearance', 'user'

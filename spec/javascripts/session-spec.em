describe 'Em.Auth.Session', ->
  auth    = null
  spy     = null
  session = null

  beforeEach ->
    auth    = Em.Auth.create()
    session = auth._session
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'session'

  it '', ->
    follow 'adapter delegation', session, 'retrieve', ['foo', 'bar']
    follow 'adapter delegation', session, 'store', ['foo', 'bar', 'baz']
    follow 'adapter delegation', session, 'remove', ['foo', 'bar']

  it '', ->
    follow 'property injection', session, auth, 'authToken'
    follow 'property injection', session, auth, 'userId'
    follow 'property injection', session, auth, 'user'

  describe '#findUser', ->
    model = { find: -> }

    beforeEach ->
      session.userId = 1
      spy = sinon.collection.spy model, 'find'

    describe 'userModel set', ->
      it 'delegates to .find()', ->
        auth.userModel = model
        session.findUser()
        expect(spy).toHaveBeenCalledWithExactly(1)

    describe 'userModel not set', ->
      it 'does nothing', ->
        session.findUser()
        expect(spy).not.toHaveBeenCalled()

  describe '#clear', ->
    example 'session data clearance', (property) ->
      it "clears #{property}", ->
        session.set property, 'foo'
        expect(session.get(property)).toEqual 'foo'
        session.clear()
        expect(session.get(property)).toBeNull()

    follow 'session data clearance', 'authToken'
    follow 'session data clearance', 'userId'
    follow 'session data clearance', 'user'

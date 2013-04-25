describe 'Em.Auth.Session', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = Em.Auth.create()
  afterEach ->
    auth.destroy()
    sinon.collection.restore()

  follow 'adapter init', 'session'

  it '', ->
    follow 'adapter delegation', auth.session, 'retrieve', ['foo', 'bar']
    follow 'adapter delegation', auth.session, 'store', ['foo', 'bar', 'baz']
    follow 'adapter delegation', auth.session, 'remove', ['foo', 'bar']

  it '', ->
    follow 'property injection', auth.session, auth, 'authToken'
    follow 'property injection', auth.session, auth, 'currentUserId'
    follow 'property injection', auth.session, auth, 'currentUser'

  describe '#findUser', ->
    model = { find: -> }

    beforeEach ->
      auth.session.currentUserId = 1
      spy = sinon.collection.spy model, 'find'

    describe 'userModel set', ->
      it 'delegates to .find()', ->
        auth.userModel = model
        auth.session.findUser()
        expect(spy).toHaveBeenCalledWithExactly(1)

    describe 'userModel not set', ->
      it 'does nothing', ->
        auth.session.findUser()
        expect(spy).not.toHaveBeenCalled()

  describe '#clear', ->
    example 'session data clearance', (property) ->
      it "clears #{property}", ->
        auth.session.set property, 'foo'
        expect(auth.session.get(property)).toEqual 'foo'
        auth.session.clear()
        expect(auth.session.get(property)).toBeNull()

    follow 'session data clearance', 'authToken'
    follow 'session data clearance', 'currentUserId'
    follow 'session data clearance', 'currentUser'

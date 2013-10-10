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

  follow 'property alias', 'signedIn', ->
    beforeEach -> @from = session; @to = auth
  follow 'property alias', 'userId', ->
    beforeEach -> @from = session; @to = auth
  follow 'property alias', 'startTime', ->
    beforeEach -> @from = session; @to = auth
  follow 'property alias', 'endTime', ->
    beforeEach -> @from = session; @to = auth

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

  describe '#end', ->
    it 'sets endTime', ->
      Em.run -> session.endTime = null
      expect(session.endTime).toBeFalsy()
      Em.run -> session.end()
      expect(session.endTime instanceof Date).toBeTruthy()

    example 'session data clearance', (property) ->
      it "clears #{property}", ->
        Em.run -> session.set property, 'foo'
        expect(session.get(property)).toEqual 'foo'
        Em.run -> session.end()
        expect(session.get(property)).toBeFalsy()

    follow 'session data clearance', 'signedIn'
    follow 'session data clearance', 'userId'
    follow 'session data clearance', 'startTime'

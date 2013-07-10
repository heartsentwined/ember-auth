describe 'Em.Auth.Module.Timeoutable', ->
  auth        = null
  spy         = null
  timeoutable = null

  beforeEach ->
    auth = authTest.create { modules: ['timeoutable'] }
    timeoutable = auth.module.timeoutable
  afterEach ->
    auth.destroy() if auth
    sinon.collection.restore()

  describe 'config.callback', ->
    it 'defaults to auth.signOut()', ->
      spy = sinon.collection.spy auth, 'signOut'
      Em.run -> auth.timeoutable.callback()
      expect(spy).toHaveBeenCalled()

  follow 'events', 'signInSuccess', 'register', ->
    beforeEach -> @emitter = auth; @listener = timeoutable
  follow 'events', 'signInError', 'clear', ->
    beforeEach -> @emitter = auth; @listener = timeoutable
  follow 'events', 'signOutSuccess', 'clear', ->
    beforeEach -> @emitter = auth; @listener = timeoutable

  describe '#timeout', ->
    beforeEach ->
      spy = sinon.collection.spy()
      Em.run -> auth.timeoutable.callback = -> spy()

    describe 'startTime = null', ->
      beforeEach ->
        Em.run -> timeoutable.startTime = null

      it 'does not trigger callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).not.toHaveBeenCalled()

    describe 'current time < start time + timeout period', ->
      beforeEach ->
        Em.run ->
          auth.timeoutable.period = 2
          oneMinuteAgo = new Date(new Date().getTime() + 1*60*1000)
          timeoutable.startTime = oneMinuteAgo

      it 'does not trigger callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).not.toHaveBeenCalled()

    describe 'current time >= start time + timeout period', ->
      beforeEach ->
        Em.run ->
          auth.timeoutable.period = 2
          twoMinutesAgo = new Date(new Date().getTime() + 2*60*1000)
          timeoutable.startTime = twoMinutesAgo

      it 'triggers callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).toHaveBeenCalled()

  describe '#register', ->
    it 'sets startTime to current session startTime', ->
      Em.run ->
        auth._session.start()
        timeoutable.startTime = null
      expect(timeoutable.startTime).toBeFalsy()
      Em.run -> timeoutable.register()
      expect(timeoutable.startTime).toBe auth.startTime

    it 'delegates to timeout after specified period', ->
      jasmine.Clock.useMock()

      spy = sinon.collection.spy timeoutable, 'timeout'
      Em.run ->
        auth.timeoutable.period = 1
        timeoutable.register()

      jasmine.Clock.tick 30*1000
      expect(spy).not.toHaveBeenCalled()

      jasmine.Clock.tick 30*1000 + 1
      expect(spy).toHaveBeenCalled()

  describe '#reset', ->
    it 'sets new startTime', ->
      Em.run -> timeoutable.startTime = null
      expect(timeoutable.startTime).toBeFalsy()
      Em.run -> timeoutable.reset()
      expect(timeoutable.startTime instanceof Date).toBeTruthy()

    it 're-registers timeout', ->
      spy = sinon.collection.spy timeoutable, 'register'
      Em.run -> timeoutable.reset()
      expect(spy).toHaveBeenCalled()

  describe '#clear', ->
    it 'clears startTime', ->
      Em.run -> timeoutable.startTime = new Date()
      expect(timeoutable.startTime).toBeTruthy()
      Em.run -> timeoutable.clear()
      expect(timeoutable.startTime).toBeFalsy()

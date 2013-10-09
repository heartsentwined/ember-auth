describe 'Em.Auth.TimeoutableAuthModule', ->
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

  describe '#timeout', ->
    beforeEach ->
      spy = sinon.collection.spy()
      Em.run -> auth.timeoutable.callback = -> spy()

    describe '_startTime = null', ->
      beforeEach ->
        Em.run -> timeoutable._startTime = null

      it 'does not trigger callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).not.toHaveBeenCalled()

    describe 'current time < start time + timeout period', ->
      beforeEach ->
        Em.run ->
          auth.timeoutable.period = 2
          oneMinuteAgo = new Date(new Date().getTime() + 1*60*1000)
          timeoutable._startTime = oneMinuteAgo

      it 'does not trigger callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).not.toHaveBeenCalled()

    describe 'current time >= start time + timeout period', ->
      beforeEach ->
        Em.run ->
          auth.timeoutable.period = 2
          twoMinutesAgo = new Date(new Date().getTime() + 2*60*1000 + 1)
          timeoutable._startTime = twoMinutesAgo

      it 'triggers callback', ->
        Em.run -> timeoutable.timeout()
        expect(spy).toHaveBeenCalled()

  describe '#register', ->
    it 'sets _startTime to current session startTime', ->
      Em.run ->
        auth._session.start()
        timeoutable._startTime = null
      expect(timeoutable._startTime).toBeFalsy()
      Em.run -> timeoutable.register()
      expect(timeoutable._startTime).toBe auth.startTime

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
    it 'sets new _startTime', ->
      Em.run -> timeoutable._startTime = null
      expect(timeoutable._startTime).toBeFalsy()
      Em.run -> timeoutable.reset()
      expect(timeoutable._startTime instanceof Date).toBeTruthy()

    it 're-registers timeout', ->
      spy = sinon.collection.spy timeoutable, 'register'
      Em.run -> timeoutable.reset()
      expect(spy).toHaveBeenCalled()

  describe '#clear', ->
    it 'clears _startTime', ->
      Em.run -> timeoutable._startTime = new Date()
      expect(timeoutable._startTime).toBeTruthy()
      Em.run -> timeoutable.clear()
      expect(timeoutable._startTime).toBeFalsy()

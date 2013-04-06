describe 'Auth.SignOutController', ->
  controller = null

  beforeEach ->
    controller = Em.Controller.extend(Auth.SignOutController).create()
    spyOn controller, 'transitionToRoute'
    spyOn(Auth, 'resolveRedirectRoute').andCallFake (arg) -> "#{arg}-r"

  afterEach ->
    Auth.set 'authToken', null
    Auth.removeObserver 'authToken'
    controller.destroy()
    controller = null

  describe 'initial state: signed in', ->
    beforeEach ->
      Auth.set 'authToken', 'foo'
      controller.registerRedirect()

    describe 'Auth.authToken changes to different token', ->
      it 'does not redirect', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'Auth.authToken changes to same token', ->
      it 'does not redirect', ->
        Auth.set 'authToken', 'foo'
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'Auth.authToken changes to null', ->
      it 'redirects', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute.calls[0].args[0]).toBe 'signOut-r'

    describe 'consecutive Auth.authToken changes', ->
      it 'only redirects for the first time', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute.calls[0].args[0]).toBe 'signOut-r'
        Auth.set 'authToken', 'bar'
        Auth.set 'authToken', null
        expect(controller.transitionToRoute.calls.length).toBe 1

  describe 'initial state: not signed in', ->
    beforeEach ->
      Auth.set 'authToken', null
      controller.registerRedirect()

    describe 'Auth.authToken changes to different token', ->
      it 'does not redirect', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'Auth.authToken changes to same token (null)', ->
      it 'does not redirect', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'consecutive Auth.authToken changes', ->
      it 'redirects on first has-token to null change', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()
        Auth.set 'authToken', 'bar'
        Auth.set 'authToken', null
        expect(controller.transitionToRoute.calls[0].args[0]).toBe 'signOut-r'
        expect(controller.transitionToRoute.calls.length).toBe 1
        Auth.set 'authToken', 'baz'
        Auth.set 'authToken', null
        expect(controller.transitionToRoute.calls.length).toBe 1

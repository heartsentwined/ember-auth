describe 'Auth.SignInController', ->
  controller = null

  beforeEach ->
    controller = Em.Controller.extend(Auth.SignInController).create()
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
      it 'redirects', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0]).toEqual 'signIn-r'

    describe 'Auth.authToken changes to same token', ->
      it 'does not redirect', ->
        Auth.set 'authToken', 'foo'
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'Auth.authToken changes to null', ->
      it 'does not redirect', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'consecutive Auth.authToken changes', ->
      it 'only redirects for the first time', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0]).toEqual 'signIn-r'
        Auth.set 'authToken', 'baz'
        expect(controller.transitionToRoute.calls.length).toEqual 1

  describe 'initial state: not signed in', ->
    beforeEach ->
      Auth.set 'authToken', null
      controller.registerRedirect()

    describe 'Auth.authToken changes to different token', ->
      it 'redirects', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0]).toEqual 'signIn-r'

    describe 'Auth.authToken changes to same token (null)', ->
      it 'does not redirect', ->
        Auth.set 'authToken', null
        expect(controller.transitionToRoute).not.toHaveBeenCalled()

    describe 'consecutive Auth.authToken changes', ->
      it 'only redirects for the first time', ->
        Auth.set 'authToken', 'bar'
        expect(controller.transitionToRoute.calls[0].args[0]).toEqual 'signIn-r'
        Auth.set 'authToken', 'baz'
        expect(controller.transitionToRoute.calls.length).toEqual 1

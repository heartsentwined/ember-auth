example 'smart redirect', ({ from, to, reg }) ->
  describe "from #{from} route", ->
    it "redirects to #{to} route", ->
      em.ready()
      em.setInitUrl from
      em.controller(from).registerRedirect() if reg
      em.toRoute from
      expect(em.currentPath()).toEqual 'sign-in'
      Auth.set 'authToken', 'bar' # signs in
      expect(em.currentPath()).toEqual to

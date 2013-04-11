example 'remember me storage media support', (opts = {}) ->
  describe "##{opts.moduleMethod}", ->
    beforeEach ->
      spyOn localStorage, opts.localStorageMethod
      spyOn jQuery, opts.cookieMethod

    it 'supports localStorage', ->
      Auth.Config.reopen { rememberStorage: 'localStorage' }
      Auth.Module.RememberMe[opts.moduleMethod].apply(this, opts.moduleArgs)
      expect(localStorage[opts.localStorageMethod].calls[0].args)
        .toEqual opts.localStorageArgs
      expect(jQuery[opts.cookieMethod]).not.toHaveBeenCalled()

    it 'supports cookie', ->
      Auth.Config.reopen { rememberStorage: 'cookie' }
      Auth.Module.RememberMe[opts.moduleMethod].apply(this, opts.moduleArgs)
      expect(jQuery[opts.cookieMethod].calls[0].args)
        .toEqual opts.cookieArgs
      expect(localStorage[opts.localStorageMethod]).not.toHaveBeenCalled()

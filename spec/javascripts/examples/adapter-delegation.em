example 'adapter delegation', (env, method, args) ->
  describe "##{method}", ->
    it 'delegates to adapter', ->
      spy = sinon.collection.spy env.adapter, method
      env[method].apply(env, args)
      expect(spy).toHaveBeenCalledWithExactly.apply(expect(spy), args)

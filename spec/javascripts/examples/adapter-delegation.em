example 'adapter delegation', (env, method, args) ->
  describe "##{method}", ->
    it 'delegates to adapter', ->
      spy = sinon.collection.spy env.adapter, method
      Em.run -> env[method].apply(env, args)
      expect(spy).toHaveBeenCalledWithExactly.apply(expect(spy), args)

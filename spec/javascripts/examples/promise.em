  example 'return promise', ->
    it 'returns a promise', ->
      expect(@return.then).toBeDefined()

  example 'return promise', ->
    it 'returns a promise', ->
      expect(@return instanceof Em.RSVP.Promise).toBe true

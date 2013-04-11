example 'auth ajax content type', (value) ->
  if value
    it 'uses given contentType', ->
      expect(jQuery.ajax.calls[0].args[0].contentType).toEqual value
  else
    it 'does not set contentType', ->
      expect(jQuery.ajax.calls[0].args[0].contentType).not.toBeDefined()

example 'auth ajax data', (value, isSerialize = false) ->
  if value
    desc =
      if isSerialize
        'serializes data to json string'
      else
        'uses given data'
    it desc, ->
      expect(jQuery.ajax.calls[0].args[0].data).toEqual value
  else
    it 'does not set data', ->
      expect(jQuery.ajax.calls[0].args[0].data).not.toBeDefined()

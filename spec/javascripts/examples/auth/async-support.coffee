example 'auth async option', (value) ->
  it 'sets async options', ->
    expect(Auth.ajax.calls[0].args[0].async).toEqual value

example 'auth async preserve data', (value) ->
  it 'does not pollute data', ->
    expect(Auth.ajax.calls[0].args[0].data).toEqual value

example 'auth async support', ->
  describe 'supports async option', ->
    beforeEach -> spyOn(Auth, 'ajax').andCallThrough()

    describe 'async = true', ->
      beforeEach -> Auth.signIn { foo: 'bar', async: true }
      follow 'auth async option', true
      follow 'auth async preserve data', JSON.stringify { foo: 'bar' }

    describe 'async = false', ->
      beforeEach -> Auth.signIn { foo: 'bar', async: false }
      follow 'auth async option', false
      follow 'auth async preserve data', JSON.stringify { foo: 'bar' }

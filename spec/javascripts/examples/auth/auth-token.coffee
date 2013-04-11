example 'auth token in param', (opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sends auth token as param with overriden value'
      else
        'sends auth token as param with auth token value'
    it desc, ->
      expect(jQuery.ajax.calls[0].args[0].data?[opts.key])
        .toEqual opts.value
  else
    it 'does not tamper with params', ->
      expect(jQuery.ajax.calls[0].args[0].data?[opts.key])
        .not.toBeDefined()

example 'auth token in authorization header', (opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sends Authorization header with overridden value'
      else
        'sends Authorization header with auth token value'
    it desc, ->
      expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
        .toEqual opts.value
  else
    it 'does not send Authorization header', ->
      expect(jQuery.ajax.calls[0].args[0].headers?.Authorization)
        .not.toBeDefined()

example 'auth token in custom header', (opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sends custom header with overridden value'
      else
        'sends custom header with auth token value'
    it desc, ->
      expect(jQuery.ajax.calls[0].args[0].headers?[opts.key])
        .toEqual opts.value
  else
    it 'does not send custom header', ->
      expect(jQuery.ajax.calls[0].args[0].headers?[opts.key])
        .not.toBeDefined()

example 'auth token location', (location, value) ->
  setValue = (def) ->
    opts.value = def
    if value
      opts.value = value; opts.isOverride = true

  opts = { key: 'tokenKey' }
  setValue 'token-value'
  if location != 'param'
    delete opts.value
  follow 'auth token in param', opts

  opts = {}
  setValue 'headerKey token-value'
  if location != 'authorization header'
    delete opts.value
  follow 'auth token in authorization header', opts

  opts = { key: 'headerKey' }
  setValue 'token-value'
  if location != 'custom header'
    delete opts.value
  follow 'auth token in custom header', opts

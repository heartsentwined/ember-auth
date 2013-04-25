example 'token in param', (output, opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sets auth token within data object with overriden value'
      else
        'sets auth token within data object with token value'
    it desc, ->
      expect(output.data?[opts.key]).toEqual opts.value
  else
    it 'does not tamper with params', ->
      expect(output.data?[opts.key]).not.toBeDefined()

example 'token in auth header', (output, opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sets Authorization header within headers object with overriden value'
      else
        'sets Authorization header within headers object with token value'
    it desc, ->
      expect(output.headers?.Authorization).toEqual opts.value
  else
    it 'does not set Authorization header', ->
      expect(output.headers?.Authorization).not.toBeDefined()

example 'token in custom header', (output, opts = {}) ->
  if opts.value
    desc =
      if opts.isOverride
        'sets custom header within headers object with overriden value'
      else
        'sets custom header within headers object with token value'
    it desc, ->
      expect(output.headers?[opts.key]).toEqual opts.value
  else
    it 'does not set custom header', ->
      expect(output.headers?[opts.key]).not.toBeDefined()

example 'token location', (output, location, value) ->
  opts = {}
  setValue = (def) ->
    opts.value = def
    if value then opts.value = value; opts.isOverride = true

  opts = { key: 'key' }
  setValue 'token'
  if location != 'param' then delete opts.value
  follow 'token in param', output, opts

  opts = {}
  setValue 'key token'
  if location != 'auth header' then delete opts.value
  follow 'token in auth header', output, opts

  opts = { key: 'key' }
  setValue 'token'
  if location != 'custom header' then delete opts.value
  follow 'token in custom header', output, opts

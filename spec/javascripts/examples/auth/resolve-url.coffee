example 'auth resolve url', (opts = {}) ->
  desc =
    if opts.isAppend
      'appends path to Auth.Config.baseUrl'
    else
      'returns path'
  it desc, ->
    expect(Auth.resolveUrl(opts.input)).toEqual opts.output
    expect(Auth.resolveUrl("/#{opts.input}")).toEqual opts.output

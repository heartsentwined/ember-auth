example 'property injection', (from, to, property) ->
  it "injects #{property}", ->
    from.set property, 'foo'
    expect(to.get(property)).toEqual 'foo'

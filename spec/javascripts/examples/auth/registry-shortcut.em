example 'registry shortcut', (key) =>
  it "##{key} to access registry.#{key}", =>
    @auth.registry.set key, 'baz'
    expect(@auth.get(key)).toEqual 'baz'

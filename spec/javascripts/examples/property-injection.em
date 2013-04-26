example 'property injection', (from, to, property) ->
  Em.run -> from.set property, 'foo'
  expect(to.get(property)).toEqual 'foo'

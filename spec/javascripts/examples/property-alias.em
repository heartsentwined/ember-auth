example 'property alias', (property) ->
  it "injects ##{property}", ->
    Em.run => @from.set property, 'foo'
    expect(@to.get(property)).toEqual 'foo'

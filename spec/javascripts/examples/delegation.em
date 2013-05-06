example 'delegation', (fromMethod, fromArg, toMethod, toArg) ->
  it "delegates ##{fromMethod} to (self/child)##{toMethod}", ->
    spy = sinon.collection.spy @to, toMethod
    Em.run => @from[fromMethod].apply(@from, fromArg)
    expect(spy).toHaveBeenCalledWithExactly.apply(expect(spy), toArg)

example 'delegation', (from, fromMethod, fromArg, to, toMethod, toArg) ->
  spy = sinon.collection.spy to, toMethod
  Em.run -> from[fromMethod].apply(from, fromArg)
  expect(spy).toHaveBeenCalledWithExactly.apply(expect(spy), toArg)

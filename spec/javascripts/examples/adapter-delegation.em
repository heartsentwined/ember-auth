example 'adapter delegation', (method, args) ->
  it "delegates ##{method} to adapter", ->
    spy = sinon.collection.spy @type.adapter, method
    Em.run => @type[method].apply(@type, args)
    expect(spy).toHaveBeenCalledWithExactly.apply(expect(spy), args)

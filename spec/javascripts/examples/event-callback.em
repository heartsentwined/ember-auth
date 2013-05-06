example 'events', (event, callback) ->
  it "##{callback} on #{event}", ->
    spy = sinon.collection.spy @listener, callback
    Em.run => @emitter.trigger event
    expect(spy).toHaveBeenCalled()

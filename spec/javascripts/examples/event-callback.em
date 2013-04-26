example 'events', (eventObj, event, callbackObj, callback) ->
  it "calls #{callback} on #{event}", ->
    spy = sinon.collection.spy callbackObj, callback
    Em.run -> eventObj.trigger event
    expect(spy).toHaveBeenCalled()

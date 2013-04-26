example 'events', (eventObj, event, callbackObj, callback) ->
  spy = sinon.collection.spy callbackObj, callback
  Em.run -> eventObj.trigger event
  expect(spy).toHaveBeenCalled()

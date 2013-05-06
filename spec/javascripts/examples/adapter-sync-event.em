example 'adapter sync event', ->
  return
  it 'delegates to adapter#syncEvent', ->
    if @type.adapter.syncEvent?
      spy = sinon.collection.stub @type.adapter, 'syncEvent', ->
    else
      @type.adapter.syncEvent = ->
      spy = sinon.collection.spy @type.adapter, 'syncEvent'
    @type.syncEvent 'foo'
    expect(spy).toHaveBeenCalledWithExactly 'foo'

  it 'allows undefined syncEvent in adapter', ->
    delete @type.adapter.syncEvent if @type.adapter.syncEvent?
    expect(=> @type.syncEvent()).not.toThrow()

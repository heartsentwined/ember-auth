describe 'Em.Auth.Module', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = authTest.create()
  afterEach ->
    auth.destroy() if auth
    delete Em.Auth.Module.FooBar if Em.Auth.Module.FooBar?
    sinon.collection.restore()

  it 'initializes modules', ->
    class Em.Auth.Module.FooBar
    spy = sinon.collection.spy Em.Auth.Module.FooBar, 'create'
    auth = authTest.create { modules: ['fooBar'] }
    expect(spy).toHaveBeenCalledWithExactly { auth: auth }

  it 'throws if module not found', ->
    expect(-> authTest.create { modules: ['fooBar'] }).toThrow()

  it 'sets initialized modules in auth.module', ->
    class Em.Auth.Module.FooBar
      baz: ->
    auth = authTest.create { modules: ['fooBar'] }
    expect(auth.module['fooBar']).toBeDefined()
    expect(auth.module['fooBar'].baz).toBeDefined()

  it 'initializes modules in specified order', ->
    class Em.Auth.Module.Foo
    class Em.Auth.Module.Bar
    fooSpy = sinon.collection.spy Em.Auth.Module.Foo, 'create'
    barSpy = sinon.collection.spy Em.Auth.Module.Bar, 'create'
    auth = authTest.create { modules: ['foo', 'bar'] }
    sinon.assert.callOrder(fooSpy, barSpy)

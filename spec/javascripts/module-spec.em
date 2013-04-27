describe 'Em.Auth.Module', ->
  auth = null
  spy  = null

  beforeEach ->
    auth = emAuth.create()
  afterEach ->
    auth.destroy() if auth
    delete Em.Auth.Module.FooBar if Em.Auth.Module.FooBar?
    sinon.collection.restore()

  it 'initializes modules', ->
    class Em.Auth.Module.FooBar
    spy = sinon.collection.spy Em.Auth.Module.FooBar, 'create'
    auth = emAuth.create { modules: ['fooBar'] }
    expect(spy).toHaveBeenCalledWithExactly { auth: auth }

  it 'throws if module not found', ->
    expect(-> emAuth.create { modules: ['fooBar'] }).toThrow()

  it 'sets initialized modules in auth.module', ->
    class Em.Auth.Module.FooBar
      baz: ->
    auth = emAuth.create { modules: ['fooBar'] }
    expect(auth.module['fooBar']).toBeDefined()
    expect(auth.module['fooBar'].baz).toBeDefined()

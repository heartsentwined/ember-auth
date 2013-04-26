describe 'Em.Auth.Module', ->
  auth = null
  spy  = null

  beforeEach ->
    Em.run -> auth = Em.Auth.create()
  afterEach ->
    auth.destroy() if auth
    delete Em.Auth.Module.FooBar if Em.Auth.Module.FooBar?
    sinon.collection.restore()

  it 'initializes modules', ->
    class Em.Auth.Module.FooBar
    spy = sinon.collection.spy Em.Auth.Module.FooBar, 'create'
    Em.run -> auth = Em.Auth.create { modules: ['fooBar'] }
    expect(spy).toHaveBeenCalledWithExactly { auth: auth }

  it 'throws if module not found', ->
    expect(-> Em.run -> Em.Auth.create { modules: ['fooBar'] }).toThrow()

  it 'sets initialized modules in auth.module', ->
    class Em.Auth.Module.FooBar
      baz: ->
    Em.run -> auth = Em.Auth.create { modules: ['fooBar'] }
    expect(auth.module['fooBar']).toBeDefined()
    expect(auth.module['fooBar'].baz).toBeDefined()

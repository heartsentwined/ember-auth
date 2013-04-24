example 'adapter init', (env) =>
  klass = Em.String.classify env
  data = {}

  it 'initializes the given adapter', =>
    data["#{env}Adapter"] = 'dummy'
    spy = sinon.collection.spy Em.Auth[klass].Dummy, 'create'
    @auth = Em.Auth.create(data)
    expect(spy).toHaveBeenCalledWithExactly { auth: @auth }

  it 'throws if adapter not found', =>
    data["#{env}Adapter"] = 'foo'
    expect(-> Em.Auth.create(data)).toThrow()

beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()

describe 'Ember.Auth.Config', =>
  it 'is customizable', =>
    expect(@auth.config.foo).not.toBeDefined()
    @auth.config.foo = 'bar'
    expect(@auth.config.foo).toEqual 'bar'

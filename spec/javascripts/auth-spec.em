beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()

describe 'Ember.Auth', =>
  it 'supports events', => expect(@auth.on).toBeDefined()

beforeEach =>
  @auth = Em.Auth.create()
afterEach =>
  @auth.destroy()

describe 'Ember.Auth', =>
  it 'supports events', => expect(@auth.on).toBeDefined()

  follow 'registry shortcut', 'authToken'
  follow 'registry shortcut', 'currentUserId'
  follow 'registry shortcut', 'currentUser'
  follow 'registry shortcut', 'jqxhr'
  follow 'registry shortcut', 'json'

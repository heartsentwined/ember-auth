describe 'Auth.Config', ->
  it 'is customizable', ->
    Auth.Config.reopen { tokenCreateUrl: 'foo' }
    expect(Auth.Config.get 'tokenCreateUrl').toBe 'foo'

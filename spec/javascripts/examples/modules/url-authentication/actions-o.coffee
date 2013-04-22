example 'url authentication - authenticate - no sign in', ->
  it 'does not attempt a sign in', ->
    Auth.Module.UrlAuthentication.authenticate()
    expect(Auth.signIn).not.toHaveBeenCalled()

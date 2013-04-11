example 'recall no sign in', ->
  it 'does not attempt a sign in', ->
    Auth.Module.RememberMe.recall()
    expect(Auth.signIn).not.toHaveBeenCalled()

example 'recall no remember', ->
  it 'does not attempt to remember session', ->
    Auth.Module.RememberMe.remember()
    expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

example 'remember me - recall - no sign in', ->
  it 'does not attempt a sign in', ->
    Auth.Module.RememberMe.recall()
    expect(Auth.signIn).not.toHaveBeenCalled()

example 'remember me - remember - no store session', ->
  it 'does not attempt to remember session', ->
    Auth.Module.RememberMe.remember()
    expect(Auth.Module.RememberMe.storeToken).not.toHaveBeenCalled()

example 'remember me - remember - clear prev session', ->
  it 'clears any residue cookie', ->
    spyOn Auth.Module.RememberMe, 'forget'
    Auth.Module.RememberMe.remember()
    expect(Auth.Module.RememberMe.forget).toHaveBeenCalled()

class Em.Auth.DummyAuthResponse extends Em.Auth.AuthResponse
  canonicalize: (response) -> JSON.parse response

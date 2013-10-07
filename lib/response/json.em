class Em.Auth.JsonAuthResponse extends Em.Auth.AuthResponse
  canonicalize: (response) ->
    return {} unless response
    try
      JSON.parse response
    catch error
      throw 'Invalid JSON format'

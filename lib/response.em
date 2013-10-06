class Em.Auth.AuthResponse
  canonicalize: mustImplement 'canonicalize'

mustImplement = (method) ->
  ->
    throw new Em.Error "Your response adapter #{@toString()} must implement the required method `#{method}`"

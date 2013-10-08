mustImplement = (method) ->
  ->
    throw new Em.Error "Your response adapter #{@toString()} must implement the required method `#{method}`"

class Em.Auth.AuthResponse
  # canonicalize a raw response string to a js object
  #
  # @param [string] raw response string
  #
  # @return [object] a js object
  canonicalize: mustImplement 'canonicalize'

class Em.Auth.AuthStrategy
  serialize:   mustImplement 'serialize'
  deserialize: mustImplement 'deserialize'

mustImplement = (method) ->
  ->
    throw new Em.Error "Your strategy adapter #{@toString()} must implement the required method `#{method}`"

class Em.Auth.AuthStrategy
  serialize:   mustImplement 'serialize'
  deserialize: mustImplement 'deserialize'

mustImplement = (method) ->
  ->
    throw new Em.Error "Your request adapter #{@toString()} must implement the required method `#{method}`"

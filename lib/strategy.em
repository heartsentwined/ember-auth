mustImplement = (method) ->
  ->
    throw new Em.Error "Your strategy adapter #{@toString()} must implement the required method `#{method}`"

class Em.Auth.AuthStrategy
  # inject the current session into a request options object
  #
  # @param [object] jquery.ajax(settings) -style options object
  #
  # @return [object] the options object with current session data
  serialize:   mustImplement 'serialize'

  # extract session data from a response object
  #
  # @param [object] object representing response payload, as `canonicalize`d
  #   by the response adapter
  #
  # @return [Em.RSVP.Promise] (opt)
  deserialize: mustImplement 'deserialize'

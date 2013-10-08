mustImplement = (method) ->
  ->
    throw new Em.Error "Your request adapter #{@toString()} must implement the required method `#{method}`"

class Em.Auth.AuthRequest
  # send a sign in request
  #
  # @param [string] url to the sign in end point
  # @param [object] jquery.ajax(settings) -style options object
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   response body as expected by the response adapter
  signIn:  mustImplement 'signIn'

  # send a sign out request
  #
  # @param [string] url to the sign out end point
  # @param [object] jquery.ajax(settings) -style options object
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   response body as expected by the response adapter
  signOut: mustImplement 'signOut'

  # send a custom request
  #
  # @param [string] url to the end point
  # @param [object] jquery.ajax(settings) -style options object
  #
  # @return [Em.RSVP.Promise] a promise that resolves and rejects with the
  #   response body as expected by the response adapter
  send:    mustImplement 'send'

  # resolve url, possibly to different auth.baseUrl if set
  #
  # @param path [string] relative url path
  #
  # @return [string] the resolved url
  resolveUrl: (path) ->
    base = @auth.baseUrl
    if base && base[base.length-1] == '/'
      base = base.substr(0, base.length-1)
    if path?[0] == '/'
      path = path.substr(1, path.length)
    [base, path].join('/')

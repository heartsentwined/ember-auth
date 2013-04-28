class Em.Auth.Response
  init: ->
    @response? || (@response = {})

    unless @adapter?
      adapter = Em.String.classify @auth.responseAdapter
      if Em.Auth.Response[adapter]?
        @adapter = Em.Auth.Response[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Response.#{adapter}"

    @inject()

  canonicalize: (input) -> @response = @adapter.canonicalize input

  inject: ->
    @auth.reopen
      response: Em.computed(=> @response).property('_response.response')

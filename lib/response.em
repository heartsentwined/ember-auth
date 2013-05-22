class Em.Auth.Response
  init: ->
    @response? || (@response = {})

    unless @adapter?
      adapter = Em.String.capitalize Em.String.camelize @auth.responseAdapter
      if Em.Auth.Response[adapter]?
        @adapter = Em.Auth.Response[adapter].create { auth: @auth }
      else
        throw "Adapter not found: Em.Auth.Response.#{adapter}"

    @inject()

  syncEvent: ->
    @adapter.syncEvent.apply @adapter, arguments if @adapter.syncEvent?

  canonicalize: (input) -> @response = @adapter.canonicalize input

  inject: ->
    @auth.reopen
      response: Em.computed(=> @response).property('_response.response')

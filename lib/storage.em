class Em.Auth.Storage
  init: ->
    adapter = Em.String.classify @auth.storageAdapter
    if Em.Auth.Storage[adapter]?
      @adapter = Em.Auth.Storage[adapter].create({ auth: @auth })
    else
      throw "Adapter not found: Em.Auth.Storage.#{adapter}"

  retrieve: (key, opts)        -> @adapter.retrieve  key, opts
  store:    (key, value, opts) -> @adapter.store     key, value, opts
  remove:   (key, opts)        -> @adapter.remove    key, opts

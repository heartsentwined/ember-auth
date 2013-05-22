class Em.Auth.Module
  init: ->
    unless @module?
      @module = {}
      for key in @auth.modules
        key    = Em.String.camelize key
        module = Em.String.capitalize Em.String.camelize key
        if Em.Auth.Module[module]?
          @set "module.#{key}", Em.Auth.Module[module].create { auth: @auth }
        else
          throw "Module not found: Em.Auth.Module.#{module}"

    @inject()

  syncEvent: ->
    args = arguments
    for _, module of @module
      module.syncEvent.apply module, args if module.syncEvent?

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      module: Em.computed(=> @module).property('_module.module')

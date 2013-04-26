class Em.Auth.Module
  module: {}

  init: ->
    for key in @auth.modules
      module = Em.String.classify key
      if Em.Auth.Module[module]?
        @set "module.#{key}", Em.Auth.Module[module].create { auth: @auth }
      else
        throw "Module not found: Em.Auth.Module.#{module}"
    @inject()

  inject: ->
    # TODO make these two-way bindings instead of read-only from auth side
    @auth.reopen
      module: Em.computed(=> @module).property('_module.module')

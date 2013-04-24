class Em.Auth.Module
  init: ->
    for key in @auth.modules
      module = Em.String.classify key
      if Em.Auth.Module[module]?
        @module[key] = Em.Auth.Module[module].create({ auth: @auth })
      else
        throw "Module not found: Em.Auth.Module.#{module}"
    @inject()

  inject: ->
    self = this
    @auth.reopen
      module: ~> self.module

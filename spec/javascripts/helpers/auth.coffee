exports = exports ? this

create = (opts) ->
  def =
    requestAdapter:  'dummy'
    responseAdapter: 'dummy'
    strategyAdapter: 'dummy'
    sessionAdapter:  'dummy'
    modules:         []
  Em.run -> Em.Auth.create jQuery.extend true, def, opts

exports.authTest = { create: create }

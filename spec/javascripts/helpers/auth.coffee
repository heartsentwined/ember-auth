exports = exports ? this

create = (opts) ->
  def =
    requestAdapter:  'dummy'
    responseAdapter: 'dummy'
    strategyAdapter: 'dummy'
    sessionAdapter:  'dummy'
  Em.run -> Em.Auth.create jQuery.extend true, def, opts

exports.emAuth = { create: create }

exports = exports ? this

create = (opts) ->
  def =
    request:  'dummy'
    response: 'dummy'
    strategy: 'dummy'
    session:  'dummy'
    modules:  []
  Em.run -> Em.Auth.create jQuery.extend true, def, opts

exports.authTest = { create: create }

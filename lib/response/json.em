class Em.Auth.Response.Json
  canonicalize: (input) ->
    switch typeof input
      when 'object' then input
      when 'string' then JSON.parse input
      else throw 'Invalid JSON format'

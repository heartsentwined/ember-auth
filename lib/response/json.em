class Em.Auth.Response.Json
  canonicalize: (input) ->
    return {} unless input
    switch typeof input
      when 'object' then input
      when 'string'
        try
          JSON.parse input
        catch error
          throw 'Invalid JSON format'
      else throw 'Invalid JSON format'



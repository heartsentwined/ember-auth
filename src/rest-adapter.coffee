Auth.RESTAdapter = DS.RESTAdapter.extend
  ajax: (url, type, hash) ->
    if token = Auth.get('authToken')
      hash.data ||= {}
      hash.data[Auth.Config.get('tokenKey')] = Auth.get('authToken')
    hash.context = this
    Auth.ajax(url, type, hash)

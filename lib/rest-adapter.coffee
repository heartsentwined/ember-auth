Auth.RESTAdapter = DS.RESTAdapter.extend
  ajax: (url, type, hash) ->
    hash.context = this
    Auth.ajax(url, type, hash)

if DS? and DS.RESTAdapter?
  Auth.RESTAdapter = DS.RESTAdapter.extend
    ajax: (url, type, settings) ->
      settings = settings || {};
      settings.url = url
      settings.type = type
      settings.context = this
      Auth.ajax(settings)

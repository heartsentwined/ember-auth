exports = exports ? this

uuid = 1
apps = {}
currentPath = null

app = -> apps[uuid]

create = (callback) ->
  Em.run ->
    apps[uuid] = Em.Application.create()
    app().Store = DS.Store.extend({ revision: 11 })
    app().deferReadiness()
    app().Router.reopen { location: 'none' }
    callback.apply(this, [app()]) if typeof callback == 'function'

ready = (callback) ->
  Em.run ->
    app().ApplicationController = Em.Controller.extend
      currentPathDidChange: (->
        currentPath = @get 'currentPath'
      ).observes('currentPath')
    callback.apply(this, [app()]) if typeof callback == 'function'
  Em.run app(), 'advanceReadiness'

destroy = (callback) ->
  Em.run ->
    callback.apply(this, [app()]) if typeof callback == 'function'
    app().destroy()
    delete apps[uuid]
  uuid = uuid + 1

run = (callback) ->
  callback.apply(this, [app()]) if typeof callback == 'function'

lookup     = (name)  -> app().__container__.lookup(name)
router     =         -> lookup 'router:main'
toRoute    = (route) -> Em.run -> router().transitionTo route
controller = (name)  -> lookup "controller:#{name.toLowerCase()}"

exports.appTest =
  create:      create
  ready:       ready
  destroy:     destroy
  run:         run
  lookup:      lookup
  router:      router
  controller:  controller
  toRoute:     toRoute
  currentPath: -> currentPath

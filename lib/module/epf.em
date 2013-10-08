class Em.Auth.EpfAuthModule
  init: ->
    @config? || (@config = @auth.epf)
    @patch()

    @auth.reopen
      user: Em.computed.alias 'module.epf.user'

    @auth.addHandler 'signInSuccess',  @findUser
    @auth.addHandler 'signInError',    @clearUser
    @auth.addHandler 'signOutSuccess', @clearUser

  # @property [Ep.Model|null] current signed in user, if signed in and
  #   enabled auto-find user; otherwise null
  user: null

  # find the current signed in user
  findUser: ->
    return unless @auth.userId? && @config.userModel
    @session.load(@config.userModel, @auth.userId).then (user) => @user = user

  # clear any current signed in user
  clearUser: ->
    @user = null

  patch: ->
    self = this
    Ep.RestAdapter.reopen
      ajax: (url, type, settings) ->
        super url, type, self.auth._strategy.serialize(settings || {})

Em.onLoad 'Ember.Application', (application) ->
  application.initializer
    name: 'ember-auth.epf'
    after: 'ember-auth'

    initialize: (container, app) ->
      app.inject 'authModule:epf', 'session', 'session:main'

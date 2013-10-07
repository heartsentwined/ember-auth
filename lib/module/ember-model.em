class Em.Auth.EmberModelAuthModule
  init: ->
    @config? || (@config = @auth.emberModel)
    @patch()

    @auth.reopen
      user: Em.computed.alias 'module.emberModel.user'

    @auth.addHandler 'signInSuccess',  @findUser
    @auth.addHandler 'signInError',    @clearUser
    @auth.addHandler 'signOutSuccess', @clearUser

  # @property [Ember.Model|null] current signed in user, if signed in and
  #   enabled auto-find user; otherwise null
  user: null

  # find the current signed in user
  findUser: ->
    return unless @auth.userId? && (model = Em.get @config.userModel)
    model.fetch(@auth.userId).then (user) => @user = user

  # clear any current signed in user
  clearUser: ->
    @user = null

  patch: ->
    self = this
    Ember.RESTAdapter.reopen
      _ajax: (url, params, method) ->
        settings = this.ajaxSettings url, method
        new Ember.RSVP.Promise (resolve, reject) ->
          if params
            # settings.data needs to be an object rather than a string
            # regardless of the method. It's going to be stringified
            # and contentType will be set in Em.Auth#send
            # if needed.
            settings.data = params
          settings.success = (json)  -> Ember.run null, resolve, json
          settings.error   = (jqxhr) -> Ember.run null, reject, jqxhr
          self.auth.send settings

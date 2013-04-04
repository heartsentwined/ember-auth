(function() {
  var evented;

  evented = Em.Object.extend(Em.Evented);

  window.Auth = evented.create({
    authToken: null,
    currentUserId: null,
    currentUser: null,
    jqxhr: null,
    prevRoute: null,
    signIn: function(data) {
      var async,
        _this = this;

      if (data == null) {
        data = {};
      }
      async = data.async != null ? data.async : true;
      if (data.async != null) {
        delete data['async'];
      }
      return this.ajax(this.resolveUrl(Auth.Config.get('tokenCreateUrl')), 'POST', {
        data: data,
        async: async
      }).done(function(json, status, jqxhr) {
        var model;

        _this.set('authToken', json[Auth.Config.get('tokenKey')]);
        _this.set('currentUserId', json[Auth.Config.get('idKey')]);
        if (model = Auth.Config.get('userModel')) {
          _this.set('currentUser', model.find(_this.get('currentUserId')));
        }
        _this.set('json', json);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInSuccess');
      }).fail(function(jqxhr) {
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInError');
      }).always(function(jqxhr) {
        _this.set('prevRoute', null);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signInComplete');
      });
    },
    signOut: function(data) {
      var async,
        _this = this;

      if (data == null) {
        data = {};
      }
      data[Auth.Config.get('tokenKey')] = this.get('authToken');
      async = data.async != null ? data.async : true;
      if (data.async != null) {
        delete data['async'];
      }
      return this.ajax(this.resolveUrl(Auth.Config.get('tokenDestroyUrl')), 'DELETE', {
        data: data,
        async: async
      }).done(function(json, status, jqxhr) {
        _this.set('authToken', null);
        _this.set('currentUserId', null);
        _this.set('currentUser', null);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signOutSuccess');
      }).fail(function(jqxhr) {
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signOutError');
      }).always(function(jqxhr) {
        _this.set('prevRoute', null);
        _this.set('jqxhr', jqxhr);
        return _this.trigger('signOutComplete');
      });
    },
    resolveUrl: function(path) {
      var base;

      base = Auth.Config.get('baseUrl');
      if (base && base[base.length - 1] === '/') {
        base = base.substr(0, base.length - 1);
      }
      if ((path != null ? path[0] : void 0) === '/') {
        path = path.substr(1, path.length);
      }
      return [base, path].join('/');
    },
    resolveRedirectRoute: function(type) {
      var fallback, isSmart, sameRoute, typeClassCase;

      if (type !== 'signIn' && type !== 'signOut') {
        return null;
      }
      typeClassCase = "" + (type[0].toUpperCase()) + (type.slice(1));
      isSmart = Auth.Config.get("smart" + typeClassCase + "Redirect");
      fallback = Auth.Config.get("" + type + "RedirectFallbackRoute");
      sameRoute = Auth.Config.get("" + type + "Route");
      if (!isSmart) {
        return fallback;
      }
      if ((this.prevRoute == null) || this.prevRoute === sameRoute) {
        return fallback;
      } else {
        return this.prevRoute;
      }
    },
    ajax: function(url, type, hash) {
      var token;

      if (token = this.get('authToken')) {
        if (Auth.Config.get('requestHeaderAuthorization')) {
          hash.headers || (hash.headers = {});
          hash.headers[Auth.Config.get('requestHeaderKey')] = this.get('authToken');
        } else {
          hash.data || (hash.data = {});
          hash.data[Auth.Config.get('tokenKey')] = this.get('authToken');
        }
      }
      hash.url = url;
      hash.type = type;
      hash.dataType = 'json';
      hash.contentType = 'application/json; charset=utf-8';
      if (hash.data && type !== 'GET') {
        hash.data = JSON.stringify(hash.data);
      }
      return jQuery.ajax(hash);
    }
  });

}).call(this);
(function() {
  Auth.Config = Em.Object.create({
    tokenCreateUrl: null,
    tokenDestroyUrl: null,
    tokenKey: null,
    idKey: null,
    userModel: null,
    baseUrl: null,
    requestHeaderAuthorization: false,
    requestHeaderKey: null,
    signInRoute: null,
    signOutRoute: null,
    authRedirect: false,
    smartSignInRedirect: false,
    smartSignOutRedirect: false,
    signInRedirectFallbackRoute: 'index',
    signOutRedirectFallbackRoute: 'index',
    rememberMe: false,
    rememberTokenKey: null,
    rememberPeriod: 14,
    rememberAutoRecall: true,
    rememberUsingLocalStorage: false
  });

}).call(this);
(function() {
  Auth.Route = Em.Route.extend(Em.Evented, {
    redirect: function() {
      if (!Auth.get('authToken')) {
        this.trigger('authAccess');
        if (Auth.Config.get('authRedirect')) {
          Auth.set('prevRoute', this.routeName);
          return this.transitionTo(Auth.Config.get('signInRoute'));
        }
      }
    }
  });

}).call(this);
(function() {
  Auth.SignInController = Em.ObjectController.extend({
    registerRedirect: function() {
      return Auth.addObserver('authToken', this, 'smartSignInRedirect');
    },
    smartSignInRedirect: function() {
      if (Auth.get('authToken')) {
        this.transitionToRoute(Auth.resolveRedirectRoute('signIn'));
        return Auth.removeObserver('authToken', this, 'smartSignInRedirect');
      }
    }
  });

}).call(this);
(function() {
  Auth.SignOutController = Em.ObjectController.extend({
    registerRedirect: function() {
      return Auth.addObserver('authToken', this, 'smartSignOutRedirect');
    },
    smartSignOutRedirect: function() {
      if (!Auth.get('authToken')) {
        this.transitionToRoute(Auth.resolveRedirectRoute('signOut'));
        return Auth.removeObserver('authToken', this, 'smartSignOutRedirect');
      }
    }
  });

}).call(this);
(function() {
  Auth.RESTAdapter = DS.RESTAdapter.extend({
    ajax: function(url, type, hash) {
      hash.context = this;
      return Auth.ajax(url, type, hash);
    }
  });

}).call(this);
(function() {
  Auth.Module = Em.Object.create();

}).call(this);
(function() {
  Auth.Module.RememberMe = Em.Object.create({
    init: function() {
      var _this = this;

      Auth.on('signInSuccess', function() {
        return _this.remember();
      });
      Auth.on('signInError', function() {
        return _this.forget();
      });
      return Auth.on('signOutSuccess', function() {
        return _this.forget();
      });
    },
    recall: function(opts) {
      var data, token;

      if (opts == null) {
        opts = {};
      }
      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      if (!Auth.get('authToken') && (token = this.retrieveToken())) {
        data = {};
        if (opts.async != null) {
          data['async'] = opts.async;
        }
        data[Auth.Config.get('rememberTokenKey')] = token;
        return Auth.signIn(data);
      }
    },
    remember: function() {
      var token;

      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      token = Auth.get('json')[Auth.Config.get('rememberTokenKey')];
      if (token && token !== this.retrieveToken()) {
        return this.storeToken(token);
      }
    },
    forget: function() {
      if (!Auth.Config.get('rememberMe')) {
        return;
      }
      return this.removeToken();
    },
    retrieveToken: function() {
      if (Auth.Config.get('rememberUsingLocalStorage')) {
        return localStorage.getItem('ember-auth-remember-me');
      } else {
        return $.cookie('ember-auth-remember-me');
      }
    },
    storeToken: function(token) {
      if (Auth.Config.get('rememberUsingLocalStorage')) {
        return localStorage.setItem('ember-auth-remember-me', token);
      } else {
        return $.cookie('ember-auth-remember-me', token, {
          expires: Auth.Config.get('rememberPeriod')
        });
      }
    },
    removeToken: function() {
      if (Auth.Config.get('rememberUsingLocalStorage')) {
        return localStorage.removeItem('ember-auth-remember-me');
      } else {
        return $.removeCookie('ember-auth-remember-me');
      }
    }
  });

  Auth.Route.reopen({
    redirect: function() {
      var callback, request, self;

      if (Auth.Config.get('rememberMe') && Auth.Config.get('rememberAutoRecall')) {
        if (request = Auth.Module.RememberMe.recall({
          async: false
        })) {
          self = this;
          callback = this._super;
          return request.always(function() {
            return callback.call(self);
          });
        }
      }
      return this._super();
    }
  });

}).call(this);
(function() {


}).call(this);
